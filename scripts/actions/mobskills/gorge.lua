-----------------------------------
-- Gorge
-- Family: Sandworm
-- Description: Drains HP from targets in a frontal cone, splitting the damage
--              between everyone hit. Also consumes each target's Food effect.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params      = {}
    local targetCount = math.max(1, skill:getTotalTargets())

    -- 25% above the previous boosted damage, divided evenly across the cone.
    params.baseDamage         = (mob:getMainLvl() + 2) * 3 / targetCount
    params.fTP                = { 4.375, 4.375, 4.375 }
    params.element            = xi.element.NONE
    params.attackType         = xi.attackType.MAGICAL
    params.damageType         = xi.damageType.NONE
    params.shadowBehavior     = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.skipMagicBonusDiff = true

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        skill:setMsg(xi.mobskills.mobDrainMove(mob, target, xi.mobskills.drainType.HP, info.damage))

        target:delStatusEffectSilent(xi.effect.FOOD)
    end

    return info.damage
end

return mobskillObject
