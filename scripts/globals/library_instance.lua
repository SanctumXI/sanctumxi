-----------------------------------
-- Celennia Memorial Library instance configuration
-----------------------------------
local instanceManager = require('scripts/globals/sanctum/instance_manager')

local libraryInstance = {}

libraryInstance.id = 28400

libraryInstance.configs =
{
    A =
    {
        definitionId    = libraryInstance.id,
        destinationZone = xi.zone.CELENNIA_MEMORIAL_LIBRARY,
        exitZone        = xi.zone.EASTERN_ADOULIN,
        exitPosition    = { x = -86.2, y = -0.15, z = -76, rot = 220 },
        copyKey         = 'library_a',
    },
    B =
    {
        definitionId    = libraryInstance.id,
        destinationZone = xi.zone.CELENNIA_MEMORIAL_LIBRARY,
        exitZone        = xi.zone.EASTERN_ADOULIN,
        exitPosition    = { x = -86.2, y = -0.15, z = -76, rot = 220 },
        copyKey         = 'library_b',
    },
}

local function getConfig(copyName)
    return libraryInstance.configs[string.upper(copyName or '')]
end

libraryInstance.enterCopy = function(player, copyName)
    local config = getConfig(copyName)
    if not config then
        player:printToPlayer('Invalid Library test copy.')
        return false
    end

    return instanceManager.enter(player, config)
end

libraryInstance.enter = function(player)
    return libraryInstance.enterCopy(player, 'A')
end

libraryInstance.clearCopy = function(copyName)
    local config = getConfig(copyName)
    return config and instanceManager.clear(config, true) or false
end

libraryInstance.clearCopies = function()
    libraryInstance.clearCopy('A')
    libraryInstance.clearCopy('B')
end

libraryInstance.getRuntimeID = function(copyName)
    local config = getConfig(copyName)
    return config and instanceManager.getRuntimeID(config) or nil
end

libraryInstance.onCreated = function(player, instance)
    return instanceManager.onInstanceCreated(player, instance)
end

libraryInstance.onFailure = function(instance)
    return instanceManager.onInstanceFailure(instance)
end

libraryInstance.onComplete = function(instance)
    return instanceManager.onInstanceComplete(instance)
end

return libraryInstance
