local _, ns = ...

--------------------------------------------------------------------------------
-- Default Values
--------------------------------------------------------------------------------

--[[
    Per-character settings (TrackingEyeCharDB). Feature toggles and behaviors
    that belong to the individual character: persistent tracking, Farm Mode, the
    Farm Mode cycle interval, and which movement states activate Farm Mode.
    selectedSpellId, lastCastSpell, and farmCycleSpells are intentionally absent
    here — nil cannot be stored in a Lua table, and farmCycleSpells is a nested
    table deep-copied on each init/reset (see ns.FARM_CYCLE_DEFAULTS below).
]]
ns.CHAR_DEFAULTS = {
    persistentTracking = true,
    farmMode = true,
    farmInterval = 3.5,
    -- Movement states that activate Farm Mode (farmNotMounted off by default).
    farmMounted = true,
    farmTravelForms = true,
    farmCheetah = true,
    farmGhostWolf = true,
    farmNotMounted = false
}

--[[
    Account-wide settings (TrackingEyeDB). UI placement and visual preferences
    shared across every character: Free Placement Mode with its icon scale and
    shape, plus the welcome message. The minimap button's position and hide flag
    live in the LibDBIcon `minimap` subtable and freePos holds the free-frame
    position — both account-wide as well, and both intentionally absent here
    (minimap is initialized as an empty table separately; freePos is written only
    once the user drags the frame).
]]
ns.GLOBAL_DEFAULTS = {
    freePlacement = false,
    freeIconScale = 1.1,
    freeIconShape = ns.SHAPES.CIRCLE,
    showWelcome = true
}

--------------------------------------------------------------------------------
-- Farm Cycle Defaults
--------------------------------------------------------------------------------

-- Only Herbs and Minerals enabled by default; all others off
ns.FARM_CYCLE_DEFAULTS = {
    [ns.SPELLS.HERBS] = true,
    [ns.SPELLS.MINERALS] = true
}
