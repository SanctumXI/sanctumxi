-----------------------------------
-- Sanctum Monk: Chi Blast boost scaling
-----------------------------------
require('modules/module_utils')
require('scripts/globals/job_utils/monk')
-----------------------------------

local m = Module:new('sanctum_monk_chi_blast')

-- The old multiplier was (power / 100) * 5, so one Boost read as 0.625 and did
-- less damage than not boosting at all. Start at 1 and add from there. Eight
-- stacks still lands on 5x.
m:addOverride('xi.job_utils.monk.useChiBlast', function(player, target, ability)
    local penanceMerits = player:getMerit(xi.merit.PENANCE)
    if penanceMerits > 0 then
        target:delStatusEffectSilent(xi.effect.INHIBIT_TP)
        target:addStatusEffect(xi.effect.INHIBIT_TP, { power = 25, duration = penanceMerits, origin = player })
    end

    local boost      = player:getStatusEffect(xi.effect.BOOST)
    local multiplier = 1.0

    if boost ~= nil then
        multiplier = 1 + boost:getPower() / 25
    end

    if player:getMainLvl() > 65 then
        target:addStatusEffect(xi.effect.PLAGUE, { power = 15, duration = 30, origin = player })
    end

    local dmg = math.floor(player:getStat(xi.mod.VIT) * (1.4 + (math.randomFloat(0, 1) / 2))) * multiplier

    dmg = xi.ability.adjustDamage(dmg, player, ability, target, xi.attackType.BREATH, xi.damageType.ELEMENTAL, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)
    target:takeDamage(dmg, player, xi.attackType.BREATH, xi.damageType.ELEMENTAL)
    target:updateClaim(player)
    player:delStatusEffect(xi.effect.BOOST)

    return dmg
end)

return m
