local addonName, te = ...

--------------------------------------------------------------------------------
-- Options Panel (AceConfig-3.0)
--------------------------------------------------------------------------------

local AC  = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

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

local function Spacer(order)
    return {
        type  = "description",
        name  = " ",
        order = order
    }
end

local function SubHeader(text, order)
    return {
        type     = "description",
        name     = "\n" .. te.GetColor("TITLE") .. text .. "|r",
        fontSize = "medium",
        order    = order
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
            type   = "toggle",
            name   = SpellLabel(id),
            order  = order,
            width  = "full",
            hidden = function() return not IsPlayerSpell(id) end,
            get    = function()
                return TrackingEyeDB and TrackingEyeDB.farmCycleSpells and
                    TrackingEyeDB.farmCycleSpells[id] or false
            end,
            set    = function(_, value)
                if TrackingEyeDB and TrackingEyeDB.farmCycleSpells then
                    TrackingEyeDB.farmCycleSpells[id] = value or nil
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
            descIntro    = Desc(te.L["OPTIONS_DESC"], 2),

            -- /Commands
            spaceCommands0 = Spacer(3),
            headerCommands = Header("/Commands", 4),
            spaceCommands1 = Spacer(5),
            descCommands = Desc(
                te.GetColor("INFO") .. "/te|r" .. "  Opens the Tracking Eye options interface.",
                6
            ),

            -- Persistent Tracking
            spacePT0         = Spacer(9),
            headerPersistent = Header(te.L["PERSISTENT_TRACKING"], 10),
            descPersistent   = Desc(te.L["PERSISTENT_DESC"], 11),
            spacePT1         = Spacer(12),
            enablePersistent = {
                type  = "toggle",
                name  = te.L["OPTIONS_ENABLE_PERSISTENT"],
                order = 13,
                width = "full",
                get   = function() return TrackingEyeDB and TrackingEyeDB.autoTracking end,
                set   = function(_, value)
                    if TrackingEyeDB then TrackingEyeDB.autoTracking = value end
                end
            },

            -- Farm Mode
            spaceFM0   = Spacer(19),
            headerFarm = Header(te.L["FARM_MODE"], 20),
            descFarm   = Desc(te.L["FARMING_DESC"], 21),
            spaceFM1   = Spacer(22),
            enableFarm = {
                type  = "toggle",
                name  = te.L["OPTIONS_ENABLE_FARM"],
                order = 23,
                width = "full",
                get   = function() return TrackingEyeDB and TrackingEyeDB.farmingMode end,
                set   = function(_, value)
                    if TrackingEyeDB then TrackingEyeDB.farmingMode = value end
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
            subCycleSpeed  = SubHeader(te.L["OPTIONS_CYCLE_SPEED"], 27),
            descCycleSpeed = Desc(te.L["OPTIONS_CYCLE_SPEED_DESC"], 28),
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
                set  = function(_, value)
                    if TrackingEyeDB then TrackingEyeDB.farmInterval = value end
                    te.RestartFarmTicker()
                end
            },

            -- Free Placement Mode
            spaceFP0   = Spacer(39),
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
                set   = function(_, value)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freePlacement = value
                        te.UpdatePlacement()
                    end
                end
            },
            spaceFP2 = Spacer(44),

            -- Icon Size
            subIconSize  = SubHeader(te.L["OPTIONS_ICON_SCALE"], 45),
            descIconSize = Desc(te.L["OPTIONS_ICON_SCALE_DESC"], 46),
            iconScale = {
                type      = "range",
                name      = "",
                order     = 47,
                min       = 0.25,
                max       = 3.0,
                step      = 0.05,
                isPercent = true,
                get       = function()
                    return TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconScale or te.FREE_ICON_SCALE_DEFAULT
                end,
                set       = function(_, value)
                    if TrackingEyeGlobalDB then
                        TrackingEyeGlobalDB.freeIconScale = value
                    end
                    te.UpdateFreeFrameScale()
                end
            },
            spaceFP3 = Spacer(48),

            -- Icon Shape
            subIconShape  = SubHeader(te.L["OPTIONS_ICON_SHAPE"], 49),
            descIconShape = Desc(te.L["OPTIONS_ICON_SHAPE_DESC"], 50),
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
                set    = function(_, value)
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
                type    = "execute",
                name    = te.L["OPTIONS_RESET"],
                order   = 62,
                width   = "normal",
                confirm = true,
                confirmText = te.L["OPTIONS_RESET_CONFIRM"],
                func    = function()
                    if TrackingEyeDB then
                        TrackingEyeDB.autoTracking = true
                        TrackingEyeDB.farmingMode = true
                        TrackingEyeDB.farmInterval = te.FARM_INTERVAL_DEFAULT
                        TrackingEyeDB.selectedSpellId = nil
                        TrackingEyeDB.lastIcon = nil
                        TrackingEyeDB.farmCycleSpells = {}
                        for id, enabled in pairs(te.FARM_CYCLE_DEFAULTS) do
                            TrackingEyeDB.farmCycleSpells[id] = enabled
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
            },

            -- Feedback & Support
            spaceLinks0      = Spacer(69),
            headerLinks      = Header(te.L["OPTIONS_LINKS"], 70),
            spaceLinks1      = Spacer(71),
            curseforgeLabel  = Desc(te.GetColor("TITLE") .. te.L["OPTIONS_CURSEFORGE"] .. "|r", 72),
            curseforgeURL = {
                type  = "input",
                name  = "",
                order = 73,
                width = "double",
                get   = function() return te.CURSEFORGE_URL end,
                set   = function() end
            },
            spaceLinks2  = Spacer(74),
            githubLabel  = Desc(te.GetColor("TITLE") .. te.L["OPTIONS_GITHUB"] .. "|r", 75),
            githubURL = {
                type  = "input",
                name  = "",
                order = 76,
                width = "double",
                get   = function() return te.GITHUB_URL end,
                set   = function() end
            },
            spaceLinks3  = Spacer(77),
            discordLabel = Desc(te.GetColor("TITLE") .. te.L["OPTIONS_DISCORD"] .. "|r", 78),
            discordURL = {
                type  = "input",
                name  = "",
                order = 79,
                width = "double",
                get   = function() return te.DISCORD_URL end,
                set   = function() end
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