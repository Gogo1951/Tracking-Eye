local _, ns = ...

local L = ns.L
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer

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
		spaceFP2 = Spacer(44),

		iconShape = {
			type = "select",
			name = L["OPTIONS_ICON_SHAPE"],
			desc = L["OPTIONS_ICON_SHAPE_DESC"],
			order = 45,
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
		spaceFP3 = Spacer(46),

		iconScale = {
			type = "range",
			name = L["OPTIONS_ICON_SCALE"],
			desc = L["OPTIONS_ICON_SCALE_DESC"],
			order = 47,
			width = "double",
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
	}
end
