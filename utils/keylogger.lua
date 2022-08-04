--[[

	Hellfred Key logger

    A key logger with subscriber notification.

--]]

--------------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

---
--- Instantiate a new key logger instance
--- @return table A key logger object
---
function module.new()

    -------------------------------
    -- Instance public namespace
    -------------------------------
    local obj = {}

    -------------------------------
    -- Instance private namespace
    -------------------------------
    local _internal = {
        modal = nil,
        subscribers = {},
        keyListener = nil,
    }

    ---
    --- Initialise this key logger
    --- @return table The key logger object
    ---
    function _internal.init()
        _internal.modal = hs.hotkey.modal.new()
        _internal.modal.entered = function()
            _internal.keyListener:start()
        end

        _internal.modal.exited = function()
            _internal.keyListener:stop()
        end

        _internal.keyListener = hs.eventtap.new(
            { hs.eventtap.event.types.keyDown },
            _internal.onKeyEvent
        )
    end

    ---
    --- Handle event tap events emitted
    ---
    --- @param eventTapEvent hs.eventtap.event
    ---
    function _internal.onKeyEvent(eventTapEvent)

        local keyCode = eventTapEvent:getKeyCode()

        if keyCode ~= 53 then -- ignore escape: must propogate
            for _, callback in pairs(_internal.subscribers) do
                callback(eventTapEvent)
            end
            return true -- prevent event propagation
        end
        return false -- allow event propagation
    end

    -------------------------------
    -- Instance public API
    -------------------------------

    ---
    --- Start logging keys
    ---
    function obj.start()
        _internal.modal:enter()
    end

    ---
    --- Stop logging keys
    ---
    function obj.stop()
        _internal.modal:exit()
    end

    ---
    --- Add a subscriber to internal subscriber list
    ---
    function obj.addSubscriber(subscriber)
        table.insert(_internal.subscribers, subscriber)
    end

    ---
    --- Add multiple subscribers to internal subscriber list
    ---
    function obj.addSubscribers(subscribers)
        hs.fnutils.each(subscribers, function(sub)
            obj.addSubscriber(sub)
        end)
    end

    -------------------------------
    -- Program
    -------------------------------
    _internal.init()

    return obj
end

return module