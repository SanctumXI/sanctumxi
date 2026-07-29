-----------------------------------
-- Barofield
-- Family: Hydra
-- Description: Deals Wind damage to enemies within a fan-shaped area.
-- Additional Effect: Bind, Blind
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params      = {}
    local customFTP   = mob:getLocalVar('BarofieldFTP')
    local fTP         = customFTP > 0 and customFTP / 100 or 4

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { fTP, fTP, fTP }
    params.element        = xi.element.WIND
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WIND
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BIND, 1, 0, 30)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 50, 0, 30)
    end

    return info.damage
end

return mobskillObject
