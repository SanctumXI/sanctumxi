-----------------------------------
-- Shared Linkshell Concierge behaviour for city placements.
-----------------------------------
local libraryInstance = require('scripts/globals/library_instance')

local concierge = {}
local confirmationVar = 'SanctumLibraryConciergeConfirm'

concierge.onTrigger = function(player, npc)
    if player:getLocalVar(confirmationVar) == 1 then
        player:setLocalVar(confirmationVar, 0)
        player:printToPlayer('Now opening your Linkshell library', xi.msg.channel.SYSTEM_3)
        libraryInstance.enterRegistered(player)
        return
    end

    player:printToPlayer('Welcome to the Linkshell Concierge.', xi.msg.channel.SYSTEM_3)

    if not libraryInstance.register(player) then
        player:setLocalVar(confirmationVar, 0)
        return
    end

    player:printToPlayer(
        string.format('Registered linkshell: %s.', libraryInstance.getRegisteredLinkshellName(player)),
        xi.msg.channel.SYSTEM_3
    )

    player:setLocalVar(confirmationVar, 1)
    player:printToPlayer(
        'Your linkshell Library is ready. Speak with me again to enter.',
        xi.msg.channel.SYSTEM_3
    )
end

return concierge