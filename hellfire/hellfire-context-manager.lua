--[[

    Hellfire context manager

    Handles events from a keylogger listener, pre-processes the
    events and then enriches with context before passing it onto subscribers

--]]

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------
local _internal = {
    subscribers = {},
    keyloggerListener = require('hellfred.hellfire.hellfire-keylogger-listener'),
    mode =  { name = 'None' }
}

function _internal.onKeyLogEvent(sequence)
    local context = {
        mode = _internal.mode,
        trigger = sequence,
        triggerAsString = hs.fnutils.reduce(sequence, function(n, m) return n .. m end),
        app = hs.window.frontmostWindow():application(),
        window = hs.window.frontmostWindow()
    }

    for _, subscriber in pairs(_internal.subscribers) do
        subscriber(context)
    end
end

function _internal.init()
    _internal.keyloggerListener.addSubscriber(_internal.onKeyLogEvent)
    _internal.keyloggerListener.setMode(_internal.mode)
    return module
end

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------
function module.start()
    _internal.keyloggerListener.start()
end

function module.stop()
    _internal.keyloggerListener.stop()
end

---
--- Add a subscriber to internal subscriber list
---
function module.addSubscriber(subscriber)
    table.insert(_internal.subscribers, subscriber)
end

---
--- Set the operating mode
--- @param mode table
---
function module.setMode(mode)
    _internal.mode = mode or { name = 'None' }
    _internal.keyloggerListener.setMode(_internal.mode)
end

return _internal.init() -- returns module
