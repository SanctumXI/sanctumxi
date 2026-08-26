-----------------------------------
-- Player-applied crowd control can end early, with a visible warning.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('UnreliableStatuses')

local checkIntervalMs = 12000
local warningMs       = 4000
local wakeChance      = 8
local warningRange    = 50
local sleepTokenVar   = 'UnreliableStatuses:SleepToken'
local exemptVar       = 'UnreliableStatuses:Exempt'

xi.sanctum = xi.sanctum or {}
xi.sanctum.unreliableStatuses = xi.sanctum.unreliableStatuses or { generation = 0 }
local state = xi.sanctum.unreliableStatuses

local function isPlayerApplied(target, effect)
    local originId = effect:getOriginID()
    if originId == 0 or originId == target:getID() then
        return false
    end

    local origin = GetPlayerByID(originId)
    if not origin then
        origin = GetEntityByID(originId, target:getInstance(), true)
        if
            not origin or
            origin:getID() ~= originId or
            (not origin:isPet() and not origin:isMob())
        then
            return false
        end

        origin = origin:getMaster()
    end

    return origin ~= nil and
        origin:isPC() and
        origin:getZoneID() == target:getZoneID() and
        origin:getInstance() == target:getInstance()
end

local function currentSleep(target, application)
    if
        application.warned or
        target:getLocalVar(sleepTokenVar) ~= application.token or
        target:getLocalVar(exemptVar) ~= 0 or
        not target:isSpawned() or
        target:isDead() or
        target:getAllegiance() ~= xi.allegiance.MOB
    then
        return nil
    end

    return target:getStatusEffect(application.effectId)
end

local function warn(target, application)
    application.warned = true

    -- This helper only broadcasts the proc animation; it does not apply Terror.
    target:weaknessTrigger(1)

    local name = target:getPacketName()
    if name == '' then
        name = target:getName()
    end

    local message  = string.format('%s begins to stir!', name:gsub('_', ' '))
    local instance = target:getInstance()
    for _, player in pairs(target:getZone():getPlayers()) do
        if
            player:getInstance() == instance and
            player:checkDistance(target) <= warningRange
        then
            player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
        end
    end
end

local scheduleCheck
scheduleCheck = function(target, application)
    local effect = currentSleep(target, application)
    if not effect then
        return
    end

    local remaining = effect:getTimeRemaining()
    if remaining == 0 then
        return
    end

    if remaining <= warningMs then
        warn(target, application)
        return
    end

    local elapsed = effect:getDuration() - remaining
    local delay   = math.max(1, math.min(application.nextCheck - elapsed, remaining - warningMs))

    -- Retain only the application token, never status-effect userdata that can be deleted.
    target:timer(delay, function(mob)
        local activeEffect = currentSleep(mob, application)
        if not activeEffect then
            return
        end

        local timeLeft = activeEffect:getTimeRemaining()
        if timeLeft == 0 then
            return
        end

        if timeLeft <= warningMs then
            warn(mob, application)
            return
        end

        local age = activeEffect:getDuration() - timeLeft
        if age >= application.nextCheck then
            -- Do not run a burst of catch-up rolls after a stalled server tick.
            application.nextCheck = age + checkIntervalMs
            if math.randomInt(1, 100) <= wakeChance then
                activeEffect:setDuration(age + warningMs)
                warn(mob, application)
                return
            end
        end

        scheduleCheck(mob, application)
    end)
end

for _, scriptName in ipairs({ 'sleep', 'lullaby' }) do
    m:addOverride(string.format('xi.effects.%s.onEffectGain', scriptName), function(target, effect)
        super(target, effect)

        if not target:isMob() then
            return
        end

        target:setLocalVar(sleepTokenVar, 0)
        if
            target:getAllegiance() ~= xi.allegiance.MOB or
            target:getLocalVar(exemptVar) ~= 0 or
            effect:getTier() >= 4 or
            effect:getPower() == 255 or
            effect:getDuration() == 0 or
            not isPlayerApplied(target, effect)
        then
            return
        end

        state.generation = state.generation + 1
        target:setLocalVar(sleepTokenVar, state.generation)
        scheduleCheck(target,
        {
            token     = state.generation,
            effectId  = effect:getEffectType(),
            nextCheck = checkIntervalMs,
            warned    = false,
        })
    end)

    m:addOverride(string.format('xi.effects.%s.onEffectLose', scriptName), function(target, effect)
        if target:isMob() then
            target:setLocalVar(sleepTokenVar, 0)
        end

        super(target, effect)
    end)
end

return m
