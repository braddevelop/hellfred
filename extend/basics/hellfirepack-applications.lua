---
--- A convenience method to create Subscriber objects
---
--- @param trigger any A key or key sequence
--- @param app any Name of the app to launch
--- @return table Subscriber object
local _factory = function(trigger, app)
    return {
        trigger = trigger,
        fireIfModeIs = nil,
        callback = function() hs.application.launchOrFocus(app) end
    }
end

-- The collection of subscribers to return.
-- Assign a key to the name of an application to be opened.
-- Notice for now that we do not pass an argument for `mode`. This is
-- fine and will indicate that these triggers fire under the Default
-- mode only.
local pack = {
    _factory({'f'}, 'Finder'),
    _factory({'t'}, 'Terminal'),
    _factory({'n'}, 'Notes'),
}

return pack