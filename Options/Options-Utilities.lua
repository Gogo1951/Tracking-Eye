local _, ns = ...

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

function ns.OptionsHeader(text, order, hidden)
	return {
		type = "header",
		name = GetColor("TITLE") .. text .. "|r",
		order = order,
		hidden = hidden,
	}
end

function ns.OptionsDesc(text, order)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		order = order,
	}
end

function ns.OptionsSpacer(order)
	return {
		type = "description",
		name = " ",
		order = order,
	}
end

--[[
    A sub-option: a control that only means anything while the toggle above it is
    on. Marked twice over, an indented checkbox and a silver caption, so the
    dependency reads whether the player is scanning shape or colour.

    Three constraints inside SubRow are load-bearing: one unnamed inline group per
    sub-option, or the next control packs onto the leftover space and the indent
    stops indenting anything; controls sized with slack rather than to the full
    row width, or a control on the wrap boundary tips onto its own line and
    strands the indent above it; and `hidden` on the group rather than the
    members, or the indent is left behind when the section collapses.
]]
function ns.OptionsSubLabel(text)
	return GetColor("HELP") .. text .. "|r"
end

function ns.OptionsSubRow(order, hidden, controls)
	local args = {
		indent = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_SUB_INDENT_WIDTH,
			order = 1,
		},
	}
	for index, control in ipairs(controls) do
		control.order = index + 1
		args["control" .. index] = control
	end
	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = args,
	}
end

--[[
    The label half of a label-beside-control row. The control that follows carries
    name = "" and the remaining width, ordered immediately after, so the two total
    ns.OPTIONS_ROW_WIDTH and land on one line. A caption left on the control puts
    the label back above the widget and breaks the row.
]]
function ns.OptionsRowLabel(text, order, width)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
	}
end
