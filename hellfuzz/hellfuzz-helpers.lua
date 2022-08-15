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
---
--- A convenience method for generating Hellfuzz ChoiceHandler objects
---
--- @param text any A string or hs.styledtext object that will be shown as the main text of the choice
--- @param subText any A string or hs.styledtext object that will be shown underneath the main text of the choice
--- @param callback any A function that is called if this choice is selected
--- @param nextChoicesFn any A function that returns an array of ChoiceHandler objects
--- @param showInFirstChoiceSet any Show this choice when Hellfuzz opens
--- @return table A ChoiceHandler object
---
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

---
--- A convenience method for generating Hellfuzz ChoiceHandler objects (custom)
--- This method allows for more custom configuration over
--- the `choice` argument than `choiceHandlerFactory` does
---
--- @param choice any A choice as specified in https://www.hammerspoon.org/docs/hs.chooser.html#choices
--- @param callback any A function that is called if this choice is selected
--- @param nextChoicesFn any A function that returns an array of ChoiceHandler objects
--- @param showInFirstChoiceSet any Show this choice when Hellfuzz opens
--- @return table A ChoiceHandler object
----
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
