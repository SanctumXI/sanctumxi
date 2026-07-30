-----------------------------------
-- Howl
--
-- Description: Grants the effect of Warcry to user and any linked allies.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self and nearby mobs of same family and/or force up to 20'.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

local defaultPower = 25
local orcPower     = 50

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local power = skill:getID() == xi.mobSkill.HOWL_ORC and orcPower or defaultPower

    -- Warcry applies both ATTP and RATTP, so Orc Howl boosts melee and ranged attacks.
    skill:setMsg(xi.mobskills.mobBuffMove(mob, xi.effect.WARCRY, power, 0, 180))

    return xi.effect.WARCRY
end

return mobskillObject
