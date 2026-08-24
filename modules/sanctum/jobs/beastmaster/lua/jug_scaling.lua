-----------------------------------
-- Sanctum jug pet: global scaling dials
--
-- ===========================================================================
--  THE DIALS. 1.00 leaves a stat exactly as it would be; 0.90 is ninety
--  percent of normal. Change these three numbers and nothing else.
-- ===========================================================================

local ATTACK_SCALE  = 0.90
local DEFENSE_SCALE = 0.90
local HP_SCALE      = 0.95

-- ===========================================================================
--
-- These reach every jug pet in the game and nothing else. They are applied
-- through xi.pets.jug.onMobSpawn, and GetScriptName returns 'jug' only for
-- PET_TYPE::JUG_PET, so wild mobs, avatars, wyverns, automatons and charmed
-- pets never pass through here.
--
-- Each dial maps onto the percentage modifier the engine already multiplies
-- by, so the result is exact rather than approximate:
--
--   ATTP  ATT() returns ATT + (ATT * ATTP / 100)
--   DEFP  DEF() returns DEF + (DEF * DEFP / 100)
--   HPP   UpdateHealth scales max HP by (100 + HPP) / 100
--
-- Because those modifiers are additive, a buff that raises the same one nets
-- against the dial rather than multiplying on top of it. At -10 attack, the
-- Tiger's Roar at +10 brings its target back to exactly normal rather than to
-- 110% of the reduced figure. That is the engine's own behaviour for every
-- percentage buff in the game, not something introduced here.
--
-- setMod rather than addMod, so a respawn cannot stack the dial on itself.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_beastmaster_jug_scaling')

-- 0.95 * 100 lands on 95.00000000000001 in floating point, so round before
-- converting rather than truncating a number that is already fractionally over.
local function toModifier(scale)
    return math.floor(scale * 100 + 0.5) - 100
end

m:addOverride('xi.pets.jug.onMobSpawn', function(pet)
    super(pet)

    pet:setMod(xi.mod.ATTP, toModifier(ATTACK_SCALE))
    pet:setMod(xi.mod.DEFP, toModifier(DEFENSE_SCALE))
    pet:setMod(xi.mod.HPP, toModifier(HP_SCALE))

    -- Max HP is resolved once when the pet is built, so HPP has to be applied
    -- before a recalculation or it will not take until something else forces one.
    pet:updateHealth()
end)

return m
