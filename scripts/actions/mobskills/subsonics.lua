-----------------------------------
-- Subsonics
-- Family: Big Bat (Single Bat)
-- Description: Lower defense
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 30, 0, 90))

    return xi.effect.DEFENSE_DOWN
end

return mobskillObject
