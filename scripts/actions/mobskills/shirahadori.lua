-----------------------------------
-- Shirahadori
-- Family: Yagudo
-- Description: Greatly boosts parry rate for a short time.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local duration = 30000

    mob:addMod(xi.mod.PARRY, 500)
    mob:queue(duration, function(mobArg)
        mobArg:delMod(xi.mod.PARRY, 500)
    end)

    skill:setMsg(xi.msg.basic.NONE)

    return 0
end

return mobskillObject
