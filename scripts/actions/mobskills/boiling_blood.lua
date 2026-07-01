-----------------------------------
-- Boiling Blood
-- Description: Boiling Blood
-- Foe gains Haste +50% and Berserk +50%
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    xi.mobskills.mobBuffMove(mob, xi.effect.HASTE, 5000, 0, 120)
    xi.mobskills.mobBuffMove(mob, xi.effect.BERSERK, 50, 0, 120)
    skill:setMsg(xi.msg.basic.NONE)
    return 0
end

return mobskillObject
