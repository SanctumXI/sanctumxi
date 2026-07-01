-----------------------------------
-- Gates of Hades
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if mob:getHPP() < 25 then
        return 0
    end

    return 1
end

local function isInCone(mob, target, range, coneAngle)
    local mobPos = mob:getPos()
    local tgtPos = target:getPos()

    local dx = tgtPos.x - mobPos.x
    local dz = tgtPos.z - mobPos.z
    local dist = math.sqrt(dx * dx + dz * dz)

    if dist > range then
        return false
    end

    local angleToTarget = math.atan2(dx, dz)
    local mobHeading = mob:getHeading()

    local diff = angleToTarget - mobHeading

    while diff > math.pi do
        diff = diff - (2 * math.pi)
    end
    while diff < -math.pi do
        diff = diff + (2 * math.pi)
    end

    return math.abs(diff) <= (coneAngle / 2)
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage = mob:getMainLvl()
    params.fTP = { 12.5, 12.5, 12.5 }
    params.element = xi.element.FIRE
    params.attackType = xi.attackType.MAGICAL
    params.damageType = xi.damageType.FIRE
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS
    params.dStatMultiplier = 1

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    local coneRange = 20
    local coneAngle = math.rad(120)

    if isInCone(mob, target, coneRange, coneAngle) then
        if xi.mobskills.processDamage(mob, target, skill, action, info) then
            target:takeDamage(info.damage, mob, info.attackType, info.damageType)

            local power = 30
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BURN, power, 3, 60)
        end

        return info.damage
    end

    return 0
end

return mobskillObject
