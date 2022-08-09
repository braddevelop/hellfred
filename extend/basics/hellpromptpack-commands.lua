-- Map strings to urls
local _linkMap = {
    so = 'https://stackoverflow.com/',
    news = 'https://news.ycombinator.com/',
    github = 'https://github.com',
}

-- Map strings to name of applications
local _appMap = {
    chrome = 'Google Chrome',
    finder =  'Finder',
    terminal = 'Terminal',
    notes = 'Notes',
}

-- Create two subscribers
-- The first will expect a command with the
-- format 'browse <LINK_SHORTCUT>'. e.g. 'browse github'.
-- It will open the link in `_linkMap` in a default browser
--
-- The second will expect a command with the
-- format 'open <APP_SHORTCUT>'. e.g. 'open notes'
-- It will open the application defined in `_appMap`
local pack = {
    {
        filters = {'^browse'}, -- match a command starting with the word 'browse'
        callback = function(command)
            local words = hs.fnutils.split(command, ' ')

            if #words == 2 then
                local site = words[2]
                if _linkMap[site] then
                    hs.urlevent.openURL(_linkMap[site])
                end
            end
        end
    },
    {
        filters = {'^open'}, -- match a command starting with the word 'open'
        callback = function(command)
            local words = hs.fnutils.split(command, ' ')

            if #words == 2 then
                local app = words[2]
                if _appMap[app] then
                    hs.application.launchOrFocus(_appMap[app])
                end
            end
        end
    }
}

return pack