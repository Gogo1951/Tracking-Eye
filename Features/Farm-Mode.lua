local _, ns = ...

--------------------------------------------------------------------------------
-- Farm Mode
--------------------------------------------------------------------------------

local farmIndex = 0
local cachedCycle = nil
-- The Cat Form state cachedCycle was built for; see BuildCycleCache.
local cachedForCat = nil
local farmTicker = nil

--------------------------------------------------------------------------------
-- Farm Cycle Cache
--------------------------------------------------------------------------------

local function IsInCatForm()
	return (ns.GetPlayerStates()) and true or false
end

--[[
    The druid's tracking (ns.CAT_FORM_ONLY) can only be cast in Cat Form, so it
    joins the rotation only while the player is in it. Cat Form counts as on
    foot, so in practice that is a druid farming with Not Mounted ticked; in
    Travel Form the rest of the cycle runs without it. The cache records the Cat
    Form state it was built for, and EnsureCycleCache rebuilds it when that
    changes.
]]
local function BuildCycleCache()
	cachedCycle = {}
	local isCat = IsInCatForm()
	cachedForCat = isCat
	local db = ns.db and ns.db.profile
	if not db then
		return
	end

	local function CanCycle(id)
		return IsPlayerSpell(id) and (not ns.CAT_FORM_ONLY[id] or isCat)
	end

	local inCycle = {}
	local spells = db.farmCycleSpells
	if spells then
		for id, enabled in pairs(spells) do
			if enabled and CanCycle(id) then
				inCycle[id] = true
				table.insert(cachedCycle, id)
			end
		end
	end

	--[[
        The Persistent Tracking ability joins the rotation when the option is on,
        but only ONCE: picking Find Herbs as the persistent ability while Find
        Herbs is already ticked in the list must not queue it twice, which would
        hand it double the airtime of everything else in the cycle. The entry
        holds whatever ns.GetPersistentSpell resolves to, so a running Target
        Tracking hunt takes the player's pick's place.
    ]]
	local selected = ns.GetPersistentSpell()
	if db.farmIncludePersistent and selected and not inCycle[selected] and CanCycle(selected) then
		table.insert(cachedCycle, selected)
	end

	table.sort(cachedCycle)
end

local function EnsureCycleCache()
	if not cachedCycle or cachedForCat ~= IsInCatForm() then
		BuildCycleCache()
	end
end

function ns.InvalidateFarmCache()
	cachedCycle = nil
end

-- Single reader of the cycle's size, so nothing else has to know about the cache.
function ns.GetFarmCycleCount()
	EnsureCycleCache()
	return #cachedCycle
end

-- A copy of the cycle as Farm Mode casts it, for Diagnostics; never the live cache.
function ns.GetFarmCycle()
	EnsureCycleCache()
	local copy = {}
	for index, spellId in ipairs(cachedCycle) do
		copy[index] = spellId
	end
	return copy
end

--[[
    Why the cycle is empty, for the two places that explain it: the tooltip's
    pause reason and the key binding's chat line. "none" means nothing is picked;
    "catForm" means the only picked abilities this character knows are the
    druid's Cat Form tracking, outside Cat Form; "unlearned" means nothing picked
    is known yet (Find Herbs ticked, but no Herbalism). Only meaningful while the
    cycle is empty.
]]
function ns.GetEmptyCycleKind()
	local db = ns.db and ns.db.profile
	if not db then
		return "none"
	end

	local picked, knowsCatOnly = false, false
	local function Consider(id)
		picked = true
		if ns.CAT_FORM_ONLY[id] and IsPlayerSpell(id) then
			knowsCatOnly = true
		end
	end

	local spells = db.farmCycleSpells
	if spells then
		for id, enabled in pairs(spells) do
			if enabled then
				Consider(id)
			end
		end
	end
	local persistent = ns.GetPersistentSpell()
	if db.farmIncludePersistent and persistent then
		Consider(persistent)
	end

	if not picked then
		return "none"
	end
	return knowsCatOnly and "catForm" or "unlearned"
end

--------------------------------------------------------------------------------
-- Farm Cycle Logic
--------------------------------------------------------------------------------

--[[
    One attempt at the form-leave restore, made once per farm tick. Returns true
    once nothing is left to do: the ability was cast, is provably up already, or
    can never be cast from here. Returns false for a temporary refusal (the
    all-clear, a cooldown, the GCD), so the caller keeps wasFarming set and the
    next tick tries again instead of dropping the restore.
]]
local function RestoreAfterFarming()
	local spellId = ns.GetPersistentSpell()
	if not ns.db.profile.persistentTracking or not spellId or not IsPlayerSpell(spellId) then
		return true
	end
	if ns.CAT_FORM_ONLY[spellId] and not ns.GetPlayerStates() then
		return true
	end

	-- Positive signal only: a nil mirror never counts as "already up".
	if ns.GetActiveTrackingSpell() == spellId then
		return true
	end
	local inFlight = ns.state.lastCastSpell == spellId
		and (GetTime() - (ns.state.lastTrackingCastAt or 0)) < ns.CAST_IN_FLIGHT_SECONDS
	if inFlight then
		return true
	end

	if not ns.CanCast() then
		return false
	end
	return ns.CastTracking(spellId)
end

--[[
    Zoom Mini-map Out: as each Farm Mode run starts, the mini-map zooms all the
    way out, and the player's own zoom is never put back. Blizzard's own zoom
    clicks set the zoom buttons themselves after Minimap:SetZoom, so this does the
    same: Era and TBC name them MinimapZoomIn and MinimapZoomOut, and WoW Forever
    hangs them off the mini-map.
]]
local function ZoomMinimapOutForRun()
	if not (ns.db and ns.db.global.farmZoomOut) or Minimap:GetZoom() == 0 then
		return
	end
	Minimap:SetZoom(0)
	local zoomIn = Minimap.ZoomIn or MinimapZoomIn
	local zoomOut = Minimap.ZoomOut or MinimapZoomOut
	if zoomIn then
		zoomIn:Enable()
	end
	if zoomOut then
		zoomOut:Disable()
	end
end

--[[
    Avoids raw GetTrackingTexture comparisons: the Era mirror lags real state by
    up to minutes, so it's consulted only as positive confirmation, never as a
    gate. The cycle compares against ns.state.lastCastSpell (written only from
    UNIT_SPELLCAST_SUCCEEDED), reliable on every client. Recasting an active
    spell is a harmless refresh, so the check only avoids burning a GCD on a no-op.
]]
function ns.RunFarmLogic()
	if ns.HandleFlightState then
		ns.HandleFlightState()
	end

	--[[
        Keep an open tooltip's Farm Mode Status honest before any bail. The ticker
        is the only thing that notices conditions firing no registered event — a
        taxi flight above all — so the pause reason is re-resolved here and the
        display refreshed only when it actually changed.
    ]]
	if ns.GetFarmPauseReason() ~= ns.state.farmPauseReason then
		ns.UpdateIcon()
	end

	if ns.IsOptionsPanelOpen and ns.IsOptionsPanelOpen() then
		return
	end

	-- Hold while any window is open, something attackable is targeted, or any tooltip shows, ours included.
	if ns.IsBlockingWindowOpen() or ns.HasAttackableTarget() or ns.IsTooltipShowing() or ns.IsOwnTooltipShowing() then
		return
	end

	if not ns.db then
		return
	end

	local _, inForm = ns.GetPlayerStates()

	--[[
        Nothing below runs while the player stands still, the form-leave restore
        included: standing still is when a player eats, drinks, gathers, or reads,
        and a cast then stands them up or costs a global cooldown for nothing.
    ]]
	if not ns.IsPlayerMoving() then
		return
	end

	--[[
        Form-leave restore. It runs ahead of the Farm Mode and restricted-zone
        gates, so switching Farm Mode off mid-farm, or unmounting inside an
        instance or a resting area, still brings the persistent ability back.
        wasFarming stays set until RestoreAfterFarming reports the job done, so
        a tick refused by the all-clear retries on the next one. Bookkeeping
        alone (lastCastSpell) cannot see tracking cancelled outside the add-on.
    ]]
	if not inForm and ns.state.wasFarming then
		if RestoreAfterFarming() then
			ns.state.wasFarming = false
		end
		return
	end

	if not ns.db.profile.farmMode then
		return
	end

	if ns.IsRestrictedZone() then
		return
	end

	if not inForm or not ns.CanCast() then
		return
	end

	EnsureCycleCache()

	if #cachedCycle == 0 then
		return
	end

	-- Only as a run starts, so a player who zooms back in mid-run keeps their choice.
	if not ns.state.wasFarming then
		ZoomMinimapOutForRun()
	end

	if #cachedCycle == 1 then
		local spellId = cachedCycle[1]

		--[[
            Idle only while the spell is provably active (Blizzard icon /
            mirror via ns.GetActiveTrackingSpell) or our own cast is still
            in flight (the icon can lag the UNIT_SPELLCAST_SUCCEEDED by a
            moment). Anything else — including tracking cancelled outside
            the add-on, which bookkeeping alone cannot see — recasts.
        ]]
		if ns.GetActiveTrackingSpell() ~= spellId then
			local inFlight = ns.state.lastCastSpell == spellId
				and (GetTime() - (ns.state.lastTrackingCastAt or 0)) < ns.CAST_IN_FLIGHT_SECONDS
			if not inFlight then
				ns.CastCycleSpell(spellId)
			end
		end
		ns.state.wasFarming = true
		return
	end

	ns.AdvanceFarmCycle()

	ns.state.wasFarming = true
end

--------------------------------------------------------------------------------
-- Manual Cycle Advance
--------------------------------------------------------------------------------

--[[
    One step of the cycle, shared by the farm ticker and the key binding so there
    is a single advance path. Returns true when the cycle advanced, which is not
    the same as having cast: an entry that already matches ns.state.lastCastSpell
    is skipped rather than recast. It honors ns.CanCast itself, so the manual
    binding obeys the same guards as the automatic cycle (combat, an open loot
    window, a loaded cursor). A one-entry cycle recasts that entry: pressing the
    key must always do something visible.
]]
function ns.AdvanceFarmCycle()
	EnsureCycleCache()

	if #cachedCycle == 0 or not ns.CanCast() then
		return false
	end

	if #cachedCycle == 1 then
		ns.CastCycleSpell(cachedCycle[1])
		return true
	end

	farmIndex = (farmIndex % #cachedCycle) + 1
	local nextSpellId = cachedCycle[farmIndex]

	if nextSpellId ~= ns.state.lastCastSpell then
		ns.CastCycleSpell(nextSpellId)
	end

	return true
end

--------------------------------------------------------------------------------
-- Ticker Management
--------------------------------------------------------------------------------

function ns.RestartFarmTicker()
	if farmTicker then
		farmTicker:Cancel()
		farmTicker = nil
	end
	farmTicker = C_Timer.NewTicker(ns.db.profile.farmInterval, ns.RunFarmLogic)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitFarmMode()
	ns.RestartFarmTicker()
end
