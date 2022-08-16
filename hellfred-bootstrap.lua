--[[

    Hellfred Bootstrap

    A bootstrap file for Hellfred with a pre-configured setup.

--]]

--------------------------------------------------------------------------
-- Public namespace
--------------------------------------------------------------------------
local hellfred = {}
hellfred.__index = hellfred

-- Metadata
hellfred.name = "Hellfred"
hellfred.version = "1.0.0"
hellfred.author = "Brad Blundell"
hellfred.homepage = "https://github.com/braddevelop/hellfred"
hellfred.license = "MIT - https://opensource.org/licenses/MIT"

--[[ ______________________________________________________________________

    Hellfire
__________________________________________________________________________]]
local hellfire = require('hellfred.hellfire.hellfire')

-- Initialise Hellfire, passing a hotkey
hellfire.init({{'shift','cmd'},'h'})

-- Load subscribers from packs
hellfire.addSubscribers(require('hellfred.quick-start').hellfirePack)

--[[ ______________________________________________________________________

    Hellprompt
__________________________________________________________________________]]
local hellprompt = require('hellfred.hellprompt.hellprompt')

-- Initialise Hellprompt, passing a hotkey
hellprompt.init({{'shift','ctrl'},'h'})

-- Load subscribers from packs
hellprompt.addSubscribers(require('hellfred.quick-start').hellpromptPack)

--[[ ______________________________________________________________________

    Hellfuzz
__________________________________________________________________________]]
local hellfuzz = require('hellfred.hellfuzz.hellfuzz')

-- Initialise Hellfuzz, passing a hotkey
hellfuzz.init({{'shift','alt'},'h'})

-- Load subscribers from packs
hellfuzz.addSubscribers(require('hellfred.quick-start').hellfuzzPack)

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------
return hellfred
