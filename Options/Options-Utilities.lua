local _, ns = ...

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

function ns.OptionsHeader(text, order)
    return {
        type = "header",
        name = ns.GetColor("TITLE") .. text .. "|r",
        order = order
    }
end

function ns.OptionsDesc(text, order)
    return {
        type = "description",
        name = text,
        fontSize = "medium",
        order = order
    }
end

function ns.OptionsSpacer(order)
    return {
        type = "description",
        name = " ",
        order = order
    }
end

function ns.OptionsSubHeader(text, order)
    return {
        type = "description",
        name = "\n" .. ns.GetColor("TITLE") .. text .. "|r",
        fontSize = "medium",
        order = order
    }
end
