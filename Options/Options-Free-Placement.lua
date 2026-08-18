local _, ns = ...

local L = ns.L
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer
local RowLabel = ns.OptionsRowLabel
local SubRow, SubLabel = ns.OptionsSubRow, ns.OptionsSubLabel

--[[
    Icon Shape and Icon Size only ever affect ns.freeFrame, which UpdatePlacement
    hides whenever freePlacement is off, so both are sub-options of Enable Free
    Placement Mode and collapse with it.
]]
local function Hidden()
	return not (ns.db and ns.db.global.freePlacement)
end

-- Sized to their captions with slack; never the full row width. See ns.OptionsSubRow.
local SHAPE_LABEL_WIDTH = 0.9
local SHAPE_DROPDOWN_WIDTH = 1.0
local SCALE_SLIDER_WIDTH = 1.9

--------------------------------------------------------------------------------
-- Free Placement Mode Options (composed into the General panel)
--------------------------------------------------------------------------------
function ns.BuildFreePlacementOptions()
	return {
		spaceFP0 = Spacer(39),
		headerFree = Header(L["PLACEMENT_MODE"], 40),
		spaceFPHeader = Spacer(40.5),
		descFree = Desc(L["PLACEMENT_DESC"], 41),
		spaceFP1 = Spacer(42),
		enableFree = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_FREE"],
			order = 43,
			width = "full",
			get = function()
				return ns.db and ns.db.global.freePlacement
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.freePlacement = value
					ns.UpdatePlacement()
				end
			end,
		},

		iconShapeRow = SubRow(45, Hidden, {
			RowLabel(SubLabel(L["OPTIONS_ICON_SHAPE"]), 1, SHAPE_LABEL_WIDTH),
			{
				type = "select",
				name = "",
				desc = L["OPTIONS_ICON_SHAPE_DESC"],
				width = SHAPE_DROPDOWN_WIDTH,
				style = "dropdown",
				values = {
					[ns.SHAPES.CIRCLE] = L["OPTIONS_SHAPE_CIRCLE"],
					[ns.SHAPES.SQUARE] = L["OPTIONS_SHAPE_SQUARE"],
				},
				get = function()
					return ns.db and ns.db.global.freeIconShape or ns.DATABASE_DEFAULTS.global.freeIconShape
				end,
				set = function(_, value)
					if ns.db then
						ns.db.global.freeIconShape = value
					end
					ns.UpdateFreeFrameShape()
				end,
			},
		}),

		iconScaleRow = SubRow(47, Hidden, {
			{
				type = "range",
				name = SubLabel(L["OPTIONS_ICON_SCALE"]),
				desc = L["OPTIONS_ICON_SCALE_DESC"],
				width = SCALE_SLIDER_WIDTH,
				min = 0.25,
				max = 3.0,
				step = 0.05,
				isPercent = true,
				get = function()
					return ns.db and ns.db.global.freeIconScale or ns.DATABASE_DEFAULTS.global.freeIconScale
				end,
				set = function(_, value)
					if ns.db then
						ns.db.global.freeIconScale = value
					end
					ns.UpdateFreeFrameScale()
				end,
			},
		}),
	}
end
