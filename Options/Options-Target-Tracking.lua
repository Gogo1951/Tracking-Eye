local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local SubRow, SubLabel = ns.OptionsSubRow, ns.OptionsSubLabel

-- Sized to the caption with slack; never the full row width. See ns.OptionsSubRow.
local TARGET_TRACKING_WIDTH = 2.2

--[[
    Open to every class: whatever creature types this character can track, it can
    have set automatically. Hidden only for one that can track none of them — a
    Mage has nothing this could ever set — and while Persistent Tracking is off,
    since this sets the Persistent Tracking Ability and is meaningless without its
    parent.
]]
local function Hidden()
	if not (ns.db and ns.db.profile.persistentTracking) then
		return true
	end
	return not ns.HasCreatureTypeTracking()
end

--------------------------------------------------------------------------------
-- Target Tracking (a sub-option of Persistent Tracking, on the General panel)
--------------------------------------------------------------------------------
function ns.BuildTargetTrackingOptions()
	return {
		targetTrackingRow = SubRow(13.1, Hidden, {
			{
				type = "toggle",
				name = SubLabel(L["OPTIONS_TARGET_TRACKING"]),
				desc = L["OPTIONS_TARGET_TRACKING_DESC"],
				width = TARGET_TRACKING_WIDTH,
				get = function()
					return ns.db and ns.db.profile.targetTracking
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.targetTracking = value
					end
				end,
			},
		}),
		--[[
			Its own sub-row so the note lines up with the checkbox it belongs to.
			The indent has to be a real widget — padding the text with spaces moves
			nothing — and the explicit width is load-bearing: a description with no
			width is given "fill" by AceConfigDialog, which takes the whole row and
			drops the note back to the left edge.
		]]
		targetTrackingNoteRow = SubRow(13.2, Hidden, {
			{
				type = "description",
				name = GetColor("HELP") .. L["OPTIONS_TARGET_TRACKING_QUESTING"] .. "|r",
				fontSize = "medium",
				width = TARGET_TRACKING_WIDTH,
			},
		}),
	}
end
