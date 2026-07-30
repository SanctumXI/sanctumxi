-----------------------------------
-- Diamond Shell
-- Family: Za'Dha Adamantking
-- Description: Nullifies physical damage dealt from behind for 60 seconds.
-----------------------------------
local adamantking = require('scripts/globals/adamantking')

---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    adamantking.finishDiamondShell(mob)

    skill:setMsg(xi.msg.basic.NONE)

    return 0
end

return mobskillObject
