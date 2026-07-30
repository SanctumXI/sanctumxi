-----------------------------------
-- Desiccation
-- Family: Sandworm
-- Description: Deals Wind damage to targets in a cone in front of the user, around
--              whoever currently holds the most hate. Consumes all job abilities
--              (Additional Effect: Amnesia).
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    -- Average damage is 50% higher, with TP-based variance instead of a fixed result.
    params.fTP            = { 3.375, 3.75, 4.125 }
    params.element        = xi.element.WIND
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WIND
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        target:maxAbilityRecasts()
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.AMNESIA, 1, 0, 60)
    end

    return info.damage
end

return mobskillObject
