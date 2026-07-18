local _, ns = ...

--------------------------------------------------------------------------------
-- Farm Cycle Defaults
--------------------------------------------------------------------------------

-- Only Herbs and Minerals enabled by default; all others off.
ns.FARM_CYCLE_DEFAULTS = {
	[ns.SPELLS.HERBS] = true,
	[ns.SPELLS.MINERALS] = true,
}

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
    The AceDB-3.0 defaults table. profile holds the per-character tracking and
    Farm Mode settings — each character owns its profile (see Core.lua), so a
    hunter and a priest never share a persistent tracking ability. global holds
    the account-wide UI: the LibDBIcon minimap payload, the free-frame position
    (freePos, written only on drag, so no default here), the free-placement
    layout, and the login greeting — identical on every character.

    selectedSpellId is intentionally absent: it is nil until the user picks a
    tracking ability, and nil cannot be stored as a default. farmCycleSpells is a
    settings map, not a re-seedable list — AceDB copies its concrete defaults with
    rawset, so the map iterates correctly for new users, and a user who turns
    every entry off keeps that state across logins.
]]
ns.DATABASE_DEFAULTS = {
	profile = {
		persistentTracking = true,
		farmMode = true,
		farmInterval = 3.5,
		-- Movement states that activate Farm Mode (farmNotMounted off by default).
		farmMounted = true,
		farmTravelForms = true,
		farmCheetah = true,
		farmGhostWolf = true,
		farmNotMounted = false,
		farmCycleSpells = ns.FARM_CYCLE_DEFAULTS,
	},
	global = {
		minimap = {},
		-- Account-wide UI: free-placement layout and the login greeting stay identical on every character.
		freePlacement = false,
		freeIconScale = 1.1,
		freeIconShape = ns.SHAPES.CIRCLE,
		showWelcome = true,
	},
}
