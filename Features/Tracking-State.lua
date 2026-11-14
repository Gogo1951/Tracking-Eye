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
    Single write-site for the runtime-only lastCastSpell bookkeeping. Set from
    UNIT_SPELLCAST_SUCCEEDED, from UpdateIcon adopting tracking that predates the
    session, and from TryRecastPersistent syncing to a spell the mirror shows
    active; cleared by UpdateIcon and ClearTracking. Never
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
-- Reading and Clearing Tracking
--------------------------------------------------------------------------------

--[[
    Lazily built reverse lookup (texture -> spellId) so every call isn't a linear
    C_Spell.GetSpellTexture scan over ns.TRACKING_IDS. During the login event storm
    C_Spell.GetSpellTexture returns nil for spells whose data hasn't loaded, so a cache
    built then is missing entries and has to be rebuilt once more data arrives.

    Rebuilds are driven by a dirty flag, NOT by testing whether every ID resolved.
    An ID this client lacks never resolves, so a completeness test can stay false
    forever and rebuild the whole table on every lookup miss, which is most of
    them while nothing is tracked. SPELLS_CHANGED and PLAYER_ENTERING_WORLD are
    the only points where new spell data can appear, so they mark it dirty and the
    next lookup rebuilds exactly once.
]]
local textureToSpellId = nil
local textureCacheDirty = true

function ns.InvalidateTextureCache()
	textureCacheDirty = true
end

local function BuildTextureCache()
	textureToSpellId = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		local texture = C_Spell.GetSpellTexture(id)
		if texture then
			textureToSpellId[texture] = id
		end
	end
	textureCacheDirty = false
end

local function MatchTrackingTexture(texture)
	if not texture then
		return nil
	end
	if not textureToSpellId or textureCacheDirty then
		BuildTextureCache()
	end
	return textureToSpellId[texture]
end

--[[
    The tracking spell an active C_Minimap entry stands for, or nil. Only entries
    backed by one of this add-on's spells count, so a town service switched on in
    the minimap menu is never mistaken for tracking. A spell entry without a spell
    ID is matched by its texture instead.
]]
local function GetMinimapEntrySpell(index)
	local info = C_Minimap.GetTrackingInfo(index)
	if not info or not info.active then
		return nil
	end
	if info.spellID then
		return ns.TRACKING_SET[info.spellID] and info.spellID or nil
	end
	if info.type == "spell" then
		return MatchTrackingTexture(info.texture)
	end
	return nil
end

--[[
    Live "which tracking is up right now?" check, returning the active
    tracking spellId or nil. GetTrackingTexture alone cannot answer this:
    on Classic Era 1.15.x it returns nil for several active trackers
    (racials like Find Treasure) and lags state changes. The Blizzard
    minimap tracking icon is authoritative there — the Vanilla client
    hides it entirely when nothing is tracked, so it is only read while
    visible (a hidden frame can retain a stale texture). Falls back to
    GetTrackingTexture for clients where the icon shows a generic "None"
    texture instead (TBC+). WoW Forever ships neither the icon nor
    GetTrackingTexture and reads the C_Minimap tracking list instead.
]]
function ns.GetActiveTrackingSpell()
	if MiniMapTrackingIcon and MiniMapTrackingIcon:IsVisible() then
		local id = MatchTrackingTexture(MiniMapTrackingIcon:GetTexture())
		if id then
			return id
		end
	end
	if GetTrackingTexture then
		return MatchTrackingTexture(GetTrackingTexture())
	end
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local id = GetMinimapEntrySpell(index)
		if id then
			return id
		end
	end
	return nil
end

--[[
    Drops the add-on's tracking. CancelTrackingBuff covers Era and TBC. On WoW
    Forever every active entry backed by one of this add-on's spells is switched
    off, and any town service beside them is left alone. Never ClearAllTracking:
    it also clears Blizzard's own quest and target filters.
]]
function ns.CancelActiveTracking()
	if CancelTrackingBuff then
		CancelTrackingBuff()
		return
	end
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		if GetMinimapEntrySpell(index) then
			C_Minimap.SetTracking(index, false)
		end
	end
end

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------

--[[
    Single source of truth for the displayed icon: ns.GetActiveTrackingSpell()
    (above). Never read MiniMapTrackingIcon or GetTrackingTexture
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

	-- Cached so RunFarmLogic can tell when the reason changes and redraw an open menu.
	if ns.GetFarmPauseReason then
		ns.state.farmPauseReason, ns.state.farmPauseState = ns.GetFarmPauseReason()
	end

	--[[
	    The icon never dims while Farm Mode is paused: on foot is a pause by
	    default, so a dimmed icon read as the add-on switched off. The menu's
	    Farm Mode Status is the only place a pause shows.
	]]
	if ns.ldb then
		ns.ldb.icon = ns.state.currentIcon
	end
	if ns.freeFrame and ns.freeFrame.icon then
		ns.freeFrame.icon:SetTexture(ns.state.currentIcon)
	end

	if ns.RefreshMenu then
		ns.RefreshMenu()
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
	-- The picked ability is a saved setting, so options redraw along with the menu.
	ns.RefreshSettings()
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
