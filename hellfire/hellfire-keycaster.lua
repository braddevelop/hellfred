--[[

	Hellfire Keycaster

	A keystroke visualiser.
	Inspired by https://github.com/keycastr/keycastr

--]]

--------------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------------
local module = {}

--------------------------------------------------------------------------------
-- Private namespace
--------------------------------------------------------------------------------
local _internal = {
    defaultChooserImage = hs.image.imageFromPath("hellfred/resources/hellfred-logo-orange-96x96.png"),
    canvas = nil,
    casterText = nil,
    modeTextElement = nil,
    frameWidth = 1200.0,
    frameHeight = 500.0, --  200:bottom; 500:middle; 900:top
    barWidth = 1200,
    barHeight = 55,
    casterTextSize = 20,
    modeTextSize = 20,
    style = {
        fonts = {
            primary = "Menlo"
        },
        colours = {
            black = { hex = "#000000" },
            white = { hex = "#FFFFFF" },
            primary = { hex = "#E43C26" }, -- intense orange
            secondary = { hex = "#F1B51C" }, -- yellow
        }
    },
}

---
--- Initialise elements of the visualiser interface
---
--- @return table The key caster object
---
function _internal.init()
    local mainScreen = hs.screen.mainScreen()
    local mainRes = mainScreen:fullFrame()

    if not _internal.canvas then
        _internal.canvas = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
    end

    -- Background
    _internal.canvas[1] = {
        action = "fill",
        fillColor = _internal.style.colours.black,
        frame = { h = _internal.barHeight, w = _internal.barWidth, x = 0.0, y = 0.0 },
        type = "rectangle"
    }
    _internal.canvas[1].fillColor.alpha = 0.9

    -- Caster text
    _internal.canvas[2] = {
        type = "text",
        text = "",
        textFont = _internal.style.fonts.primary,
        textSize = _internal.casterTextSize,
        textColor = _internal.style.colours.secondary,
        textAlignment = "center",
        frame = { x = 30.0, y = 16.0, h = _internal.barHeight, w = _internal.barWidth }
    }
    _internal.casterText = _internal.canvas[2]

    -- Mode title
    _internal.canvas[3] = {
        type = "text",
        text = "MODE:",
        textFont = _internal.style.fonts.primary,
        textSize = 10,
        textColor = { hex = "#CCCCCC" },
        frame = { x = 80.0, y = 20.0, h = 100, w = 100 }
    }

    -- Mode text
    _internal.canvas[4] = {
        type = "text",
        text = "No mode set",
        textFont = _internal.style.fonts.primary,
        textSize = 14,
        textColor = _internal.style.colours.white,
        frame = { x = 120.0, y = 18.0, h = 100, w = 500 }
    }
    _internal.modeTextElement = _internal.canvas[4]

    -- Hellfred logo
    _internal.canvas[5] = {
        type = "image",
        image = _internal.defaultChooserImage,
        frame = { x = 12.0, y = 0.0, h = 48, w = 48 }
    }

    _internal.canvas:frame({
        x = (mainRes.w - _internal.frameWidth) / 2,
        y = (mainRes.h - _internal.frameHeight),
        w = _internal.frameWidth,
        h = _internal.frameHeight
    })

    return module
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

---
--- Show the key caster
---
function module.show()
    _internal.canvas:show()
end

---
--- Hide the key caster
---
function module.hide()
    _internal.canvas:hide()
end

---
--- Set the mode
--- @param mode string
---
function module.setMode(mode)
    _internal.modeTextElement.text = mode.name

    if mode.style and mode.style.background then
        _internal.canvas[1].fillColor = mode.style.background.color -- main background
    end

    if mode.style and mode.style.casterText then
        _internal.canvas[2].textColor = mode.style.casterText.color -- caster text
    end

    if mode.style and mode.style.modeDisplay then
        _internal.canvas[3].textColor = mode.style.modeDisplay.color -- MODE title
        _internal.canvas[4].textColor = mode.style.modeDisplay.color -- MODE text
    end
end

---
--- Set the key caster text
--- @param text string
---
function module.setText(text)
    _internal.casterText.text = text
end

---
--- Reset the key caster object
---
function module.reset()
    _internal.casterText.text = ''
end

return _internal.init() -- returns module
