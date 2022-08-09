---
--- A convenience method to create Subscriber objects
---
--- @param trigger any A key or key sequence
--- @param nextMode any Mode to change to
--- @return table Subscriber object
local _factory = function(trigger, nextMode)
    return {
        trigger = trigger,
        fireIfModeIs = nil, -- set to `nil` so it fires in any mode
        callback = function(context)
            context.hellfire.setMode(nextMode)
            return { exitAfterCallback = false } -- keep Hellfire open
        end
    }
end

local pack = {
    _factory({'c','l'}, _G.HELLFIRE_MODES_EXTENDED.COMMON_LINKS),
    _factory({';'}, _G.HELLFIRE_MODES.DEFAULT),
}

return pack