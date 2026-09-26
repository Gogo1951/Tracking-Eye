local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Announcements
--------------------------------------------------------------------------------

--[[
    Tracking Eye never sends chat itself. Come & Get It is the one outbound line,
    and only as a draft the player sends: BuildAnnounceMessage composes it, and
    the chat box is opened in Features/Come-and-Get-It.lua. Announce,
    GetGroupChatChannel, and a TARGET_MARKER constant are intentionally omitted.
]]

-- Format: |cff[INFO]Add-on Name|r |cff[SEPARATOR]//|r |cff[TEXT]Message|r
function ns:PrintMessage(message)
	print(
		GetColor("INFO")
			.. L["ADDON_TITLE"]
			.. "|r "
			.. GetColor("SEPARATOR")
			.. "//"
			.. "|r "
			.. GetColor("TEXT")
			.. message
			.. "|r"
	)
end

--------------------------------------------------------------------------------
-- Announcement Builder
--------------------------------------------------------------------------------

--[[
    Come & Get It's draft line, sent as the locale body alone: no raid marker, no
    add-on name prefix. WoW Forever blocks raid-marker tokens in chat, so the line
    stays plain on every client, and it reads as the player talking.
]]
function ns:BuildAnnounceMessage(formatKey, ...)
	local template = L[formatKey]
	if not template then
		return nil
	end
	local message = string.format(template, ...)
	-- Bodies never carry item links, so stripping stray pipes is safe here.
	return (message:gsub("|", ""))
end
