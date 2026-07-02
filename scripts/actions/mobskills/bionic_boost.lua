-----------------------------------
-- Bionic Boost
-- Description: Gives the user the effect of counterstance (+15% counter rate) for 60 seconds. (Counter Rate could use additional testing.)
-- Boosts attack by 15%. Does not lower defense.
-- Type: Buff
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local typeEffect = xi.effect.COUNTERSTANCE

    skill:setMsg(xi.mobskills.mobBuffMove(mob, typeEffect, 30, 1, 90))
    return typeEffect
end

return mobskillObject
