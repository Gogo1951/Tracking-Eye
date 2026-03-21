local addonName, te = ...

--------------------------------------------------------------------------------
-- Options Panel (AceConfig-3.0)
--------------------------------------------------------------------------------

local AC  = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

te.optionsOpen = false

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local function Header(text, order)
    return {
        type  = "header",
        name  = te.GetColor("TITLE") .. text .. "|r",
        order = order
    }
end

local function Desc(text, order)
    return {
        type     = "description",
        name     = text,
        fontSize = "medium",
        order    = order
    }
end

local function SmallDesc(text, order)
    return {
        type     = "description",
        name     = text,
        fontSize = "small",
        order    = order
    }
end

local function Spacer(order)
    return {
        type  = "description",
        name  = " ",
        order = order
    }
end

local function SpellLabel(spellId, suffix)
    local name = te.GetSpellName(spellId) or "Unknown"
    local tex = GetSpellTexture(spellId) or te.ICON_DEFAULT
    local label = string.format("|T%s:16|t %s", tex, name)
    if suffix then
        label = label .. "  " .. te.GetColor("MUTED") .. suffix .. "|r"
    end
    return label
end

--------------------------------------------------------------------------------
-- Build Farm Ability Args
--------------------------------------------------------------------------------
local function BuildFarmAbilityArgs()
    local args = {}
    local order = 1

    -- Build sorted list: always-on first, then alphabetical
    local allSpells = {}
    for _, id in ipairs(te.TRACKING_IDS) do
        if id ~= te.SPELLS.DRUID_HUMANOIDS then
            local name = te.GetSpellName(id)
            if name then
                table.insert(allSpells, {id = id, name = name})
            end
        end
    end
    table.sort(allSpells, function(a, b)
        local aOn = te.FARM_ALWAYS_ON[a.id] and true or false
        local bOn = te.FARM_ALWAYS_ON[b.id] and true or false
        if aOn ~= bOn then return aOn end
        return a.name < b.name
    end)

    for _, data in ipairs(allSpells) do
        local id = data.id
        local isAlwaysOn = te.FARM_ALWAYS_ON[id]
        local key = "spell_" .. id

        if isAlwaysOn then
            args[key] = {
                type     = "toggle",
                name     = SpellLabel(id, te.L["OPTIONS_ALWAYS_ON"]),
                order    = order,
                width    = "full",
                disabled = true,
                get      = function() return true end,
                set      = function() end
            }
        else
            args[key] = {
                type   = "toggle",
                name   = SpellLabel(id),
                order  = order,
                width  = "full",
                hidden = function() return not IsPlayerSpell(id) end,
                get    = function()
                    return TrackingEyeDB and TrackingEyeDB.farmCycleSpells and
                        TrackingEyeDB.farmCycleSpells[id] or false
                end,
                set    = function(_, val)
                    if TrackingEyeDB and TrackingEyeDB.farmCycleSpells then
                        TrackingEyeDB.farmCycleSpells[id] = val or nil
                        te.InvalidateFarmCache()
                    end
                end
            }
        end
        order = order + 1
    end

    return args
end

--------------------------------------------------------------------------------
-- Options Table
--------------------------------------------------------------------------------
local function GetOptions()
    return {
        name = te.L["ADDON_TITLE"],
        type = "group",
        args = {

            -- Persistent Tracking
            headerPersistent = Header(te.L["PERSISTENT_TRACKING"], 10),
            descPersistent   = Desc(te.L["PERSISTENT_DESC"], 11),
            spacePT1         = Spacer(12),
            enablePersistent = {
                type  = "toggle",
                name  = te.L["OPTIONS_ENABLE_PERSISTENT"],
                order = 13,
                width = "full",
                get   = function() return TrackingEyeDB and TrackingEyeDB.autoTracking end,
                set   = function(_, val)
                    if TrackingEyeDB then TrackingEyeDB.autoTracking = val end
                end
            },

            -- Farm Mode
            headerFarm = Header(te.L["FARM_MODE"], 20),
            descFarm   = Desc(te.L["FARMING_DESC"], 21),
            spaceFM1   = Spacer(22),
            enableFarm = {
                type  = "toggle",
                name  = te.L["OPTIONS_ENABLE_FARM"],
                order = 23,
                width = "full",
                get   = function() return TrackingEyeDB and TrackingEyeDB.farmingMode end,
                set   = function(_, val)
                    if TrackingEyeDB then TrackingEyeDB.farmingMode = val end
                end
            },
            spaceFM2 = Spacer(24),

            -- Farm Mode Abilities (inline group)
            farmAbilities = {
                type   = "group",
                name   = te.GetColor("TITLE") .. te.L["OPTIONS_FARM_ABILITIES"] .. "|r",
                order  = 25,
                inline = true,
                args   = BuildFarmAbilityArgs()
            },
            spaceFM3 = Spacer(26),

            -- Cycle Speed
            headerCycleSpeed = {
                type     = "description",
                name     = "\n" .. te.GetColor("TITLE") .. te.L["OPTIONS_CYCLE_SPEED"] .. "|r",
                fontSize = "medium",
                order    = 27
            },
            descCycleSpeed = SmallDesc(te.L["OPTIONS_CYCLE_SPEED_DESC"], 28),
            cycleSpeed = {
                type = "range",
                name = "",
                order = 29,
                min  = 2,
                max  = 10,
                step = 0.5,
                get  = function()
                    return TrackingEyeDB and TrackingEyeDB.farmInterval or te.FARM_INTERVAL_DEFAULT
                end,
                set  = function(_, val)
                    if TrackingEyeDB then TrackingEyeDB.farmInterval = val end
                    te.RestartFarmTicker()
                end
            },

            -- Free Placement Mode
            headerFree = Header(te.L["PLACEMENT_MODE"], 40),
            descFree   = Desc(te.L["PLACEMENT_DESC"], 41),
            spaceFP1   = Spacer(42),
            enableFree = {
                type  = "toggle",
                name  = te.L["OPTIONS_ENABLE_FREE"],
                order = 43,
                width = "full",
                get   = function()
                    return TrackingEyeGlobalDB and TrackingEyeGlobalDB.freePlacement
                end,
                set   = function(_, val)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freePlacement = val
                        te.UpdatePlacement()
                    end
                end
            },
            spaceFP2 = Spacer(44),

            -- Icon Size
            headerIconSize = {
                type     = "description",
                name     = "\n" .. te.GetColor("TITLE") .. te.L["OPTIONS_ICON_SCALE"] .. "|r",
                fontSize = "medium",
                order    = 45
            },
            descIconSize = SmallDesc(te.L["OPTIONS_ICON_SCALE_DESC"], 46),
            iconScale = {
                type    = "range",
                name    = "",
                order   = 47,
                min     = 0.25,
                max     = 3.0,
                step    = 0.05,
                isPercent = true,
                get     = function()
                    return TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconScale or te.FREE_ICON_SCALE_DEFAULT
                end,
                set     = function(_, val)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freeIconScale = val
                    end
                    te.UpdateFreeFrameScale()
                end
            },
            spaceFP3 = Spacer(48),

            -- Icon Shape
            headerIconShape = {
                type     = "description",
                name     = "\n" .. te.GetColor("TITLE") .. te.L["OPTIONS_ICON_SHAPE"] .. "|r",
                fontSize = "medium",
                order    = 49
            },
            descIconShape = SmallDesc(te.L["OPTIONS_ICON_SHAPE_DESC"], 50),
            iconShape = {
                type   = "select",
                name   = "",
                order  = 51,
                style  = "dropdown",
                values = {
                    [te.SHAPES.CIRCLE] = te.L["OPTIONS_SHAPE_CIRCLE"],
                    [te.SHAPES.SQUARE] = te.L["OPTIONS_SHAPE_SQUARE"]
                },
                get    = function()
                    return TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconShape or te.FREE_ICON_SHAPE_DEFAULT
                end,
                set    = function(_, val)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freeIconShape = val
                    end
                    te.UpdateFreeFrameShape()
                end
            },

            -- Feedback & Support
            headerLinks = Header(te.L["OPTIONS_LINKS"], 60),
            spaceLinks1 = Spacer(61),
            discordLabel = {
                type     = "description",
                name     = te.GetColor("TITLE") .. te.L["OPTIONS_DISCORD"] .. "|r",
                fontSize = "medium",
                order    = 62
            },
            discordURL = {
                type  = "input",
                name  = "",
                order = 63,
                width = "double",
                get   = function() return te.DISCORD_URL end,
                set   = function() end
            },
            spaceLinks2 = Spacer(64),
            githubLabel = {
                type     = "description",
                name     = te.GetColor("TITLE") .. te.L["OPTIONS_GITHUB"] .. "|r",
                fontSize = "medium",
                order    = 65
            },
            githubURL = {
                type  = "input",
                name  = "",
                order = 66,
                width = "double",
                get   = function() return te.GITHUB_URL end,
                set   = function() end
            },
            spaceLinks3 = Spacer(67),

            -- Reset
            resetAll = {
                type    = "execute",
                name    = te.L["OPTIONS_RESET"],
                order   = 70,
                width   = "normal",
                confirm = true,
                confirmText = "Reset all Tracking Eye options to defaults?",
                func    = function()
                    if TrackingEyeDB then
                        TrackingEyeDB.autoTracking = true
                        TrackingEyeDB.farmingMode = true
                        TrackingEyeDB.farmInterval = te.FARM_INTERVAL_DEFAULT
                        TrackingEyeDB.selectedSpellId = nil
                        TrackingEyeDB.lastIcon = nil
                        TrackingEyeDB.farmCycleSpells = {}
                        for id, v in pairs(te.FARM_CYCLE_DEFAULTS) do
                            TrackingEyeDB.farmCycleSpells[id] = v
                        end
                    end
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freePlacement = false
                        TrackingEyeGlobalDB.freeIconScale = te.FREE_ICON_SCALE_DEFAULT
                        TrackingEyeGlobalDB.freeIconShape = te.FREE_ICON_SHAPE_DEFAULT
                    end
                    te.InvalidateFarmCache()
                    te.RestartFarmTicker()
                    te.UpdatePlacement()
                    te.UpdateFreeFrameScale()
                    te.UpdateFreeFrameShape()
                    te.UpdateIcon()
                end
            }
        }
    }
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------
local mainPanel

function te.InitOptions()
    AC:RegisterOptionsTable(addonName, GetOptions)
    mainPanel = ACD:AddToBlizOptions(addonName, te.L["ADDON_TITLE"])
end

function te.OpenOptions()
    if Settings and Settings.GetCategory then
        local category = Settings.GetCategory(te.L["ADDON_TITLE"])
        if category then
            Settings.OpenToCategory(category.ID)
            return
        end
    end
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(mainPanel)
        InterfaceOptionsFrame_OpenToCategory(mainPanel)
        return
    end
    ACD:Open(addonName)
end
