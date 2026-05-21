local addonName, ns = ...

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
        name = ns.GetColor("TITLE") .. text .. "|r",
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


local function SpellLabel(spellId, suffix)
    local name = GetSpellInfo(spellId) or "Unknown"
    local texture = GetSpellTexture(spellId) or ns.ICON_DEFAULT
    local label = string.format("|T%s:16|t %s", texture, name)
    if suffix then
        label = label .. "  " .. ns.GetColor("MUTED") .. suffix .. "|r"
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
    for _, id in ipairs(ns.TRACKING_IDS) do
        if id ~= ns.SPELLS.DRUID_HUMANOIDS then
            local name = GetSpellInfo(id)
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
                    ns.InvalidateFarmCache()
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
        name = ns.L["ADDON_TITLE"],
        type = "group",
        args = {

            -- Brief Description
            descIntro = Desc(ns.L["OPTIONS_DESC"], 1),

            -- Welcome Message
            spaceWelcome0 = Spacer(2),
            enableWelcome = {
                type = "toggle",
                name = ns.L["OPTIONS_ENABLE_WELCOME"],
                desc = ns.L["OPTIONS_WELCOME_DESC"],
                order = 3,
                width = "full",
                get = function() return TrackingEyeDB and TrackingEyeDB.showWelcome end,
                set = function(_, value)
                    if TrackingEyeDB then TrackingEyeDB.showWelcome = value end
                end
            },

            -- /Commands
            spaceCommands0 = Spacer(4),
            headerCommands = Header("/Commands", 5),
            spaceCommands1 = Spacer(6),
            descCommandsIntro = Desc(ns.L["OPTIONS_COMMANDS_INTRO"], 7),
            spaceCommands2 = Spacer(7.1),
            descCommandTE = Desc(
                ns.GetColor("INFO") .. "/te|r" .. "  " .. ns.L["OPTIONS_COMMAND_TE"],
                7.2
            ),
            spaceCommands3 = Spacer(7.3),
            descCommandTrackingEye = Desc(
                ns.GetColor("INFO") .. "/trackingeye|r" .. "  " .. ns.L["OPTIONS_COMMAND_TE"],
                7.4
            ),

            -- Persistent Tracking
            spacePT0 = Spacer(9),
            headerPersistent = Header(ns.L["PERSISTENT_TRACKING"], 10),
            spacePT1 = Spacer(12),
            enablePersistent = {
                type = "toggle",
                name = ns.L["OPTIONS_ENABLE_PERSISTENT"],
                desc = ns.L["PERSISTENT_DESC"],
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
                hidden = function() return not ns.HasTrackingAbility() end
            },
            headerFarm = {
                type = "header",
                name = ns.GetColor("TITLE") .. ns.L["FARM_MODE"] .. "|r",
                order = 20,
                hidden = function() return not ns.HasTrackingAbility() end
            },
            spaceFM1 = {
                type = "description",
                name = " ",
                order = 22,
                hidden = function() return not ns.HasTrackingAbility() end
            },
            enableFarm = {
                type = "toggle",
                name = ns.L["OPTIONS_ENABLE_FARM"],
                desc = ns.L["FARMING_DESC"],
                order = 23,
                width = "full",
                hidden = function() return not ns.HasTrackingAbility() end,
                get = function() return TrackingEyeCharDB and TrackingEyeCharDB.farmingMode end,
                set = function(_, value)
                    if TrackingEyeCharDB then TrackingEyeCharDB.farmingMode = value end
                end
            },
            spaceFM2 = {
                type = "description",
                name = " ",
                order = 24,
                hidden = function() return not ns.HasTrackingAbility() end
            },

            -- Farm Mode Abilities (inline group)
            farmAbilities = {
                type = "group",
                name = ns.GetColor("TITLE") .. ns.L["OPTIONS_FARM_ABILITIES"] .. "|r",
                order = 25,
                inline = true,
                hidden = function() return not ns.HasTrackingAbility() end,
                args = BuildFarmAbilityArgs()
            },
            spaceFM3 = {
                type = "description",
                name = " ",
                order = 26,
                hidden = function() return not ns.HasTrackingAbility() end
            },

            -- Cycle Speed
            cycleSpeed = {
                type = "range",
                name = ns.L["OPTIONS_CYCLE_SPEED"],
                desc = ns.L["OPTIONS_CYCLE_SPEED_DESC"],
                order = 29,
                width = "double",
                min = 2,
                max = 10,
                step = 0.5,
                hidden = function() return not ns.HasTrackingAbility() end,
                get = function()
                    return TrackingEyeCharDB and TrackingEyeCharDB.farmInterval or ns.CHAR_DEFAULTS.farmInterval
                end,
                set = function(_, value)
                    if TrackingEyeCharDB then TrackingEyeCharDB.farmInterval = value end
                    ns.RestartFarmTicker()
                end
            },

            -- Free Placement Mode
            spaceFP0 = Spacer(39),
            headerFree = Header(ns.L["PLACEMENT_MODE"], 40),
            spaceFP1 = Spacer(42),
            enableFree = {
                type = "toggle",
                name = ns.L["OPTIONS_ENABLE_FREE"],
                desc = ns.L["PLACEMENT_DESC"],
                order = 43,
                width = "full",
                get = function()
                    return TrackingEyeDB and TrackingEyeDB.freePlacement
                end,
                set = function(_, value)
                    if TrackingEyeDB then
                        TrackingEyeDB.freePlacement = value
                        ns.UpdatePlacement()
                    end
                end
            },
            spaceFP2 = Spacer(44),

            -- Icon Size
            iconScale = {
                type = "range",
                name = ns.L["OPTIONS_ICON_SCALE"],
                desc = ns.L["OPTIONS_ICON_SCALE_DESC"],
                order = 47,
                width = "double",
                min = 0.25,
                max = 3.0,
                step = 0.05,
                isPercent = true,
                get = function()
                    return TrackingEyeDB and TrackingEyeDB.freeIconScale or ns.GLOBAL_DEFAULTS.freeIconScale
                end,
                set = function(_, value)
                    if TrackingEyeDB then
                        TrackingEyeDB.freeIconScale = value
                    end
                    ns.UpdateFreeFrameScale()
                end
            },
            spaceFP3 = Spacer(48),

            -- Icon Shape
            iconShape = {
                type = "select",
                name = ns.L["OPTIONS_ICON_SHAPE"],
                desc = ns.L["OPTIONS_ICON_SHAPE_DESC"],
                order = 51,
                style = "dropdown",
                values = {
                    [ns.SHAPES.CIRCLE] = ns.L["OPTIONS_SHAPE_CIRCLE"],
                    [ns.SHAPES.SQUARE] = ns.L["OPTIONS_SHAPE_SQUARE"]
                },
                get = function()
                    return TrackingEyeDB and TrackingEyeDB.freeIconShape or ns.GLOBAL_DEFAULTS.freeIconShape
                end,
                set = function(_, value)
                    if TrackingEyeDB then
                        TrackingEyeDB.freeIconShape = value
                    end
                    ns.UpdateFreeFrameShape()
                end
            },

            -- Reset
            spaceReset0 = Spacer(59),
            headerReset = Header(ns.L["OPTIONS_RESET_HEADER"], 60),
            descReset = Desc(ns.L["OPTIONS_RESET_DESC"], 60.5),
            spaceReset1 = Spacer(61),
            resetAll = {
                type = "execute",
                name = ns.L["OPTIONS_RESET"],
                order = 62,
                width = "double",
                confirm = true,
                confirmText = ns.L["OPTIONS_RESET_CONFIRM"],
                func = function()
                    if TrackingEyeCharDB then
                        for k, v in pairs(ns.CHAR_DEFAULTS) do
                            TrackingEyeCharDB[k] = v
                        end
                        TrackingEyeCharDB.selectedSpellId = nil
                        TrackingEyeCharDB.farmCycleSpells = {}
                        for id, enabled in pairs(ns.FARM_CYCLE_DEFAULTS) do
                            TrackingEyeCharDB.farmCycleSpells[id] = enabled
                        end
                    end
                    if TrackingEyeDB then
                        for k, v in pairs(ns.GLOBAL_DEFAULTS) do
                            TrackingEyeDB[k] = v
                        end
                        --[[
                            Clear free-placement layout state. freePos is
                            wiped so the icon snaps back to center; the
                            minimap table is wiped in place so LibDBIcon
                            (which holds a reference to it) sees the
                            cleared angle / hide state.
                        ]]
                        TrackingEyeDB.freePos = nil
                        if TrackingEyeDB.minimap then
                            wipe(TrackingEyeDB.minimap)
                        else
                            TrackingEyeDB.minimap = {}
                        end
                        --[[
                            Bump the account-wide resetGeneration so every
                            other character wipes its per-character DB on
                            its next login. Sync this character now so it
                            doesn't re-wipe on the next reload.
                        ]]
                        TrackingEyeDB.resetGeneration = (TrackingEyeDB.resetGeneration or 0) + 1
                        if TrackingEyeCharDB then
                            TrackingEyeCharDB.resetGeneration = TrackingEyeDB.resetGeneration
                        end
                    end
                    -- Snap the free frame back to center immediately.
                    if ns.freeFrame then
                        ns.freeFrame:ClearAllPoints()
                        ns.freeFrame:SetPoint("CENTER")
                    end
                    ns.InvalidateFarmCache()
                    ns.RestartFarmTicker()
                    ns.UpdatePlacement()
                    ns.UpdateFreeFrameScale()
                    ns.UpdateFreeFrameShape()
                    ns.UpdateIcon()
                end
            },

            -- Feedback & Support
            spaceLinks0 = Spacer(69),
            headerLinks = Header(ns.L["OPTIONS_LINKS"], 70),
            spaceLinks1 = Spacer(71),
            curseforgeLabel = Desc(ns.GetColor("TITLE") .. ns.L["OPTIONS_CURSEFORGE"] .. "|r", 72),
            curseforgeURL = {
                type = "input",
                name = "",
                order = 73,
                width = "double",
                get = function() return ns.CURSEFORGE_URL end,
                set = function() end
            },
            spaceLinks2 = Spacer(74),
            githubLabel = Desc(ns.GetColor("TITLE") .. ns.L["OPTIONS_GITHUB"] .. "|r", 75),
            githubURL = {
                type = "input",
                name = "",
                order = 76,
                width = "double",
                get = function() return ns.GITHUB_URL end,
                set = function() end
            },
            spaceLinks3 = Spacer(77),
            discordLabel = Desc(ns.GetColor("TITLE") .. ns.L["OPTIONS_DISCORD"] .. "|r", 78),
            discordURL = {
                type = "input",
                name = "",
                order = 79,
                width = "double",
                get = function() return ns.DISCORD_URL end,
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
                name = ns.GetColor("MUTED") .. "Version " .. ns.Version .. "|r",
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
    ns.OpenOptions()
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------
local mainPanel

function ns.InitOptions()
    AC:RegisterOptionsTable(addonName, GetOptions)
    mainPanel = ACD:AddToBlizOptions(addonName, ns.L["ADDON_TITLE"])

    -- Pause Farm Mode while options panel is visible
    if mainPanel then
        mainPanel:HookScript("OnShow", function()
            ns.optionsOpen = true
        end)
        mainPanel:HookScript("OnHide", function()
            ns.optionsOpen = false
        end)
    end
end

function ns.OpenOptions()
    if Settings and Settings.GetCategory then
        local category = Settings.GetCategory(ns.L["ADDON_TITLE"])
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
