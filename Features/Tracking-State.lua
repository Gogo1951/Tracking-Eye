local _, ns = ...

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.state = {
	currentIcon = ns.ICON_DEFAULT,
	wasFarming = false,
	lastCastSpell = nil,
	--[[
        enteredWorldAt anchors the login/reload grace window used by
        TryRecastPersistent (initialized at file load so triggers that
        arrive before the first PLAYER_ENTERING_WORLD are still covered).
        lastTrackingCastAt debounces recasts against the
        MINIMAP_UPDATE_TRACKING echo of our own cast.
    ]]
	enteredWorldAt = GetTime(),
	lastTrackingCastAt = 0,
	--[[
        Tracked from LOOT_OPENED / LOOT_CLOSED rather than by reading LootFrame:
        Speedy-Loot-style add-ons hide that frame while looting is still open, so
        the events are the only reliable source. Read by ns.CanCast.
    ]]
	lootWindowOpen = false,
	--[[
        Flipped true by UpdateIcon once the tracking mirror positively reports
        our own lastCastSpell — i.e. the mirror has caught up. After that, a nil
        mirror reading is a genuine external cancel (not lag), so the icon's
        in-flight fallback stops overriding it. Reset to false on every new cast.
    ]]
	mirrorConfirmedCast = false,
	-- Locale key for why Farm Mode is idle, or nil, and the movement state it names. Written only by UpdateIcon.
	farmPauseReason = nil,
	farmPauseState = nil,
	-- The running Automatic Target Tracking hunt's spell, or nil. Never saved (see Target-Tracking.lua).
	huntSpellId = nil,
}

--[[
    Single write-site for the runtime-only lastCastSpell bookkeeping,
    written from UNIT_SPELLCAST_SUCCEEDED (and cleared on demand). Never
    persisted: last session's value treated as live bookkeeping makes the
    farm cycle and persistent recast believe tracking is already up at
    login and skip every real cast.
]]
function ns.SetLastCast(spellId)
	ns.state.lastCastSpell = spellId
	-- A freshly recorded cast is not yet mirror-confirmed; UpdateIcon flips this.
	ns.state.mirrorConfirmedCast = false
end

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------

--[[
    Single source of truth for the displayed icon: ns.GetActiveTrackingSpell()
    (see Utilities.lua). Never read MiniMapTrackingIcon or GetTrackingTexture
    directly here — a hidden frame keeps its last texture, and a raw read
    resurrects a cleared icon and re-poisons lastCastSpell via the adopt branch.
]]
function ns.UpdateIcon()
	local isCat = ns.GetPlayerStates()

	if not isCat and ns.CAT_FORM_ONLY[ns.state.lastCastSpell] then
		ns.SetLastCast(nil)
	end

	local activeSpell = ns.GetActiveTrackingSpell()
	if activeSpell and not ns.state.lastCastSpell then
		--[[
            Adopt tracking that predates this session (set up before the
            add-on loaded) — but ONLY while the session has no confirmed
            cast. In-session casts already update lastCastSpell via
            UNIT_SPELLCAST_SUCCEEDED, and the mirror lags that event on
            Era: adopting over fresh bookkeeping would corrupt the farm
            cycle's comparisons.
        ]]
		ns.SetLastCast(activeSpell)
	end

	--[[
        Once the mirror positively reports our own cast it has caught up, so a
        later nil reading is a genuine external cancel rather than lag. Latch
        that here so the in-flight fallback below stops re-showing the stale
        icon — this is what makes an external cancel resolve promptly instead of
        hanging on the old spell for the rest of the window.
    ]]
	if activeSpell and activeSpell == ns.state.lastCastSpell then
		ns.state.mirrorConfirmedCast = true
	end

	--[[
        The icon shows what the game is tracking; nothing tracked means the
        default icon. No fallback to saved or selected spells — those show a
        stale icon (e.g. last session's spell at login with nothing up). Only
        exception: for a few seconds after our own confirmed cast, and only
        until the mirror confirms it, show that spell while the icon catches up.
    ]]
	local iconSpell = activeSpell
	if
		not iconSpell
		and ns.state.lastCastSpell
		and not ns.state.mirrorConfirmedCast
		and (GetTime() - (ns.state.lastTrackingCastAt or 0)) < ns.ICON_IN_FLIGHT_SECONDS
	then
		iconSpell = ns.state.lastCastSpell
	end

	ns.state.currentIcon = iconSpell and C_Spell.GetSpellTexture(iconSpell) or ns.ICON_DEFAULT

	-- Cached so RunFarmLogic can tell when the reason changes and redraw an open tooltip.
	if ns.GetFarmPauseReason then
		ns.state.farmPauseReason, ns.state.farmPauseState = ns.GetFarmPauseReason()
	end

	if ns.ldb then
		ns.ldb.icon = ns.state.currentIcon
	end
	if ns.freeFrame and ns.freeFrame.icon then
		ns.freeFrame.icon:SetTexture(ns.state.currentIcon)
	end

	if ns.RefreshTooltip then
		ns.RefreshTooltip()
	end
end

function ns.ClearTracking()
	if ns.EndHunt then
		ns.EndHunt(false)
	end
	ns.SetLastCast(nil)
	if ns.db then
		ns.db.profile.selectedSpellId = nil
		-- The cycle can include this ability, so the cache is now stale.
		ns.InvalidateFarmCache()
	end
	ns.CancelActiveTracking()

	-- Force the default icon now: the cancel is async, so the mirror still reads the old texture for a frame.
	ns.state.currentIcon = ns.ICON_DEFAULT
	if ns.ldb then
		ns.ldb.icon = ns.ICON_DEFAULT
	end
	if ns.freeFrame and ns.freeFrame.icon then
		ns.freeFrame.icon:SetTexture(ns.ICON_DEFAULT)
	end
	if ns.RefreshTooltip then
		ns.RefreshTooltip()
	end
end

--------------------------------------------------------------------------------
-- Casting
--------------------------------------------------------------------------------

-- Returns true when a cast was actually attempted, false on every early bail.
function ns.CastTracking(spellId)
	if not spellId or not IsPlayerSpell(spellId) then
		return false
	end

	if ns.CAT_FORM_ONLY[spellId] then
		local isCat = ns.GetPlayerStates()
		if not isCat then
			return false
		end
	end

	--[[
        Treating "on GCD" as "on cooldown" is acceptable here (no real-cooldown
        vs GCD split): tracking casts are cheap refreshes, and every caller
        either retries (TryRecastPersistent) or re-fires on its next tick (the
        farm ticker), so a GCD-blocked attempt is never lost.
    ]]
	local start, duration = ns.GetSpellCooldown(spellId)
	if start and duration and start > 0 and duration > 0 then
		return false
	end

	--[[
        Do not write lastCastSpell or refresh the icon here — the cast
        can still fail silently (LOS, range, server reject). Let
        UNIT_SPELLCAST_SUCCEEDED be the single source of truth for a
        successful cast; otherwise the farm cycle and persistent recast
        would see a matching lastCastSpell and skip a real recast.
        lastTrackingCastAt is set on the attempt (not the success) so a
        burst of triggers can't hammer casts while one is in flight.
    ]]
	ns.state.lastTrackingCastAt = GetTime()
	pcall(CastSpellByID, spellId)
	return true
end

--------------------------------------------------------------------------------
-- Icon Pollers
--------------------------------------------------------------------------------

--[[
    Poll until the Blizzard minimap tracking icon has a texture, then
    refresh the icon once. During the Classic login event storm
    MiniMapTrackingIcon may not have its texture set yet, so every
    UpdateIcon call falls through to the default icon, and
    MINIMAP_UPDATE_TRACKING does not fire because tracking state
    hasn't changed — without this poll the icon stays stuck on
    default until the user toggles something.
]]
function ns.PollUntilTrackingReady(attempts)
	attempts = attempts or 0
	if MiniMapTrackingIcon and MiniMapTrackingIcon:GetTexture() then
		ns.UpdateIcon()
		return
	end
	if attempts >= 15 then
		return
	end
	C_Timer.After(1, function()
		ns.PollUntilTrackingReady(attempts + 1)
	end)
end

--[[
    Brief flush-poll after a tracking change. The Era tracking mirror can settle
    a beat or two after MINIMAP_UPDATE_TRACKING fires — sometimes without firing
    a second event — so re-run UpdateIcon a few times over ~2s to catch the
    flush the moment it happens instead of waiting for an unrelated buff tick.
    This cannot make the mirror fresher; it only shaves tail latency. Coalesced
    so a burst of tracking events can't stack overlapping polls.
]]
local iconFlushActive = false
function ns.FlushIconAfterTrackingChange()
	if iconFlushActive then
		return
	end
	iconFlushActive = true
	local attempts = 0
	local function tick()
		ns.UpdateIcon()
		attempts = attempts + 1
		if attempts >= 8 then
			iconFlushActive = false
			return
		end
		C_Timer.After(0.25, tick)
	end
	C_Timer.After(0.25, tick)
end
