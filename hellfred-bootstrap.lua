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
hellfred.version = "0.1.0"
hellfred.author = "Brad Blundell"
hellfred.homepage = "https://github.com/braddevelop/hellfred"
hellfred.license = "MIT - https://opensource.org/licenses/MIT"

_G.HELLFIRE_MODES = require('hellfred.hellfire.hellfire-modes')
_G.HELLFIRE_MODES_EXTENDED = require('hellfred.extend.basics.hellfire-modes-extended')

--[[ ______________________________________________________________________

    Hellfire
__________________________________________________________________________]]
local hellfire = require('hellfred.hellfire.hellfire')

-- Initialise Hellfire, passing a hotkey
hellfire.init({{'shift','cmd'},'h'})

-- Load subscribers from packs
hellfire.addSubscribers(require('hellfred.quick-start').hellfirePack)
hellfire.addSubscribers(require('hellfred.extend.basics.hellfirepack-applications'))
hellfire.addSubscribers(require('hellfred.extend.basics.hellfirepack-common-links'))
hellfire.addSubscribers(require('hellfred.extend.basics.hellfire-mode-triggers'))

--[[ ______________________________________________________________________

    Hellprompt
__________________________________________________________________________]]
local hellprompt = require('hellfred.hellprompt.hellprompt')

-- Initialise Hellprompt, passing a hotkey
hellprompt.init({{'shift','ctrl'},'h'})

-- Load subscribers from packs
hellprompt.addSubscribers(require('hellfred.quick-start').hellpromptPack)
hellprompt.addSubscribers(require('hellfred.extend.basics.hellpromptpack-commands'))

--[[ ______________________________________________________________________

    Hellfuzz
__________________________________________________________________________]]
local hellfuzz = require('hellfred.hellfuzz.hellfuzz')

-- Initialise Hellfuzz, passing a hotkey
hellfuzz.init({{'shift','alt'},'h'})

-- Load subscribers from packs
hellfuzz.addSubscribers(require('hellfred.quick-start').hellfuzzPack)
hellfuzz.addSubscribers(require('hellfred.extend.basics.hellfuzzpack-apps-and-links'))

--------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------
return hellfred