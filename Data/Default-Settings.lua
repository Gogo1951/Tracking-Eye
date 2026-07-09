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
    The single AceDB-3.0 defaults table. Every user setting lives under profile,
    so it follows the active profile and behaves account-wide on the shared
    Default profile. Only profile-independent placement data lives under global:
    the LibDBIcon minimap payload and the free-frame position (freePos, written
    only once the user drags, so it has no default entry here).

    selectedSpellId is intentionally absent: it is nil until the user picks a
    tracking ability, and nil cannot be stored as a default. farmCycleSpells is a
    settings map, not a re-seedable list — AceDB copies its concrete defaults with
    rawset, so the map iterates correctly for new users, and a user who turns
    every entry off (stored as explicit false) keeps that state across logins.
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
		-- UI placement and visual preferences.
		freePlacement = false,
		freeIconScale = 1.1,
		freeIconShape = ns.SHAPES.CIRCLE,
		showWelcome = true,
	},
	global = {
		minimap = {},
	},
}
