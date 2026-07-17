-----------------------------------
-- Celennia Memorial Library test instance
-- !libraryinstance
-----------------------------------
local libraryInstance = require('scripts/globals/library_instance')

local instanceObject = {}

instanceObject.onInstanceCreated = function(instance)
end

instanceObject.onInstanceCreatedCallback = function(player, instance)
    libraryInstance.onCreated(player, instance)
end

instanceObject.afterInstanceRegister = function(player)
end

instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
end

instanceObject.onInstanceFailure = function(instance)
    libraryInstance.onFailure(instance)
end

instanceObject.onInstanceComplete = function(instance)
    libraryInstance.onComplete(instance)
end

return instanceObject
