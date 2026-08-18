local _, ns = ...

--------------------------------------------------------------------------------
-- Farm Cycle Defaults
--------------------------------------------------------------------------------

--[[
    The gathering trio is on by default; every other tracking ability is off.
    Find Treasure is a Dwarf racial, so it only ever reaches the cycle on a
    character that knows it — BuildCycleCache requires IsPlayerSpell, and the
    options toggle hides itself the same way.
]]
ns.FARM_CYCLE_DEFAULTS = {
	[ns.SPELLS.HERBS] = true,
	[ns.SPELLS.MINERALS] = true,
	[ns.SPELLS.TREASURE] = true,
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
		--[[
			Movement states that activate Farm Mode. Aspect of the Cheetah and
			Pack are off by default: they are combat and travel utility a hunter
			flips on constantly, so cycling off the back of them fires the tracking
			casts well outside actual farming.
		]]
		farmMounted = true,
		farmTravelForms = true,
		farmCheetah = false,
		farmGhostWolf = true,
		farmNotMounted = false,
		farmCycleSpells = ns.FARM_CYCLE_DEFAULTS,
		-- On by default: the ability the player picked belongs in the rotation.
		farmIncludePersistent = true,
		-- Opt-in: borrows the tracking slot to match the creature you target.
		targetTracking = false,
		-- On by default: the cycle's repeated cast sound is the add-on's own noise.
		muteCycleSound = true,
	},
	global = {
		minimap = {},
		-- Account-wide UI: free-placement layout and the login greeting stay identical on every character.
		freePlacement = false,
		freeIconScale = 1.1,
		freeIconShape = ns.SHAPES.CIRCLE,
		showWelcome = true,
		-- Opt-in: takes over Blizzard's own mini-map tracking button to open our menu.
		hookBlizzardTracking = false,
	},
}
