local _, ns = ...

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
    The AceDB-3.0 defaults table. profile holds the per-character tracking,
    Farm Mode, and Come & Get It settings — each character owns its profile
    (see Core.lua), so a hunter and a priest never share a persistent tracking
    ability. global holds the account-wide presentation, identical on every
    character. freePos has no default: it is written on drag and at logout while
    the free frame is shown.

    selectedSpellId is intentionally absent: it is nil until the user picks a
    tracking ability, and nil cannot be stored as a default. farmCycleSpells is a
    settings map, not a re-seedable list — AceDB copies its concrete defaults with
    rawset, so the map iterates correctly for new users, and a user who turns
    every entry off keeps that state across logins. Its defaults are the flavor
    data's ns.FARM_CYCLE_DEFAULTS (Data/{Game}/Spells-{Game}.lua).
]]
ns.DATABASE_DEFAULTS = {
	profile = {
		persistentTracking = true,
		-- Opt-in: inside a battleground or an arena, Track Humanoids stands in for the Persistent Tracking Ability.
		battlegroundHumanoids = false,
		-- Opt-in: in Cat Form, Druid Track Humanoids stands in for the Persistent Tracking Ability.
		catFormHumanoids = false,
		-- On by default: a fishing pole in the main hand is a clear sign the player is fishing.
		fishingPoleFish = true,
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
		farmPack = false,
		farmGhostWolf = true,
		farmNotMounted = false,
		farmCycleSpells = ns.FARM_CYCLE_DEFAULTS,
		-- On by default: the ability the player picked belongs in the rotation.
		farmIncludePersistent = true,
		-- Opt-in: out in the world, the kind of creature you target stands in for the Persistent Tracking Ability.
		targetTracking = false,
		-- On by default: the cycle's repeated cast sound is the add-on's own noise.
		muteCycleSound = true,
		-- On by default: it only drafts a chat line, and nothing is sent until the player presses Enter.
		comeAndGetIt = true,
		comeAndGetItOutput = ns.DEFAULT_OUTPUT_CHANNEL,
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
		-- On by default, and account-wide like the rest of the presentation: it zooms the client's own mini-map.
		farmZoomOut = true,
	},
}
