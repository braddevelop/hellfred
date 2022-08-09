---
--- A convenience method to create Subscriber objects
---
--- @param trigger any A key or key sequence
--- @param url any URL to open
--- @param mode any Mode this trigger may fire in
--- @return table Subscriber object
local _factory = function(trigger, url)
    return {
        trigger = trigger,
        fireIfModeIs = _G.HELLFIRE_MODES_EXTENDED.COMMON_LINKS, -- set to Common Links mode
        callback = function() hs.urlevent.openURL(url) end
    }
end

-- The collection of subscribers to return.
-- Assign a key to the name of a url to be opened.
local pack = {
    _factory({'t'}, 'https://techcrunch.com'), -- TechCrunch
    _factory({'g'}, 'https://github.com'), -- Github
    _factory({'h'}, 'https://news.ycombinator.com/'), -- Hacker News
    _factory({'s'}, 'https://stackoverflow.com/'), -- Stack Overflow
}

return pack