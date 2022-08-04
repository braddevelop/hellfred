--[[

    Hellfred Quick Start

    A sample configuration for Hellfred

--]]

local hfh = require('hellfred.hellfuzz.hellfuzz-helpers')

-- A  mapping of keys to resources
local _resourceMap = {
    wiki = 'https://github.com/braddevelop/hellfred/wiki',
    discuss = 'https://github.com/braddevelop/hellfred/discussions',
    code = 'https://github.com/braddevelop/hellfred',
}

-- Factory function that creates subscribers
-- for Hellfire
local _factory = function(trigger, url, mode)
    return {
        trigger = trigger,
        fireIfModeIs = mode or nil,
        callback = function() hs.urlevent.openURL(url) end
    }
end

-- A configuration object with
-- setups for Hellfire, Hellfuzz and Hellprompt
return {
    --[[
        Using Hellfire:
        - the`w` key opens the Hellfred Wiki online.
        - the`c` key opens the Hellfred Repo online.
        - the`d` key opens the Hellfred Discussion page online.
    ]]
    hellfirePack = {
        _factory({'w'}, _resourceMap.wiki),
        _factory({'c'}, _resourceMap.code),
        _factory({'d'}, _resourceMap.discuss),
    },
    --[[
        Using Hellfuzz:
        - display choices for opening Hellfred Wiki, Code or Discussion page
    ]]
    hellfuzzPack = {
        hfh.choiceHandlerFactory("Open Hellfred wiki", "", function(choice)
            hs.urlevent.openURL(_resourceMap.wiki)
        end, nil, true),
        hfh.choiceHandlerFactory("Open Hellfred repo", "", function(choice)
            hs.urlevent.openURL(_resourceMap.code)
        end, nil, true),
        hfh.choiceHandlerFactory("Discuss Hellfred", "", function(choice)
            hs.urlevent.openURL(_resourceMap.discuss)
        end, nil, true)
    },
    --[[
        Using Hellprompt:
        - type `open wiki` to open the Hellfred Wiki online.
        - type `open code` to open the Hellfred Repo online.
        - type `open discuss` to open the Hellfred Discussion page online.
    ]]
    hellpromptPack = {
        {
            filters = {'^open'},
            callback = function(command)
                local words = hs.fnutils.split(command, ' ')

                if #words == 2 then
                    local resource = words[2]
                    if _resourceMap[resource] then
                        hs.urlevent.openURL(_resourceMap[resource])
                    end
                end
            end
        }
    },
}