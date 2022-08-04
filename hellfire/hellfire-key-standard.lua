--[[

    Hellfire key standard

    Converts different representations of key and key chord
    sequences to a standardised representation

--]]

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------
local _internal = {
    modifierList = { 'cmd', 'shift', 'ctrl', 'alt', 'capslock'}, -- supported modifier strings. Ignore `fn` for Hellfire (#documentation)
    modMap = { shift = '⇧', ctrl = '⌃', alt = '⌥', cmd = '⌘', capslock = '⊼', fn = 'ƒ' },
    shiftMap = require('hellfred.utils.shift-map')
}

---
--- Convert a modifier string to a symbol
---
function _internal.convertModifierToSymbol(modifier)
    return _internal.modMap[modifier]
end

---
--- Takes a human readable version of a keychord and standardises it
--- e.g. shift+h
---
function _internal.stringToStandardKeyChord(keyChord)
    -- Case: if user defines a keychord of 'shift++' for example.
    -- Remove '+' globally
    keyChord = keyChord:lower():gsub('%+%+', "+="):gsub('%+', "")

    local standardised = ''

    -- Search for modifiers in the string.
    -- If found, note the modifier in the standard to be returned
    -- and then strip the modifier out.
    for _, m in pairs(_internal.modifierList) do
        if string.find(keyChord, m) then
            standardised = standardised .. m
            keyChord = keyChord:gsub(m, "")
        end
    end

    -- canonicalise characters e.g. "!" => "1"
    for k, v in pairs(_internal.shiftMap) do
        if keyChord == v then
            keyChord = k
            break
        end
    end

    standardised = standardised .. keyChord
    return standardised
end

---
--- Takes a hs.eventtap.event and standardises it
---
function _internal.eventTapEventToStandardKeyChord(event)
    local standardised = ''

    -- search for supported modifiers in the eventTap event
    local eventmodifiers = hs.eventtap.checkKeyboardModifiers()
    for _, m in pairs(_internal.modifierList) do
        if eventmodifiers[m] then standardised = standardised .. m end
    end

    local character = hs.keycodes.map[event:getKeyCode()]
    standardised = standardised .. character

    return string.lower(standardised)
end

function _internal.keyChordSequenceToStandard(sequence)
    local standardised = ''
    for _, v in pairs(sequence) do
        standardised = standardised .. _internal.stringToStandardKeyChord(v)
    end
    return standardised
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

---
--- Standardise a key or key chord
---
--- Accepts a keychord, whether generated from an hs.eventtap.event
--- or supplied as a string and outputs a standardised version
--- Value can be either:
---      userdata from a keylogger eventtap event
---      string like "cmd+shift+v"
---
--- Outputs string => "cmdshiftv"
---
--- @param keyChord any
--- @return string
---
function module.standardiseKeyChord(keyChord)
    local standardised = ''
    if type(keyChord) == 'userdata' then -- eventtap event
        standardised = _internal.eventTapEventToStandardKeyChord(keyChord)
    elseif type(keyChord) == 'string' then -- string e.g.'cmd+g'
        standardised = _internal.stringToStandardKeyChord(keyChord)
    end

    return string.lower(standardised)
end

---
--- Converts a standardised keychord to a prettified output
---
--- E.g.
---    "cmdshiftx" to ⌘⇧X
---    "cmdx" to ⌘x
---    "cmdshift1" to ⌘⇧!
---
--- @param standardised any
--- @return string
---
function module.standardToHumanPrettified(standardised)
    local human = ''
    local isShifted = string.find(standardised, 'shift') or string.find(standardised, 'capslock')

    for _, m in pairs(_internal.modifierList) do
        if string.find(standardised, m) then
            if m ~= 'shift' then
                human = human .. _internal.convertModifierToSymbol(m)
            end
            standardised = standardised:gsub(m, "")
        end
    end

    -- if is a shiftable sequence then check the shiftmap
    if isShifted then
        for k, v in pairs(_internal.shiftMap) do
            if standardised == k then
                standardised = v
                break
            end
            -- if an alpha char then uppercase
            standardised = string.upper(standardised)
        end
    end

    human = human .. standardised
    return human
end

---
--- Compare two key/keychord sequences for equality
---
--- @param keyChordSequenceA any
--- @param keyChordSequenceB any
--- @return boolean `true` if they are equivalent, `false` if otherwise
---
function module.compare(keyChordSequenceA, keyChordSequenceB)
    return _internal.keyChordSequenceToStandard(keyChordSequenceA) == _internal.keyChordSequenceToStandard(keyChordSequenceB)
end

return module