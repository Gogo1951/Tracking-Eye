local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Announcements
--------------------------------------------------------------------------------

--[[
    Tracking Eye only prints to the player; it sends no cross-player chat. The
    sent-chat helpers (BuildAnnounceMessage, Announce, GetGroupChatChannel) and a
    TARGET_MARKER constant are intentionally omitted — add them here if outbound
    chat messaging is ever introduced.
]]

-- Format: |cff[INFO]Add-on Name|r |cff[SEPARATOR]//|r |cff[TEXT]Message|r
function ns:PrintMessage(message)
    print(GetColor("INFO") .. L["ADDON_TITLE"] .. "|r "
       .. GetColor("SEPARATOR") .. "//" .. "|r "
       .. GetColor("TEXT") .. message .. "|r")
end
