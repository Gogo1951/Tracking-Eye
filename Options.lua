local addonName, te = ...

--------------------------------------------------------------------------------
-- Options Panel (AceConfig-3.0)
--------------------------------------------------------------------------------

local AC = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local function Header(text, order)
    return {
        type = "header",
        name = te.GetColor("TITLE") .. text .. "|r",
        order = order
    }
end

local function Desc(text, order)
    return {
        type = "description",
        name = text,
        fontSize = "medium",
        order = order
    }
end

local function Spacer(order)
    return {
        type = "description",
        name = " ",
        order = order
    }
end

local function SubHeader(text, order)
    return {
        type = "description",
        name = "\n" .. te.GetColor("TITLE") .. text .. "|r",
        fontSize = "medium",
        order = order
    }
end

local function SpellLabel(spellId, suffix)
    local name = te.GetSpellName(spellId) or "Unknown"
    local texture = GetSpellTexture(spellId) or te.ICON_DEFAULT
    local label = string.format("|T%s:16|t %s", texture, name)
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

    -- Build sorted list alphabetically, exclude Druid Humanoids
    local allSpells = {}
    for _, id in ipairs(te.TRACKING_IDS) do
        if id ~= te.SPELLS.DRUID_HUMANOIDS then
            local name = te.GetSpellName(id)
            if name then
                table.insert(allSpells, {id = id, name = name})
            end
        end
    end
    table.sort(allSpells, function(a, b) return a.name < b.name end)

    for _, data in ipairs(allSpells) do
        local id = data.id
        local key = "spell_" .. id

        args[key] = {
            type = "toggle",
            name = SpellLabel(id),
            order = order,
            width = "full",
            hidden = function() return not IsPlayerSpell(id) end,
            get = function()
                return TrackingEyeCharDB and TrackingEyeCharDB.farmCycleSpells and
                    TrackingEyeCharDB.farmCycleSpells[id] or false
            end,
            set = function(_, value)
                if TrackingEyeCharDB and TrackingEyeCharDB.farmCycleSpells then
                    TrackingEyeCharDB.farmCycleSpells[id] = value or nil
                    te.InvalidateFarmCache()
                end
            end
        }
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

            -- Brief Description
            spacerIntro0 = Spacer(1),
            descIntro = Desc(te.L["OPTIONS_DESC"], 2),

            -- /Commands
            spaceCommands0 = Spacer(3),
            headerCommands = Header("/Commands", 4),
            spaceCommands1 = Spacer(5),
            descCommandsIntro = Desc(te.L["OPTIONS_COMMANDS_INTRO"], 6),
            spaceCommands2 = Spacer(6.1),
            descCommandTE = Desc(
                te.GetColor("INFO") .. "/te|r" .. "  " .. te.L["OPTIONS_COMMAND_TE"],
                6.2
            ),
            spaceCommands3 = Spacer(6.3),
            descCommandTrackingEye = Desc(
                te.GetColor("INFO") .. "/trackingeye|r" .. "  " .. te.L["OPTIONS_COMMAND_TE"],
                6.4
            ),

            -- General Settings
            spaceGeneral0 = Spacer(7),
            headerGeneral = Header(te.L["OPTIONS_GENERAL_SETTINGS"], 7.1),
            spaceGeneral1 = Spacer(7.2),
            enableWelcome = {
                type = "toggle",
                name = te.L["OPTIONS_ENABLE_WELCOME"],
                desc = te.L["OPTIONS_WELCOME_DESC"],
                order = 7.3,
                width = "full",
                get = function() return TrackingEyeCharDB and TrackingEyeCharDB.showWelcome end,
                set = function(_, value)
                    if TrackingEyeCharDB then TrackingEyeCharDB.showWelcome = value end
                end
            },

            -- Persistent Tracking
            spacePT0 = Spacer(9),
            headerPersistent = Header(te.L["PERSISTENT_TRACKING"], 10),
            spacePT1 = Spacer(12),
            enablePersistent = {
                type = "toggle",
                name = te.L["OPTIONS_ENABLE_PERSISTENT"],
                desc = te.L["PERSISTENT_DESC"],
                order = 13,
                width = "full",
                get = function() return TrackingEyeCharDB and TrackingEyeCharDB.autoTracking end,
                set = function(_, value)
                    if TrackingEyeCharDB then TrackingEyeCharDB.autoTracking = value end
                end
            },

            -- Farm Mode (entire section hidden when no tracking abilities are known)
            spaceFM0 = {
                type = "description",
                name = " ",
                order = 19,
                hidden = function() return not te.HasTrackingAbility() end
            },
            headerFarm = {
                type = "header",
                name = te.GetColor("TITLE") .. te.L["FARM_MODE"] .. "|r",
                order = 20,
                hidden = function() return not te.HasTrackingAbility() end
            },
            spaceFM1 = {
                type = "description",
                name = " ",
                order = 22,
                hidden = function() return not te.HasTrackingAbility() end
            },
            enableFarm = {
                type = "toggle",
                name = te.L["OPTIONS_ENABLE_FARM"],
                desc = te.L["FARMING_DESC"],
                order = 23,
                width = "full",
                hidden = function() return not te.HasTrackingAbility() end,
                get = function() return TrackingEyeCharDB and TrackingEyeCharDB.farmingMode end,
                set = function(_, value)
                    if TrackingEyeCharDB then TrackingEyeCharDB.farmingMode = value end
                end
            },
            spaceFM2 = {
                type = "description",
                name = " ",
                order = 24,
                hidden = function() return not te.HasTrackingAbility() end
            },

            -- Farm Mode Abilities (inline group)
            farmAbilities = {
                type = "group",
                name = te.GetColor("TITLE") .. te.L["OPTIONS_FARM_ABILITIES"] .. "|r",
                order = 25,
                inline = true,
                hidden = function() return not te.HasTrackingAbility() end,
                args = BuildFarmAbilityArgs()
            },
            spaceFM3 = {
                type = "description",
                name = " ",
                order = 26,
                hidden = function() return not te.HasTrackingAbility() end
            },

            -- Cycle Speed
            cycleSpeed = {
                type = "range",
                name = te.L["OPTIONS_CYCLE_SPEED"],
                desc = te.L["OPTIONS_CYCLE_SPEED_DESC"],
                order = 29,
                min = 2,
                max = 10,
                step = 0.5,
                hidden = function() return not te.HasTrackingAbility() end,
                get = function()
                    return TrackingEyeCharDB and TrackingEyeCharDB.farmInterval or te.CHAR_DEFAULTS.farmInterval
                end,
                set = function(_, value)
                    if TrackingEyeCharDB then TrackingEyeCharDB.farmInterval = value end
                    te.RestartFarmTicker()
                end
            },

            -- Free Placement Mode
            spaceFP0 = Spacer(39),
            headerFree = Header(te.L["PLACEMENT_MODE"], 40),
            spaceFP1 = Spacer(42),
            enableFree = {
                type = "toggle",
                name = te.L["OPTIONS_ENABLE_FREE"],
                desc = te.L["PLACEMENT_DESC"],
                order = 43,
                width = "full",
                get = function()
                    return TrackingEyeGlobalDB and TrackingEyeGlobalDB.freePlacement
                end,
                set = function(_, value)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freePlacement = value
                        te.UpdatePlacement()
                    end
                end
            },
            spaceFP2 = Spacer(44),

            -- Icon Size
            iconScale = {
                type = "range",
                name = te.L["OPTIONS_ICON_SCALE"],
                desc = te.L["OPTIONS_ICON_SCALE_DESC"],
                order = 47,
                min = 0.25,
                max = 3.0,
                step = 0.05,
                isPercent = true,
                get = function()
                    return TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconScale or te.GLOBAL_DEFAULTS.freeIconScale
                end,
                set = function(_, value)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freeIconScale = value
                    end
                    te.UpdateFreeFrameScale()
                end
            },
            spaceFP3 = Spacer(48),

            -- Icon Shape
            iconShape = {
                type = "select",
                name = te.L["OPTIONS_ICON_SHAPE"],
                desc = te.L["OPTIONS_ICON_SHAPE_DESC"],
                order = 51,
                style = "dropdown",
                values = {
                    [te.SHAPES.CIRCLE] = te.L["OPTIONS_SHAPE_CIRCLE"],
                    [te.SHAPES.SQUARE] = te.L["OPTIONS_SHAPE_SQUARE"]
                },
                get = function()
                    return TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconShape or te.GLOBAL_DEFAULTS.freeIconShape
                end,
                set = function(_, value)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freeIconShape = value
                    end
                    te.UpdateFreeFrameShape()
                end
            },

            -- Reset
            spaceReset0 = Spacer(59),
            headerReset = Header(te.L["OPTIONS_RESET_HEADER"], 60),
            spaceReset1 = Spacer(61),
            resetAll = {
                type = "execute",
                name = te.L["OPTIONS_RESET"],
                order = 62,
                width = "double",
                confirm = true,
                confirmText = te.L["OPTIONS_RESET_CONFIRM"],
                func = function()
                    if TrackingEyeCharDB then
                        for k, v in pairs(te.CHAR_DEFAULTS) do
                            TrackingEyeCharDB[k] = v
                        end
                        TrackingEyeCharDB.selectedSpellId = nil
                        TrackingEyeCharDB.lastIcon = nil
                        TrackingEyeCharDB.farmCycleSpells = {}
                        for id, enabled in pairs(te.FARM_CYCLE_DEFAULTS) do
                            TrackingEyeCharDB.farmCycleSpells[id] = enabled
                        end
                    end
                    if TrackingEyeGlobalDB then
                        for k, v in pairs(te.GLOBAL_DEFAULTS) do
                            TrackingEyeGlobalDB[k] = v
                        end
                    end
                    te.InvalidateFarmCache()
                    te.RestartFarmTicker()
                    te.UpdatePlacement()
                    te.UpdateFreeFrameScale()
                    te.UpdateFreeFrameShape()
                    te.UpdateIcon()
                end
            },

            -- Feedback & Support
            spaceLinks0 = Spacer(69),
            headerLinks = Header(te.L["OPTIONS_LINKS"], 70),
            spaceLinks1 = Spacer(71),
            curseforgeLabel = Desc(te.GetColor("TITLE") .. te.L["OPTIONS_CURSEFORGE"] .. "|r", 72),
            curseforgeURL = {
                type = "input",
                name = "",
                order = 73,
                width = "double",
                get = function() return te.CURSEFORGE_URL end,
                set = function() end
            },
            spaceLinks2 = Spacer(74),
            githubLabel = Desc(te.GetColor("TITLE") .. te.L["OPTIONS_GITHUB"] .. "|r", 75),
            githubURL = {
                type = "input",
                name = "",
                order = 76,
                width = "double",
                get = function() return te.GITHUB_URL end,
                set = function() end
            },
            spaceLinks3 = Spacer(77),
            discordLabel = Desc(te.GetColor("TITLE") .. te.L["OPTIONS_DISCORD"] .. "|r", 78),
            discordURL = {
                type = "input",
                name = "",
                order = 79,
                width = "double",
                get = function() return te.DISCORD_URL end,
                set = function() end
            },
            spaceVersion0 = {
                type = "description",
                name = " ",
                width = "full",
                order = 998
            },
            versionLine = {
                type = "description",
                name = te.GetColor("MUTED") .. "Version " .. te.Version .. "|r",
                fontSize = "medium",
                order = 999
            }
        }
    }
end

--------------------------------------------------------------------------------
-- Slash Command
--------------------------------------------------------------------------------
SLASH_TRACKINGEYE1 = "/te"
SLASH_TRACKINGEYE2 = "/trackingeye"
SlashCmdList["TRACKINGEYE"] = function()
    te.OpenOptions()
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------
local mainPanel

function te.InitOptions()
    AC:RegisterOptionsTable(addonName, GetOptions)
    mainPanel = ACD:AddToBlizOptions(addonName, te.L["ADDON_TITLE"])

    -- Pause Farm Mode while options panel is visible
    if mainPanel then
        mainPanel:HookScript("OnShow", function()
            te.optionsOpen = true
        end)
        mainPanel:HookScript("OnHide", function()
            te.optionsOpen = false
        end)
    end
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
