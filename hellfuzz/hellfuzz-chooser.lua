--[[

    Hellfuzz chooser

    Attribution: Fuzzy Window Switcher https://gist.github.com/RainmanNoodles/70aaff04b20763041d7acb771b0ff2b2

--]]

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local module={}

--------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------
local _internal = {
    choices = nil,
    lastApp = nil,
    chooser = nil,
    onChooserEventHandler = nil,
    userMeta = nil,
    queryInterceptorFunc = nil,
    bindings = {},
}

function _internal.enter()
    local escapeHotkey = hs.hotkey.bindSpec({ {}, 'escape' },
        function()
        _internal.chooser:cancel()
        _internal.exit()
    end
    )
    table.insert(_internal.bindings, escapeHotkey)

    _internal.userMeta = nil
    _internal.lastApp = hs.window.focusedWindow()

    _internal.chooser:show()
    _internal.chooser:query('') -- workaround
    _internal.onQueryChanged('') -- workaround
end


---
--- Unbind all hotkeys
---
function _internal.unbindAll()
    hs.fnutils.each(_internal.bindings, function(bindingObj)
        bindingObj:delete()
    end)

    -- clear bindings
    local count = #_internal.bindings
    for i = 0, count do _internal.bindings[i] = nil end
end


function _internal.exit()
    _internal.unbindAll()
end


function _internal.onSelectCallback(choice, userParams)
    _internal.onChooserEventHandler(choice, userParams)
end

---
--- Fuzzy score algorithm
---
function _internal.fuzzyScore(s, m)
    local s_index = 1
    local m_index = 1
    local match_start = nil
    while true do
        if s_index > s:len() or m_index > m:len() then
            return -1
        end
        local s_char = s:sub(s_index, s_index)
        local m_char = m:sub(m_index, m_index)
        if s_char == m_char then
            if match_start == nil then
                match_start = s_index
            end
            s_index = s_index + 1
            m_index = m_index + 1
            if m_index > m:len() then
                local match_end = s_index
                local s_match_length = match_end - match_start
                local score = m:len() / s_match_length
                return score
            end
        else
            s_index = s_index + 1
        end
    end
end


function _internal.onSelectCallbackDecorator(choice)
    if choice == nil then
        if _internal.lastApp then
            -- Workaround so last focused window stays focused after dismissing
            _internal.lastApp:focus()
            _internal.lastApp = nil
        end
    else
        if _internal.onSelectCallback then
            _internal.onSelectCallback(choice, _internal.userMeta)
        end
    end
    _internal.exit()
end


function _internal.onInvalidCallback(choice)
    _internal.onChooserEventHandler(choice, _internal.userMeta)
end


function _internal.onQueryChanged(query)
    if _internal.queryInterceptorFunc then
        query, _internal.userMeta = _internal.queryInterceptorFunc(query)
    end

    -- If the user has backspaced (deleted) to an empty string
    -- then reset back to all choices
    if query:len() == 0 then
        _internal.chooser:choices(_internal.choices)
        return
    end

    local pickedChoices = {}
    for i, j in pairs(_internal.choices) do

        -- Prepare the search space for this choice
        local fullText = j["text"]
        if j["subText"] ~= nil then
            fullText = fullText .. " " .. j["subText"]
        end
        fullText = fullText:lower()

        -- Score the match of query to choice
        local score = _internal.fuzzyScore(fullText, query:lower())

        -- If the choice has any interesting score then assign `score` to `choice.fzf_score`
        if score > 0 then
            j["fzf_score"] = score
            table.insert(pickedChoices, j)
        end
    end

    -- Sort the choices by score
    local sort_func = function(a, b) return a["fzf_score"] > b["fzf_score"] end
    table.sort(pickedChoices, sort_func)

    -- Update chooser choices with scored items
    _internal.chooser:choices(pickedChoices)
end

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------

---
--- Initialise Hellfuzz chooser
--- @param onEventHandler any
---
function module.init(onEventHandler)
    _internal.onChooserEventHandler = onEventHandler
    _internal.chooser = hs.chooser.new(_internal.onSelectCallbackDecorator)
    _internal.chooser:bgDark(true)
    _internal.chooser:queryChangedCallback(_internal.onQueryChanged) -- Enable true fuzzy find
    _internal.chooser:invalidCallback(_internal.onInvalidCallback)
end
---
--- Enter the chooser
---
--- @param choices table A list of choices
---
function module.enter(choices)
    _internal.choices = choices
    _internal.enter()
end

---
--- Supply another [sub set] of choices for the chooser
---
--- @param choices table A list of choices
---
function module.next(choices)
    _internal.userMeta = nil
    _internal.choices = choices
    _internal.chooser:choices(_internal.choices)
    _internal.chooser:query('') -- workaround
end

---
--- Set a query interceptor function
---
--- A function that intercepts the user
--- input before it is processed by the fuzzy search.
---
--- It should accept one string argument (the user query)
--- and return a string as a first return value, to be used
--- by the chooser, followed by an optional second meta value,
--- that will be passed to the subscriber callback.
---
--- Format example:
---     inspectorFunc = function (query)
---         ...some logic here...
---         return query, query.upper()
---     end
---
--- @param fn any
---
function module.setQueryInterceptor(fn)
    _internal.queryInterceptorFunc = fn
end

return module