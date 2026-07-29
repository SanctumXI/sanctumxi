-----------------------------------
-- Shirahadori
-- Family: Yagudo
-- Description: Deals physical damage in a frontal cone.
-- Additional Effect: TP reset, Bind, Knockback
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage         = mob:getWeaponDmg()
    params.numHits            = 1
    params.fTP                = { 2.5, 2.5, 2.5 }
    params.accuracyModifier   = { 50, 50, 50 }
    params.guaranteedFirstHit = true
    params.attackType         = xi.attackType.PHYSICAL
    params.damageType         = xi.damageType.PIERCING
    params.shadowBehavior     = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
        target:setTP(0)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BIND, 1, 0, 20)
    end

    return info.damage
end

return mobskillObject
