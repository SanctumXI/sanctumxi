-----------------------------------
-- Sanctum Monk: bring hand-to-hand in line with the two-handers
-----------------------------------
require('modules/module_utils')
require('scripts/globals/combat/physical_hit_rate')
require('scripts/globals/combat/physical_utilities')
require('scripts/globals/weaponskills')
-----------------------------------

local m = Module:new('sanctum_monk_hand_to_hand')

-- Two fists on a short round put Monk roughly 50% clear of the field before any
-- buffs. Two of the three causes are hand-to-hand getting a better version of a
-- rule everyone else follows, and those are normalised elsewhere in this module
-- and in attackround.cpp. This is the remaining dial: flat damage on hand-to-hand
-- swings and weapon skills. Raise it to give Monk back damage, lower it to take
-- more away.
local handToHandDamage = 0.80

m:addOverride('xi.combat.physicalHitRate.getPhysicalHitRateCap', function(attacker, slot)
    -- Hand-to-hand was the only weapon class with a 99% cap. Everything else caps
    -- at 95% and Monk clears either one on gear alone, so the extra 4% was free.
    if attacker:isPC() and attacker:isUsingH2H() then
        return 0.95
    end

    return super(attacker, slot)
end)

m:addOverride('xi.combat.physical.calculateAttackDamage', function(actor, target, slot, physicalAttackType, isH2H, isFirstSwing, isSneakAttack, isTrickAttack, damageRatio)
    local damage = super(actor, target, slot, physicalAttackType, isH2H, isFirstSwing, isSneakAttack, isTrickAttack, damageRatio)

    if isH2H and actor:isPC() then
        damage = math.floor(damage * handToHandDamage)
    end

    return damage
end)

m:addOverride('xi.weaponskills.calculateRawWSDmg', function(attacker, target, wsID, tp, action, wsParams, calcParams)
    local result = super(attacker, target, wsID, tp, action, wsParams, calcParams)

    if
        attacker:isPC() and
        attacker:isUsingH2H() and
        calcParams.attackInfo.slot ~= xi.slot.RANGED
    then
        result.finalDmg = result.finalDmg * handToHandDamage
    end

    return result
end)

return m
