-----------------------------------
-- Sanctum Blue Mage adjustments
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_blue_magic')

m:addOverride('xi.actions.spells.blue.cocoon.onSpellCast', function(caster, target, spell)
    local power = 50

    if caster:getMainJob() ~= xi.job.BLU and caster:getSubJob() == xi.job.BLU then
        power = 25
    end

    local duration = xi.spells.blue.calculateDurationWithDiffusion(caster, 180)

    if not target:addStatusEffect(xi.effect.DEFENSE_BOOST, { power = power, duration = duration, origin = caster }) then
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return xi.effect.DEFENSE_BOOST
end)

return m
