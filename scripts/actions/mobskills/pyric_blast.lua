-----------------------------------
-- Pyric Blast
-- Family: Hydra
-- Description: Deals Fire damage to enemies within a fan-shaped area. Additional Effect: Plague
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- Only used when all 3 heads are alive.
    if mob:getAnimationSub() == 0 then
        -- TODO: Does this need an inFront() check?
        return 0
    else
        return 1
    end
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params             = {}
    local magicAccuracyBonus = mob:getLocalVar('HydraBlastMacc')

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 8.5, 8.5, 8.5 }
    params.mACCBonus      = { magicAccuracyBonus, magicAccuracyBonus, magicAccuracyBonus }
    params.element        = xi.element.FIRE
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.FIRE
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PLAGUE, 5, 3, 60) -- TODO: Capture power/duration
    end

    if
        mob:getPool() == xi.mobPool.TINNIN and
        bit.band(mob:getBehavior(), xi.behavior.NO_TURN) == 0
    then
        -- re-enable no turn if all three heads are up
        mob:setBehavior(bit.bor(mob:getBehavior(), xi.behavior.NO_TURN))
    end

    return info.damage
end

return mobskillObject
