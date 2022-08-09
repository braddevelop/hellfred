-- require the Hellfuzz Helpers
local hfh = require('hellfred.hellfuzz.hellfuzz-helpers')

-- Create a standard callback function that gets
-- executed when a choice is selected.
-- The `choice` property from the subscriber is
-- passed as an argument.
local openAppCallback = function (choice)
    hs.application.launchOrFocus(choice.text)
end

-- Create a callback function that will
-- be executed when a url needs to be opened
local openLinkCallback = function (choice)
    hs.urlevent.openURL(choice.subText)
end

-- Create a function to call when the 'Common Links'
-- choice is selected. It returns a new set of subscribers.
local commonLinksNextChoices = function (choice)
    return {
        hfh.choiceHandlerFactory("Stack Overflow", "https://stackoverflow.com/", openLinkCallback, nil),
        hfh.choiceHandlerFactory("Hacker News", "https://news.ycombinator.com/", openLinkCallback, nil),
        hfh.choiceHandlerFactory("Github", "https://github.com", openLinkCallback, nil),
    }
end

-- 1. Create subscribers for the apps to be launched.
--    Pass the `openAppCallback` function as a `callback`.
--    Pass `true` to indicate that we want the choice to
--    show in the first choice set when Hellfuzz opens.
--
-- 2. Create a subscriber for the Common Links choice.
--    Pass `nil` for the callback
--    Pass the `commonLinksNextChoices` function as the `nextChoicesFn` function
return {
    -- App Launcher choices
    hfh.choiceHandlerFactory("Google Chrome", "", openAppCallback, nil, true),
    hfh.choiceHandlerFactory("Finder", "", openAppCallback, nil, true),
    hfh.choiceHandlerFactory("Terminal", "", openAppCallback, nil, true),
    hfh.choiceHandlerFactory("Notes", "", openAppCallback, nil, true),

    -- Url Launcher parent choice
    hfh.choiceHandlerFactory("Common Links", "", nil, commonLinksNextChoices, true)
}