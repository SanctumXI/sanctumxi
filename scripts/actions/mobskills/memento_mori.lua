-----------------------------------
-- Memento Mori
-- Enhances Magic Attack.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobBuffMove(mob, xi.effect.MAGIC_ATK_BOOST, 50, 0, 45))

    return xi.effect.MAGIC_ATK_BOOST
end

return mobskillObject
