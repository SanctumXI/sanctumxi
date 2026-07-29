-----------------------------------
-- Area: Reisenjima Henge (292)
--  HNM: Hard Mode Simurgh
-----------------------------------
mixins =
{
    require('scripts/mixins/rage'),
    require('scripts/mixins/job_special'),
}

local simurghMechanics = require('scripts/globals/sanctum/simurgh')
local ID               = zones[xi.zone.REISENJIMA_HENGE]

---@type TMobEntity
local entity = {}

local stormThresholds =
{
    80,
    60,
    40,
    20,
}

local aspectSpawnOffsets =
{
    { x =  4, z =  0 },
    { x = -4, z =  0 },
    { x =  0, z =  4 },
    { x =  0, z = -4 },
    { x =  3, z =  3 },
    { x = -3, z = -3 },
    { x =  3, z = -3 },
    { x = -3, z =  3 },
}

local stormChargeTime      = 10
local lowHpThreshold       = 20
local lowHpFocusDuration   = 3
local stationaryTime       = 30
local stationaryMoveRadius = 10
local positionPrecision    = 100
local simurghMp            = 5000

local stationaryBonuses =
{
    { xi.mod.ATT,  150 },
    { xi.mod.MATT, 100 },
}

local function configureMob(mob)
    mob:renameEntity('Simurgh', true)
    mob:setModelSize(3)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.TERROR)
    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
end

local function setCombatEnabled(mob, enabled)
    mob:setAutoAttackEnabled(enabled)
    mob:setMagicCastingEnabled(enabled)
    mob:setMobAbilityEnabled(enabled)
end

local function applyStationaryBonuses(mob, multiplier)
    for _, modifier in ipairs(stationaryBonuses) do
        mob:addMod(modifier[1], modifier[2] * multiplier)
    end
end

local function setMovementAnchor(mob)
    local position = mob:getPos()

    mob:setLocalVar('MovementAnchorX', math.floor(position.x * positionPrecision))
    mob:setLocalVar('MovementAnchorZ', math.floor(position.z * positionPrecision))
    mob:setLocalVar('StationarySince', GetSystemTime())
end

local function removeStationaryBuff(mob, silent)
    if mob:getLocalVar('StationaryBuff') == 0 then
        return
    end

    applyStationaryBonuses(mob, -1)
    mob:setLocalVar('StationaryBuff', 0)

    if not silent then
        simurghMechanics.sendMessage(mob, 'Simurgh is displaced. Its Rooted Tempest fades.')
    end
end

local function updateStationaryBuff(mob)
    local position = mob:getPos()
    local anchorX  = mob:getLocalVar('MovementAnchorX') / positionPrecision
    local anchorZ  = mob:getLocalVar('MovementAnchorZ') / positionPrecision
    local deltaX   = position.x - anchorX
    local deltaZ   = position.z - anchorZ

    if deltaX * deltaX + deltaZ * deltaZ >= stationaryMoveRadius * stationaryMoveRadius then
        removeStationaryBuff(mob)
        setMovementAnchor(mob)
    elseif
        mob:getLocalVar('StationaryBuff') == 0 and
        GetSystemTime() - mob:getLocalVar('StationarySince') >= stationaryTime
    then
        applyStationaryBonuses(mob, 1)
        mob:setLocalVar('StationaryBuff', 1)
        simurghMechanics.sendMessage(mob, 'Simurgh invokes Rooted Tempest after holding its ground!')
    end
end

local function spawnRandomAspects(mob, target, stage)
    local availableAspects = {}

    for index = 1, #ID.mob.HARD_MODE_SIMURGH_ASPECTS do
        if mob:getLocalVar('AspectUsed' .. index) == 0 then
            table.insert(availableAspects, index)
        end
    end

    for spawnIndex = 1, math.min(2, #availableAspects) do
        local selectionPosition = math.randomInt(1, #availableAspects)
        local aspectIndex       = table.remove(availableAspects, selectionPosition)
        local aspectId          = ID.mob.HARD_MODE_SIMURGH_ASPECTS[aspectIndex]
        local aspect            = GetMobByID(aspectId, mob:getInstance())
        local offset            = aspectSpawnOffsets[(stage - 1) * 2 + spawnIndex]

        mob:setLocalVar('AspectUsed' .. aspectIndex, 1)

        if aspect then
            local position = mob:getPos()

            aspect:setSpawn(position.x + offset.x, position.y, position.z + offset.z, position.rot)
            aspect = SpawnMob(aspectId, mob:getInstance())

            if aspect and aspect:isAlive() and target then
                aspect:updateEnmity(target)
            end
        end
    end
end

local function finishStormCharge(mob)
    if mob:getLocalVar('StormChargeActive') == 0 then
        return
    end

    setCombatEnabled(mob, true)
    mob:setLocalVar('StormChargeActive', 0)
end

local function startStormCharge(mob, target, stage)
    mob:setLocalVar('StormStage', stage)
    mob:setLocalVar('StormChargeActive', 1)
    setCombatEnabled(mob, false)

    simurghMechanics.sendMessage(mob, 'Simurgh stills its wings and gathers a catastrophic storm!')
    spawnRandomAspects(mob, target, stage)

    mob:timer(stormChargeTime * 1000, function(simurgh)
        if not simurgh:isAlive() or simurgh:getLocalVar('StormChargeActive') == 0 then
            return
        end

        local stormTarget = simurgh:getTarget()

        if not stormTarget then
            finishStormCharge(simurgh)
            return
        end

        simurgh:setMobAbilityEnabled(true)
        simurgh:useMobAbility(xi.mobSkill.HM_STORMWIND, stormTarget, 0, true)

        -- Safety fallback in case the forced ability cannot resolve.
        simurgh:timer(2000, function(simurghArg)
            if simurghArg:isAlive() then
                finishStormCharge(simurghArg)
            end
        end)
    end)
end

local function restoreNormalEnmity(mob, disabledTargets)
    for _, disabledTarget in ipairs(disabledTargets) do
        mob:setEnmityActive(disabledTarget, true)
    end

    mob:updateTarget()
end

local function startLowHpFocus(mob, focusTarget)
    local disabledTargets = {}

    mob:setLocalVar('LowHpSeen' .. focusTarget:getID(), 1)
    mob:setLocalVar('LowHpFocusActive', 1)

    for _, enmityEntry in ipairs(mob:getEnmityList()) do
        if enmityEntry.entity:getID() ~= focusTarget:getID() then
            mob:setEnmityActive(enmityEntry.entity, false)
            table.insert(disabledTargets, enmityEntry.entity)
        end
    end

    mob:updateTarget()
    simurghMechanics.sendMessage(mob, string.format('Simurgh marks %s for death', focusTarget:getName()))

    mob:timer(lowHpFocusDuration * 1000, function(simurgh)
        if not simurgh:isAlive() then
            return
        end

        if
            focusTarget:isAlive() and
            focusTarget:getZoneID() == simurgh:getZoneID() and
            focusTarget:getHPP() < lowHpThreshold
        then
            simurgh:setLocalVar('ForcedAbilityActive', 1)
            simurgh:useMobAbility(xi.mobSkill.DREAD_DIVE_1, focusTarget, nil, true)

            simurgh:timer(3000, function(simurghArg)
                if simurghArg:isAlive() then
                    simurghArg:setLocalVar('ForcedAbilityActive', 0)
                end
            end)
        else
            simurghMechanics.sendMessage(simurgh, string.format(
                '%s escapes Simurgh\'s Dread Dive.',
                focusTarget:getName()
            ))
        end

        restoreNormalEnmity(simurgh, disabledTargets)
        simurgh:setLocalVar('LowHpFocusActive', 0)
    end)
end

local function checkLowHpPlayers(mob)
    local focusTarget = nil

    for _, enmityEntry in ipairs(mob:getEnmityList()) do
        local enmityTarget = enmityEntry.entity

        if
            enmityTarget and
            enmityTarget:isPC() and
            enmityTarget:isAlive()
        then
            local markerName = 'LowHpSeen' .. enmityTarget:getID()

            if enmityTarget:getHPP() >= lowHpThreshold then
                mob:setLocalVar(markerName, 0)
            elseif mob:getLocalVar(markerName) == 0 and not focusTarget then
                focusTarget = enmityTarget
            end
        end
    end

    if focusTarget then
        startLowHpFocus(mob, focusTarget)
    end
end

entity.onMobInitialize = function(mob)
    configureMob(mob)
end

entity.onMobSpawn = function(mob)
    configureMob(mob)
    mob:setMaxMP(simurghMp)
    mob:setMP(simurghMp)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 250)
    mob:setMod(xi.mod.EVA, 400)
    mob:setMod(xi.mod.ACC, 519)

    setCombatEnabled(mob, true)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 0)
    mob:setLocalVar('StormStage', 0)
    mob:setLocalVar('StormChargeActive', 0)
    mob:setLocalVar('LowHpFocusActive', 0)
    mob:setLocalVar('ForcedAbilityActive', 0)
    mob:setLocalVar('StationaryBuff', 0)

    for index = 1, #ID.mob.HARD_MODE_SIMURGH_ASPECTS do
        mob:setLocalVar('AspectUsed' .. index, 0)
        mob:setLocalVar('AspectBuff' .. index, 0)
    end

    local instance = mob:getInstance()
    if instance then
        for _, player in ipairs(instance:getChars()) do
            mob:setLocalVar('LowHpSeen' .. player:getID(), 0)
        end
    end

    simurghMechanics.cleanupAdds(mob)
    setMovementAnchor(mob)
end

entity.onMobEngage = function(mob, target)
    removeStationaryBuff(mob, true)
    setMovementAnchor(mob)
end

entity.onMobFight = function(mob, target)
    simurghMechanics.syncAspectBuffs(mob)
    updateStationaryBuff(mob)

    local drawInTable =
    {
        conditions =
        {
            target:checkDistance(mob) > mob:getMeleeRange(target),
        },
        position = mob:getPos(),
        offset   = 5,
        degrees  = 180,
        wait     = 10,
    }

    utils.drawIn(target, drawInTable)

    if
        mob:getLocalVar('StormChargeActive') == 1 or
        mob:getLocalVar('ForcedAbilityActive') == 1
    then
        return
    end

    if mob:getLocalVar('LowHpFocusActive') == 0 then
        local nextStage = mob:getLocalVar('StormStage') + 1

        if
            nextStage <= #stormThresholds and
            mob:getHPP() <= stormThresholds[nextStage]
        then
            startStormCharge(mob, target, nextStage)
            return
        end

        checkLowHpPlayers(mob)
    end
end

entity.onAdditionalEffect = function(mob, target, damage)
    if mob:getLocalVar('AspectBuff8') == 0 then
        return 0, 0, 0
    end

    local effect =
    {
        chance         = 100,
        attackType     = xi.attackType.MAGICAL,
        magicalElement = xi.element.WIND,
        basePower      = math.randomInt(50, 75),
    }

    return xi.combat.action.executeAddEffectDamage(mob, target, effect)
end

entity.onMobWeaponSkill = function(mob, target, skill, action)
    if skill:getID() == xi.mobSkill.HM_STORMWIND then
        simurghMechanics.sendMessage(mob, 'Simurgh unleashes its catastrophic Stormwind!')
        finishStormCharge(mob)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    removeStationaryBuff(mob, true)
    simurghMechanics.cleanupAdds(mob)
end

entity.onMobDespawn = function(mob)
    removeStationaryBuff(mob, true)
    simurghMechanics.cleanupAdds(mob)
end

return entity
