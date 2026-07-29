-----------------------------------
-- Lightning Spear
-- Family: Monoceros (Dark Ixion)
-- Description: Long, narrow line-shaped Thunder damage (600-1500). Additional Effect: Shock
-- Notes: Will pick a random person on the hate list for this attack.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 60.0, 60.0, 60.0 }
    params.element        = xi.element.THUNDER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.THUNDER
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        local duration = xi.mobskills.calculateDuration(skill:getTP(), 30, 120)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SHOCK, 40, 3, duration)
    end

    return info.damage
end

return mobskillObject
