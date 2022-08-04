--[[

    Hellfire key logger listener

    Composes a keylogger and manages the timing and broadcast
    of outputs to subscribers

--]]

--------------------------------------------------------------------------
-- Dependencies
--------------------------------------------------------------------------
local keyStandard = require('hellfred.hellfire.hellfire-key-standard')

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------
local _internal = {
    keylogger = require('hellfred.utils.keylogger'):new(),
    subscribers = {},
    digestTimer = nil,
    digestTimeInSeconds = 0.5,
    keyBuffer = {},
    keyCaster = require('hellfred.hellfire.hellfire-keycaster'),
}

function _internal.onKeyLogEvent(eventTapEvent)
    if _internal.digestTimer then
        _internal.digestTimer:setNextTrigger(_internal.digestTimeInSeconds)
    else
        _internal.digestTimer = hs.timer.doAfter(_internal.digestTimeInSeconds, _internal.onDigestTimerTrigger)
    end

    local standardised = keyStandard.standardiseKeyChord(eventTapEvent)

    table.insert(_internal.keyBuffer, standardised)

    local humanReadable = {}
    hs.fnutils.each(_internal.keyBuffer, function(kEvent)
        table.insert(humanReadable, keyStandard.standardToHumanPrettified(kEvent))
    end)

    _internal.keyCaster.setText(table.concat(humanReadable, "  ›  "))
end

function _internal.clearKeyBuffer()
    _internal.keyBuffer = {}
    _internal.keyCaster.reset()
end

function _internal.onDigestTimerTrigger()
    for _, subscriber in pairs(_internal.subscribers) do
        subscriber(_internal.keyBuffer)
    end
    _internal.clearKeyBuffer()
end


function _internal.init()
    _internal.keylogger.addSubscriber(_internal.onKeyLogEvent)
    return module
end

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------
function module.start()
    _internal.clearKeyBuffer()
    _internal.keylogger:start()
    _internal.keyCaster.show()
end

function module.stop()
    _internal.keylogger:stop()
    if _internal.digestTimer then
        _internal.digestTimer:stop()
    end
    _internal.keyCaster.hide()
    _internal.keyCaster.reset()
end

function module.setMode(mode)
    _internal.keyCaster.setMode(mode)
end

function module.addSubscriber(subscriber)
    table.insert(_internal.subscribers, subscriber)
end

return _internal.init() -- returns module