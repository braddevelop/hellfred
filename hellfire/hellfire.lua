--[[

    Hellfire

    A key-to-action mapping utility with subscriber notification.
    Supports single key triggers as well as key chord sequences as triggers.

    Composes a key caster to display the user key strokes and
    a key logger that listens for event tap events.

--]]


--------------------------------------------------------------------------
-- Dependencies
--------------------------------------------------------------------------
local keyStandard = require('hellfred.hellfire.hellfire-key-standard')
local hellfireModes = require('hellfred.hellfire.hellfire-modes')

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------
local _internal = {
    contextManager = require('hellfred.hellfire.hellfire-context-manager'),
    subscribers = {}
}

---
--- Enter Hellfire
---
function _internal.enter()
    _internal.contextManager.start()
end

---
--- Exit Hellfire
---
function _internal.exit()
    _internal.contextManager.stop()
    if _internal.modal then
        _internal.modal:exit()
    end
end

---
--- Notify subscribers
--- @param context table
---
function _internal.notify(context)
    for _, subscriber in pairs(_internal.subscribers) do
        subscriber(context)
    end
end

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------

---
--- Initialise Hellfire
--- @param keySpec table A hotkey specification that triggers Hellfire
---
function module.init(keySpec)
    if keySpec then
        _internal.modal = hs.hotkey.modal.new(keySpec[1], keySpec[2])
        function _internal.modal:entered()
            _internal.enter()
        end
        _internal.modal:bind('', 'escape', function() _internal.exit() end)
    end
    _internal.contextManager.addSubscriber(_internal.notify)
    module.setMode(hellfireModes.DEFAULT)
end

---
--- Add a subscriber to internal subscriber list
--- @param subscriber any A subscriber to be notified of Hellfire events
---
function module.addSubscriber(subscriber)
    -- Always set a mode to a default if not configured
    subscriber.fireIfModeIs = subscriber.fireIfModeIs or hellfireModes.ANY

    local trigger = subscriber.trigger
    local callback = subscriber.callback
    local fireIfModeIs = subscriber.fireIfModeIs.name

    local fn = function(context)

        -- If the subscriber is not configured to run in Hellfire's ANY mode
        -- then short circuit if it should not execute its callback in the current mode
        if fireIfModeIs ~= hellfireModes.ANY.name then
            if context.mode.name ~= fireIfModeIs then
                return 0
            end
        end

        -- Only compare if a trigger was explicitly supplied
        local comparisonResult = nil
        if trigger then
            local a = context.trigger -- standard key chord sequence
            local b = trigger -- user configured
            comparisonResult = keyStandard.compare(a, b)
        end

        -- Invoke callback if there is a comparison match or if no trigger was supplied
        if trigger == nil or comparisonResult == true then
            context['hellfire'] = module

            local cbResponse = callback(context) or {exitAfterCallback = true}

            if cbResponse['exitAfterCallback'] ~= false then
                _internal.exit()
            end
        end
    end

    table.insert(_internal.subscribers, fn)
end

---
--- Add multiple subscribers to internal subscriber list
--- @param subscribers table
---
function module.addSubscribers(subscribers)
    hs.fnutils.each(subscribers, function(subscriber)
        module.addSubscriber(subscriber)
    end)
end

---
--- Set the operating mode
--- @param mode table A configuration for a Hellfire mode
---
function module.setMode(mode)
    _internal.contextManager.setMode(mode)
end

return module