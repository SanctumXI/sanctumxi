-----------------------------------
-- Tornado Edge
-- Family: Bloodcrown Brradhod
-- Description: Deals high physical damage in a 20-yalm frontal cone.
-- Additional Effect: HP Down, MP Down, Max TP Down
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage         = mob:getWeaponDmg()
    params.numHits            = 3
    params.fTP                = { 5.0, 5.0, 5.0 }
    params.accuracyModifier   = { 50, 50, 50 }
    params.guaranteedFirstHit = true
    params.attackType         = xi.attackType.PHYSICAL
    params.damageType         = xi.damageType.SLASHING
    params.shadowBehavior     = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        local duration = xi.mobskills.calculateDuration(skill:getTP(), 30, 90)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.MAX_HP_DOWN, 50, 0, duration)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.MAX_MP_DOWN, 50, 0, duration)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.MAX_TP_DOWN, 50, 0, duration)
    end

    return info.damage
end

return mobskillObject
