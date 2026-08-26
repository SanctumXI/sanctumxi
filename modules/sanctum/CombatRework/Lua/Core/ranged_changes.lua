-- Sanctum ranged-combat changes.
--
-- Guns and crossbows are fully effective at any distance. Bows, cannons and
-- thrown weapons need room to work: inside the minimum distance they lose a
-- flat share of their ranged attack and accuracy, with no falloff anywhere
-- else. Maximum firing range is untouched.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ranged_changes')

m:addOverride('xi.combat.physical.criticalRateFromAGIDiff', function(actor, target)
    local dAgi = math.max(0, actor:getStat(xi.mod.AGI) - target:getStat(xi.mod.AGI))

    return math.floor(dAgi / 10) / 100
end)

m:addOverride('xi.combat.physical.calculateRangedCriticalRate', function(actor, target, actorTP, slot, optCritModTable)
    local tpFactor = 0

    if optCritModTable then
        tpFactor = xi.combat.physical.calculateTPfactor(actorTP, optCritModTable)
    end

    local criticalRate =
        0.05 +
        xi.combat.physical.criticalRateFromAGIDiff(actor, target) +
        xi.combat.physical.criticalRateFromInnin(actor, target) +
        xi.combat.physical.criticalRateFromFencer(actor) +
        xi.combat.physical.criticalRateFromFlourish(actor) +
        xi.combat.physical.criticalRateFromWeaponSlot(actor, slot) +
        actor:getMod(xi.mod.CRITHITRATE) / 100 +
        actor:getMerit(xi.merit.CRIT_HIT_RATE) / 100 -
        target:getMod(xi.mod.CRITICAL_HIT_EVASION) / 100 -
        target:getMerit(xi.merit.ENEMY_CRIT_RATE) / 100 +
        tpFactor

    return utils.clamp(criticalRate, 0.05, 1)
end)

-- Distance a bow, cannon or thrown weapon needs between the two hitboxes
-- before it reaches full effect.
local minimumDistance = 5.0

-- Share of ranged attack and accuracy lost inside that distance.
local closeRangePenalty = 0.30

-- Guns (marksmanship subskill 1) and crossbows (subskill 0) ignore distance
-- entirely. Cannons are subskill 2 and are not exempt.
local function ignoresDistance(attacker)
    if attacker:getEquippedItem(xi.slot.RANGED) == nil then
        return false -- Thrown ammo with an empty ranged slot.
    end

    local skillType    = attacker:getWeaponSkillType(xi.slot.RANGED)
    local subSkillType = attacker:getWeaponSubSkillType(xi.slot.RANGED)

    return skillType == xi.skill.MARKSMANSHIP and (subSkillType == 0 or subSkillType == 1)
end

-- Measured between hitboxes, matching every other distance check in combat, so
-- the rule scales with the target's size instead of punishing big mobs.
local function isTooClose(attacker, defender)
    local threshold = minimumDistance + attacker:getHitboxSize() + defender:getHitboxSize()

    return attacker:checkDistance(defender) <= threshold
end

local function isPenalized(attacker, defender)
    return attacker:isPC() and not ignoresDistance(attacker) and isTooClose(attacker, defender)
end

m:addOverride('xi.combat.ranged.attackDistancePenalty', function(attacker, defender)
    if not isPenalized(attacker, defender) then
        return 0
    end

    return math.floor(attacker:getStat(xi.mod.RATT) * closeRangePenalty)
end)

m:addOverride('xi.combat.ranged.accuracyDistancePenalty', function(attacker, defender)
    if not isPenalized(attacker, defender) then
        return 0
    end

    return math.floor(attacker:getRACC() * closeRangePenalty)
end)

return m
