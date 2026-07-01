-----------------------------------
-- Exuviation
-- Family: Wamoura
-- Type: Healing and Full Erase
-- Range: Self
-- Notes: Erases all negative effects on the mob and heals an amount for each removed.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local effectCount = 0
    local dispel = mob:eraseStatusEffect()

    while (dispel ~= xi.effect.NONE)
    do
        effectCount = effectCount + 1
        dispel = mob:eraseStatusEffect()
    end

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    return xi.mobskills.mobHealMove(mob, (700 + (mob:getMainLvl() - 70) * 12) * effectCount)
end

return mobskillObject
