--[[

    Hellprompt

    A commandline-like utility with subscriber notification.

    Composes a key caster to display user key strokes and
    a key logger that it listens to for event tap events.

--]]

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------
local _internal = {
    modal = nil,
    keylogger = require('hellfred.utils.keylogger'):new(),
    subscribers = {},
    commandBuffer = '',
    keyCaster = require('hellfred.hellprompt.hellprompt-keycaster'),
    cursor = '▏',
    promptPrefix = ' ›› ',
    shiftMap = require('hellfred.utils.shift-map')
}

---
--- Enter Hellprompt
---
function _internal.enter()
    _internal.clearCommandBuffer()
    _internal.keyCaster.setText(_internal.promptPrefix.._internal.cursor)
    _internal.keylogger:start()
    _internal.keyCaster.show()
end

---
--- Exit Hellprompt
---
function _internal.exit()
    _internal.keylogger:stop()
    _internal.keyCaster.hide()
    _internal.keyCaster.reset()
    _internal.modal:exit()
end

---
--- Notify subscribers
---
--- @param message string
---
function _internal.notify(message)
    hs.fnutils.each(_internal.subscribers, function(subscriber)
        -- Check the filter rules, if any, specified by the subscriber object
        -- If any filters do not match then do not notify the subscriber
        local doNotify = true
        if subscriber.filters then
            hs.fnutils.each(subscriber.filters, function(filter)
                if string.match(message, filter) == nil then
                    doNotify = false
                end
            end)
        end

        if doNotify then
            subscriber.callback(message)
        end
    end)
end

---
--- Handle event tap events emitted from a keylogger
---
--- @param eventTapEvent hs.eventtap.event
---
function _internal.onKeyLoggerEvent(eventTapEvent)

    local key = hs.keycodes.map[eventTapEvent:getKeyCode()]

    -- Check if we should submit the command and exit Hellprompt
    if key == 'return' or key == 'padenter' then
        _internal.exit()
        _internal.notify(_internal.commandBuffer)
        return
    end

    -- Ignore these key inputs
    local ignoreableKeys = {
        ["f1"] = true, ["f2"] = true, ["f3"] = true, ["f4"] = true,
        ["f5"] = true, ["f6"] = true, ["f7"] = true, ["f8"] = true, ["f9"] = true,
        ["f10"] = true, ["f11"] = true, ["f12"] = true, ["f13"] = true,
        ["f14"] = true, ["f15"] = true, ["f16"] = true, ["f17"] = true,
        ["f18"] = true, ["f19"] = true, ["f20"] = true, ["tab"] = true,
        ["escape"] = true, ["help"] = true, ["home"] = true, ["pageup"] = true,
        ["forwarddelete"] = true, ["end"] = true, ["pagedown"] = true,
        ["left"] = true, ["right"] = true, ["down"] = true, ["up"] = true,
    }
    for k, v in pairs(ignoreableKeys) do
        if key == k then return end
    end

    -- Convert some keys to canonical character
    local convertableKeys = {
        ["pad"] = '"', ["pad*"] = '*', ["pad+"] = '+', ["pad/"] = '/', ["pad-"] = '-',
        ["pad="] = '=', ["pad0"] = '0', ["pad1"] = '1', ["pad2"] = '2', ["pad3"] = '3',
        ["pad4"] = '4', ["pad5"] = '5', ["pad6"] = '6', ["pad7"] = '7', ["pad8"] = '8',
        ["pad9"] = '9', ["space"] = ' ',
    }
    for k, v in pairs(convertableKeys) do
        if key == k then
            key = v
        end
    end

    -- Convert to 'shift up' characters if necessary
    local flags = eventTapEvent:getFlags()
    if flags.shift then
        key = key:upper()
        if _internal.shiftMap[key] then
            key = _internal.shiftMap[key]
        end
    end

    -- Handle character and word deletion
    if key:lower() == 'delete'  or key:lower() == 'padclear' then
        if _internal.commandBuffer ~= '' then
            if flags.alt or flags.cmd or flags.ctrl then
                -- delete previous word
                local words = hs.fnutils.split(_internal.commandBuffer,' ')
                table.remove(words, #words)
                _internal.commandBuffer = table.concat(words, ' ')
            else
                -- delete last character
                _internal.commandBuffer = string.sub(_internal.commandBuffer, 1,-2)
            end
        end
    else
        -- Append the character
        _internal.commandBuffer = _internal.commandBuffer..key
    end

    _internal.keyCaster.setText(_internal.promptPrefix.._internal.commandBuffer.._internal.cursor)
end

---
--- Clear the command buffer
---
function _internal.clearCommandBuffer()
    _internal.commandBuffer = ''
    _internal.keyCaster.reset()
end

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------

---
--- Initialise Hellprompt
--- @param keySpec table
---
function module.init(keySpec)
    _internal.modal = hs.hotkey.modal.new(keySpec[1], keySpec[2])

    function _internal.modal:entered()
        _internal.enter()
    end
    _internal.modal:bind('', 'escape', function() _internal.exit() end)
    _internal.keylogger.addSubscriber(_internal.onKeyLoggerEvent)
end

---
--- Add a subscriber to internal subscriber list
---
--- @param subscriber any A CommandHandler object
---
function module.addSubscriber(subscriber)
    table.insert(_internal.subscribers, subscriber)
end

---
--- Add multiple subscribers to internal subscriber list
---
--- @param subscribers any An array of CommandHandler objects
---
function module.addSubscribers(subscribers)
    hs.fnutils.each(subscribers, function(sub)
        module.addSubscriber(sub)
    end)
end

return module