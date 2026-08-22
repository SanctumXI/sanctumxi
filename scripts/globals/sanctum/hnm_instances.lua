-----------------------------------
-- Optional Sanctum HNM arena configuration helpers
-----------------------------------
local instanceManager = require('scripts/globals/sanctum/instance_manager')

local hnmInstances = {}

hnmInstances.id = 29200

hnmInstances.reisenjimaHenge =
{
    definitionId    = hnmInstances.id,
    destinationZone = xi.zone.REISENJIMA_HENGE,
    exitZone        = xi.zone.REISENJIMA,
    exitPosition    = { x = -500.023, y = -19.074, z = -487.686, rot = 190 },
    copyKey         = 'henge_hnm_test',
    creationTimeoutMs =
        xi.settings and
        xi.settings.sanctum and
        xi.settings.sanctum.HNM_INSTANCE_CREATION_TIMEOUT or
        60 * 1000,
    idleTimeoutSeconds =
        xi.settings and
        xi.settings.sanctum and
        xi.settings.sanctum.HNM_INSTANCE_IDLE_TIMEOUT or
        5 * 60,
    maxActiveCopies =
        xi.settings and
        xi.settings.sanctum and
        xi.settings.sanctum.HNM_MAX_ACTIVE_INSTANCES or
        16,
    sleepWhenEmpty = true,
}

hnmInstances.enterTest = function(player)
    return instanceManager.enter(player, hnmInstances.reisenjimaHenge)
end

hnmInstances.clearTest = function()
    return instanceManager.clear(hnmInstances.reisenjimaHenge, true)
end

hnmInstances.getRuntimeID = function()
    return instanceManager.getRuntimeID(hnmInstances.reisenjimaHenge)
end

hnmInstances.onCreated = function(player, instance)
    return instanceManager.onInstanceCreated(player, instance)
end

hnmInstances.onFailure = function(instance)
    return instanceManager.onInstanceFailure(instance)
end

hnmInstances.onComplete = function(instance)
    return instanceManager.onInstanceComplete(instance)
end

hnmInstances.onTimeUpdate = function(instance, elapsed)
    return instanceManager.onInstanceTimeUpdate(instance, elapsed)
end

-- Example only: the caller must supply a new server-side instance_list ID.
-- This does not register an encounter or change any content.
hnmInstances.createRalaWaterwaysExample = function(definitionId, copyKey, accessCheck)
    return
    {
        definitionId    = definitionId,
        destinationZone = xi.zone.RALA_WATERWAYS_U,
        exitZone        = xi.zone.RALA_WATERWAYS,
        copyKey         = copyKey,
        canEnter        = accessCheck or function()
            return true
        end,
    }
end

return hnmInstances
