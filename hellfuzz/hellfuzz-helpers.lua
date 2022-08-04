--[[

    Helper methods for Hellfuzz

--]]

--------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------
local _internal = {
    defaultChooserImage = hs.image.imageFromPath("hellfred/resources/hellfred-logo-orange-96x96.png")
}

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------
function module.choiceHandlerFactory(text, subText, callback, nextChoicesFn, showInFirstChoiceSet)

    local choice = {
        text = text,
        image = _internal.defaultChooserImage
    }

    if subText then
        choice.subText = subText
    end

    return {
        choice = choice,
        callback = callback,
        nextChoicesFn = nextChoicesFn,
        showInFirstChoiceSet = showInFirstChoiceSet or false
    }
end

function module.choiceHandlerCustomFactory(choice, callback, nextChoicesFn, showInFirstChoiceSet)
    choice.image = choice.image or _internal.defaultChooserImage

    return {
        choice = choice,
        callback = callback,
        nextChoicesFn = nextChoicesFn,
        showInFirstChoiceSet = showInFirstChoiceSet or false
    }
end

return module
