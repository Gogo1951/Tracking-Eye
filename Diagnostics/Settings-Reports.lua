local ADDON_NAME, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Display Context
--------------------------------------------------------------------------------

--[[
    Answers "the mini-map button is gone / off-screen" reports: screen size, UI
    scale, the button's saved placement, and the free-placement icon that
    replaces it. Read-only.
]]
function ns:BuildDisplayContextReport()
	local lines = { GetClientHeader(), "" }

	local width, height = GetPhysicalScreenSize()
	lines[#lines + 1] = string.format("Physical screen size: %s x %s", tostring(width), tostring(height))
	lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent and UIParent:GetScale()))
	lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))

	lines[#lines + 1] = ""
	local LibDBIcon = LibStub("LibDBIcon-1.0")
	local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
	lines[#lines + 1] = string.format("Minimap button created: %s", button and "yes" or "no")

	local minimap = ns.db and ns.db.global.minimap
	if type(minimap) == "table" then
		lines[#lines + 1] = string.format("Minimap button hidden: %s", tostring(minimap.hide or false))
		lines[#lines + 1] = string.format("Minimap saved angle: %s", tostring(minimap.minimapPos))
	else
		lines[#lines + 1] = "Minimap saved position: (none yet)"
	end

	--[[
	    Where a dragged position lives, link by link: LibDBIcon's drag handler
	    computes the angle with math.atan2 every frame and writes it into the
	    button's db, which has to be the very table AceDB saves, and the raw
	    SavedVariables value is what the client writes at logout.
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("math.atan2 present: %s", tostring(type(math.atan2) == "function"))
	lines[#lines + 1] = string.format("LibDBIcon-1.0 minor: %s", tostring(LibStub.minors["LibDBIcon-1.0"]))
	if button then
		lines[#lines + 1] = string.format("Button db present: %s", tostring(button.db ~= nil))
		lines[#lines + 1] = string.format(
			"Button db is ns.db.global.minimap: %s",
			tostring(button.db ~= nil and minimap ~= nil and button.db == minimap)
		)
		lines[#lines + 1] = string.format("Button db.minimapPos: %s", tostring(button.db and button.db.minimapPos))
	end
	local saved = _G[ns.SAVED_VARIABLES_NAME]
	local savedGlobal = type(saved) == "table" and saved.global
	local savedMinimap = type(savedGlobal) == "table" and savedGlobal.minimap
	lines[#lines + 1] = string.format(
		"%s.global.minimap.minimapPos: %s",
		ns.SAVED_VARIABLES_NAME,
		tostring(type(savedMinimap) == "table" and savedMinimap.minimapPos or nil)
	)

	-- The free-placement icon, which stands in for the mini-map button while Free Placement Mode is on.
	lines[#lines + 1] = ""
	local global = ns.db and ns.db.global
	lines[#lines + 1] = string.format("freePlacement: %s", tostring(global and global.freePlacement))
	if global and type(global.freePos) == "table" then
		lines[#lines + 1] = string.format("freePos: x=%s y=%s", tostring(global.freePos.x), tostring(global.freePos.y))
	else
		lines[#lines + 1] = "freePos: (none)"
	end
	if ns.freeFrame then
		lines[#lines + 1] = string.format(
			"freeFrame shown: %s // scale: %s",
			tostring(ns.freeFrame:IsShown()),
			tostring(ns.freeFrame:GetScale())
		)
	else
		lines[#lines + 1] = "freeFrame: (not created)"
	end
	lines[#lines + 1] = string.format(
		"minimap zoom: %d of %d // farmZoomOut: %s",
		Minimap:GetZoom(),
		Minimap:GetZoomLevels() - 1,
		tostring(global and global.farmZoomOut)
	)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local count = C_AddOns.GetNumAddOns()
	for index = 1, count do
		local name, _, _, loadable = C_AddOns.GetAddOnInfo(index)
		local version = C_AddOns.GetAddOnMetadata(index, "Version") or "?"
		lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

local function DumpTable(value, indent, depth, lines)
	if depth > 8 then
		lines[#lines + 1] = indent .. "<max depth>"
		return
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local entry = value[key]
		if type(entry) == "table" then
			lines[#lines + 1] = indent .. tostring(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
		end
	end
end

--[[
    Dumps the single AceDB-managed table (profiles, profileKeys, char, global)
    so a player can paste their exact configuration: every setting in each
    profile and in the account-wide scope.
]]
function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "", ns.SAVED_VARIABLES_NAME .. " = {" }
	DumpTable(_G[ns.SAVED_VARIABLES_NAME] or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"
	return table.concat(lines, "\n")
end
