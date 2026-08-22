-----------------------------------
-- Reisenjima Henge hard-mode HNM test instance
-- !hengeinstance
-----------------------------------
local hnmInstances = require('scripts/globals/sanctum/hnm_instances')
local ID           = zones[xi.zone.REISENJIMA_HENGE]

local instanceObject = {}

instanceObject.onInstanceCreated = function(instance)
    local entityNames =
    {
        { GetMobByID(ID.mob.HARD_MODE_ROC, instance),         'Roc' },
        { GetMobByID(ID.mob.HARD_MODE_SIMURGH, instance),     'Simurgh' },
        { GetMobByID(ID.mob.HARD_MODE_KING_ARTHRO, instance), 'King Arthro' },
        { GetNPCByID(ID.npc.HARD_MODE_HNM_QM, instance),      '???' },
    }

    for _, addId in ipairs(ID.mob.HARD_MODE_KNIGHT_CRABS) do
        table.insert(entityNames, { GetMobByID(addId, instance), 'Knight Crab' })
    end

    for _, entityName in ipairs(entityNames) do
        local entity = entityName[1]
        if entity then
            entity:renameEntity(entityName[2], true)
        end
    end
end

instanceObject.onInstanceCreatedCallback = function(player, instance)
    hnmInstances.onCreated(player, instance)
end

instanceObject.afterInstanceRegister = function(player)
end

instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    hnmInstances.onTimeUpdate(instance, elapsed)
end

instanceObject.onInstanceFailure = function(instance)
    hnmInstances.onFailure(instance)
end

instanceObject.onInstanceComplete = function(instance)
    hnmInstances.onComplete(instance)
end

return instanceObject
