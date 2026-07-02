-----------------------------------
-- Cimicine Discharge
-- Reduces the attack speed of enemies within range.
-- Also grants Haste to the user.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local slowPower  = 2000
    local hastePower = 2000
    local duration   = math.random(60, 90)

    -- Give Haste to the mob using the skill.
    if not mob:hasStatusEffect(xi.effect.HASTE) then
        xi.mobskills.mobBuffMove(mob, xi.effect.HASTE, hastePower, 0, duration)
    end

    -- Apply Slow to the target and use Slow as the displayed message.
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW, slowPower, 0, duration))

    return xi.effect.SLOW
end

return mobskillObject
