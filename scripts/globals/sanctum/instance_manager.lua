-----------------------------------
-- Reusable Sanctum runtime instance manager
-----------------------------------
local instanceManager = {}

local defaultCreationTimeoutMs = 30000
local copyStates              = {}
local pendingByRequester      = {}
local requesterBlockedUntil   = {}
local stateKeyByRuntimeId     = {}
local nextRequestToken        = 0

local function log(config, message)
    print(string.format('[SanctumInstance:%s] %s', config.copyKey, message))
end

local function validateConfig(config)
    if
        type(config) ~= 'table' or
        type(config.definitionId) ~= 'number' or
        type(config.destinationZone) ~= 'number' or
        type(config.exitZone) ~= 'number' or
        type(config.copyKey) ~= 'string' or
        config.copyKey == ''
    then
        return false, 'Invalid Sanctum instance configuration.'
    end

    return true
end

local function getStateKey(config)
    return string.format('%u:%u:%s', config.destinationZone, config.definitionId, config.copyKey)
end

local function getState(config)
    local stateKey = getStateKey(config)
    local state    = copyStates[stateKey]

    if not state then
        state =
        {
            config         = config,
            creating       = false,
            requestToken   = 0,
            requesterId    = 0,
            creationStart  = 0,
            runtimeId      = nil,
            waitingPlayers = {},
        }

        copyStates[stateKey] = state
    else
        state.config = config
    end

    return stateKey, state
end

local function checkAccess(player, config)
    if not config.canEnter then
        return true
    end

    local allowed, message = config.canEnter(player)
    if not allowed then
        player:printToPlayer(message or 'You do not meet this instance\'s entry requirements.')
        return false
    end

    return true
end

local function clearPendingRequest(stateKey, state)
    local pending = pendingByRequester[state.requesterId]
    if
        pending and
        pending.stateKey == stateKey and
        pending.requestToken == state.requestToken
    then
        pendingByRequester[state.requesterId] = nil
    end

    state.creating      = false
    state.requestToken  = 0
    state.requesterId   = 0
    state.creationStart = 0
end

local function cancelPendingRequest(stateKey, state)
    local requesterId = state.requesterId
    if requesterId > 0 then
        local timeoutSeconds = math.ceil((state.config.creationTimeoutMs or defaultCreationTimeoutMs) / 1000)
        requesterBlockedUntil[requesterId] = GetSystemTime() + timeoutSeconds
    end

    clearPendingRequest(stateKey, state)
end

local function notifyWaiters(state, message)
    for playerId in pairs(state.waitingPlayers) do
        local player = GetPlayerByID(playerId)
        if player then
            player:printToPlayer(message)
        end
    end

    state.waitingPlayers = {}
end

local function clearRuntimeState(stateKey, state)
    if state.runtimeId then
        stateKeyByRuntimeId[state.runtimeId] = nil
        state.runtimeId = nil
    end

    clearPendingRequest(stateKey, state)
    state.waitingPlayers = {}
end

local function getDestinationZone(config)
    local zone = GetZone(config.destinationZone)
    if not zone then
        log(config, string.format('destination zone %u is not loaded on this map server', config.destinationZone))
    end

    return zone
end

local function getLiveInstance(state)
    if not state.runtimeId then
        return nil
    end

    local runtimeId = state.runtimeId
    local zone      = getDestinationZone(state.config)
    local instance  = nil

    if zone and zone:isInstanceAlive(runtimeId) then
        instance = zone:getInstanceByRuntimeID(runtimeId)
    end

    if
        not instance or
        instance:getID() ~= state.config.definitionId
    then
        log(state.config, string.format(
            'stale lookup or cleanup detected for definition %u, runtime %u',
            state.config.definitionId,
            runtimeId
        ))

        stateKeyByRuntimeId[runtimeId] = nil
        state.runtimeId = nil
        return nil
    end

    return instance
end

local function assignPlayer(player, instance, config)
    local runtimeId      = instance:getRuntimeID()
    local current        = player:getInstance()
    local currentRuntime = current and current:getRuntimeID() or nil

    if current and currentRuntime ~= runtimeId then
        if player:getZoneID() == current:getZone():getID() then
            player:printToPlayer('Leave your current instance before switching Sanctum copies.')
            return false
        end

        log(config, string.format(
            'reassigning player %s from retained runtime %u to runtime %u',
            player:getName(),
            currentRuntime,
            runtimeId
        ))
    elseif currentRuntime == runtimeId then
        log(config, string.format(
            're-entry requested by %s for definition %u, runtime %u',
            player:getName(),
            instance:getID(),
            runtimeId
        ))

        if player:getZoneID() == config.destinationZone then
            player:printToPlayer(string.format(
                'Already in definition %u, runtime %u.',
                instance:getID(),
                runtimeId
            ))

            return true
        end
    end

    local destinationZone = getDestinationZone(config)
    if not destinationZone then
        player:printToPlayer('The requested instance zone is unavailable.')
        return false
    end

    local instanceZone   = instance:getZone()
    local instanceZoneId = instanceZone and instanceZone:getID() or 0
    if
        instanceZoneId ~= config.destinationZone or
        not destinationZone:isInstanceAlive(runtimeId)
    then
        player:printToPlayer('The requested Sanctum instance is no longer available.')
        log(config, string.format(
            'pre-assignment validation failed for player %s: current zone %u, destination zone %u, definition %u, runtime %u, instance zone %u',
            player:getName(),
            player:getZoneID(),
            config.destinationZone,
            instance:getID(),
            runtimeId,
            instanceZoneId
        ))
        return false
    end

    local removedRegistrations = destinationZone:unregisterCharFromInstances(player)
    if removedRegistrations > 0 then
        log(config, string.format(
            'removed %u stale registration(s) for player %s before assigning runtime %u',
            removedRegistrations,
            player:getName(),
            runtimeId
        ))
    end

    log(config, string.format(
        'before setInstance: player %s, current zone %u, destination zone %u, definition %u, runtime %u',
        player:getName(),
        player:getZoneID(),
        config.destinationZone,
        instance:getID(),
        runtimeId
    ))

    player:setInstance(instance)

    local assignedInstance   = player:getInstance()
    local assignedDefinition = assignedInstance and assignedInstance:getID() or 0
    local assignedRuntime    = assignedInstance and assignedInstance:getRuntimeID() or 0
    local assignedZone       = assignedInstance and assignedInstance:getZone() or nil
    local assignedZoneId     = assignedZone and assignedZone:getID() or 0
    local assignedAlive      = assignedInstance and destinationZone:isInstanceAlive(assignedRuntime) or false
    local assignedToZone     = assignedInstance and assignedZoneId == config.destinationZone or false

    log(config, string.format(
        'after setInstance: player %s, assigned %s, definition %u, runtime %u, alive %s, instance zone %u, destination match %s',
        player:getName(),
        assignedInstance and 'yes' or 'no',
        assignedDefinition,
        assignedRuntime,
        tostring(assignedAlive),
        assignedZoneId,
        tostring(assignedToZone)
    ))

    if
        not assignedInstance or
        assignedDefinition ~= config.definitionId or
        assignedRuntime ~= runtimeId or
        not assignedAlive or
        not assignedToZone
    then
        player:printToPlayer('Unable to assign the requested Sanctum instance.')
        log(config, string.format('assignment failed for player %s, runtime %u', player:getName(), runtimeId))
        return false
    end

    local entryPos = instance:getEntryPos()

    log(config, string.format(
        'assigning player %s to definition %u, runtime %u',
        player:getName(),
        instance:getID(),
        runtimeId
    ))

    player:printToPlayer(string.format(
        'Entering definition %u, runtime %u.',
        instance:getID(),
        runtimeId
    ))

    log(config, string.format(
        'before setPos: player %s, assigned runtime %u, destination zone %u',
        player:getName(),
        assignedRuntime,
        config.destinationZone
    ))

    player:setPos(
        entryPos.x,
        entryPos.y,
        entryPos.z,
        entryPos.rot,
        config.destinationZone
    )

    return true
end

local function expireCreation(stateKey, state, message)
    log(state.config, string.format(
        'creation request timed out for definition %u after %u ms',
        state.config.definitionId,
        state.config.creationTimeoutMs or defaultCreationTimeoutMs
    ))

    cancelPendingRequest(stateKey, state)
    notifyWaiters(state, message or 'Instance creation timed out. Wait for the canceled request to clear, then try again.')
end

instanceManager.checkPendingCreation = function(stateKey, requestToken)
    local state = copyStates[stateKey]
    if
        not state or
        not state.creating or
        state.requestToken ~= requestToken
    then
        return
    end

    expireCreation(stateKey, state)
end

instanceManager.enter = function(player, config)
    local valid, errorMessage = validateConfig(config)
    if not valid then
        player:printToPlayer(errorMessage)
        return false
    end

    if not checkAccess(player, config) then
        return false
    end

    local stateKey, state = getState(config)
    local instance        = getLiveInstance(state)
    if instance then
        return assignPlayer(player, instance, config)
    end

    if state.creating then
        local timeoutSeconds = math.ceil((config.creationTimeoutMs or defaultCreationTimeoutMs) / 1000)
        if GetSystemTime() - state.creationStart >= timeoutSeconds then
            expireCreation(stateKey, state)
            return false
        end

        state.waitingPlayers[player:getID()] = true
        player:printToPlayer(string.format('Instance copy %s is being created.', config.copyKey))
        return true
    end

    local requesterId = player:getID()
    local blockedUntil = requesterBlockedUntil[requesterId]
    if blockedUntil and blockedUntil > GetSystemTime() then
        player:printToPlayer('A canceled Sanctum request is still being cleared. Please wait before retrying.')
        return false
    end

    requesterBlockedUntil[requesterId] = nil

    if pendingByRequester[requesterId] then
        player:printToPlayer('You already have another Sanctum instance creation pending.')
        return false
    end

    local destinationZone = getDestinationZone(config)
    if not destinationZone then
        player:printToPlayer('The requested instance zone is unavailable.')
        return false
    end

    nextRequestToken = nextRequestToken + 1

    state.creating                   = true
    state.requestToken               = nextRequestToken
    state.requesterId                = requesterId
    state.creationStart              = GetSystemTime()
    state.waitingPlayers[requesterId] = true
    pendingByRequester[requesterId]  =
    {
        stateKey     = stateKey,
        requestToken = state.requestToken,
    }

    log(config, string.format(
        'creation requested by %s for definition %u, destination zone %u',
        player:getName(),
        config.definitionId,
        config.destinationZone
    ))

    player:createInstance(config.definitionId)

    local timeoutMs    = config.creationTimeoutMs or defaultCreationTimeoutMs
    local requestToken = state.requestToken
    player:timer(timeoutMs, function()
        instanceManager.checkPendingCreation(stateKey, requestToken)
    end)

    return true
end

instanceManager.joinRuntime = function(player, config, runtimeId)
    local valid, errorMessage = validateConfig(config)
    if not valid then
        player:printToPlayer(errorMessage)
        return false
    end

    if not checkAccess(player, config) then
        return false
    end

    local zone     = getDestinationZone(config)
    local instance = zone and zone:getInstanceByRuntimeID(runtimeId) or nil
    if
        not instance or
        instance:getID() ~= config.definitionId
    then
        player:printToPlayer(string.format('Runtime instance %u is no longer available.', runtimeId))
        log(config, string.format('join failed: stale runtime %u', runtimeId))
        return false
    end

    return assignPlayer(player, instance, config)
end

instanceManager.getInstancesByDefinition = function(config)
    local valid = validateConfig(config)
    if not valid then
        return {}
    end

    local zone = getDestinationZone(config)
    return zone and zone:getInstancesByDefinition(config.definitionId) or {}
end

instanceManager.getRuntimeID = function(config)
    local valid = validateConfig(config)
    if not valid then
        return nil
    end

    local _, state = getState(config)
    local instance = getLiveInstance(state)
    return instance and instance:getRuntimeID() or nil
end

instanceManager.onInstanceCreated = function(requester, instance)
    local requesterId  = requester and requester:getID() or 0
    local pending      = pendingByRequester[requesterId]
    local definitionId = instance and instance:getID() or 0
    local runtimeId    = instance and instance:getRuntimeID() or 0

    print(string.format(
        '[SanctumInstance] creation callback received for requester %u, definition %u, runtime %u',
        requesterId,
        definitionId,
        runtimeId
    ))

    if not pending then
        requesterBlockedUntil[requesterId] = nil

        if requester then
            requester:printToPlayer('Received an instance callback with no pending Sanctum request.')
        end

        if instance then
            print(string.format('[SanctumInstance] failing orphaned runtime %u', runtimeId))
            instance:fail()
        end

        return false
    end

    local state = copyStates[pending.stateKey]
    if
        not state or
        not state.creating or
        state.requestToken ~= pending.requestToken
    then
        pendingByRequester[requesterId] = nil
        if instance then
            print(string.format('[SanctumInstance] failing stale callback runtime %u', runtimeId))
            instance:fail()
        end

        return false
    end

    local config = state.config
    clearPendingRequest(pending.stateKey, state)

    local instanceZone   = instance and instance:getZone() or nil
    local instanceZoneId = instanceZone and instanceZone:getID() or 0
    log(config, string.format(
        'creation callback: requester %s, definition %u, runtime %u, instance destination zone %u',
        requester and requester:getName() or '<none>',
        definitionId,
        runtimeId,
        instanceZoneId
    ))

    if
        not instance or
        definitionId ~= config.definitionId or
        instanceZoneId ~= config.destinationZone
    then
        notifyWaiters(state, 'Instance creation failed validation. Please try again.')
        if instance then
            instance:fail()
        end

        return false
    end

    state.runtimeId                = runtimeId
    stateKeyByRuntimeId[runtimeId] = pending.stateKey

    log(config, string.format(
        'creation callback accepted for definition %u, runtime %u',
        definitionId,
        runtimeId
    ))

    local waitingPlayers = state.waitingPlayers
    state.waitingPlayers = {}

    for playerId in pairs(waitingPlayers) do
        local player = GetPlayerByID(playerId)
        if player then
            if checkAccess(player, config) then
                assignPlayer(player, instance, config)
            end
        end
    end

    return true
end

local function finishInstance(instance, reason)
    local runtimeId = instance:getRuntimeID()
    local stateKey  = stateKeyByRuntimeId[runtimeId]
    local state     = stateKey and copyStates[stateKey] or nil

    if not state then
        print(string.format(
            '[SanctumInstance] %s callback for untracked definition %u, runtime %u',
            reason,
            instance:getID(),
            runtimeId
        ))

        return false
    end

    local config = state.config
    log(config, string.format(
        '%s cleanup for definition %u, runtime %u',
        reason,
        instance:getID(),
        runtimeId
    ))

    clearRuntimeState(stateKey, state)

    local exitPosition = config.exitPosition or { x = 0, y = 0, z = 0, rot = 0 }
    for _, player in ipairs(instance:getChars()) do
        player:setPos(
            exitPosition.x,
            exitPosition.y,
            exitPosition.z,
            exitPosition.rot,
            config.exitZone
        )
    end

    return true
end

instanceManager.onInstanceFailure = function(instance)
    return finishInstance(instance, 'failure')
end

instanceManager.onInstanceComplete = function(instance)
    return finishInstance(instance, 'completion')
end

instanceManager.clear = function(config, destroyInstance)
    local valid = validateConfig(config)
    if not valid then
        return false
    end

    local stateKey, state = getState(config)
    local instance        = getLiveInstance(state)

    notifyWaiters(state, string.format('Instance copy %s was cleared.', config.copyKey))
    if state.creating then
        cancelPendingRequest(stateKey, state)
    else
        clearPendingRequest(stateKey, state)
    end

    if instance and destroyInstance then
        log(config, string.format(
            'explicit cleanup requested for definition %u, runtime %u',
            instance:getID(),
            instance:getRuntimeID()
        ))

        instance:fail()
        return true
    end

    if instance then
        log(config, string.format('cleared copy state while leaving runtime %u alive', instance:getRuntimeID()))
    else
        log(config, 'cleared copy state with no live runtime')
    end

    clearRuntimeState(stateKey, state)
    return true
end

return instanceManager
