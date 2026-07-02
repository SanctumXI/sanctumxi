-----------------------------------
-- Demonic Howl
-- Description : Slows enemies within a 10' radius area around the user.
-- Radius: 10 yalms
-- NOTE: Can be overridden by Haste.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW, 4000, 0, 180))

    return xi.effect.SLOW
end

return mobskillObject
