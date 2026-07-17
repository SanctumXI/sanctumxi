-----------------------------------
-- func: !instancecheck
-- desc: Display current zone and instance information
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = '',
}

commandObj.onTrigger = function(player)
    local instance = player:getInstance()

    player:printToPlayer(string.format(
        'Current zone ID: %u',
        player:getZoneID()
    ))

    if instance then
        player:printToPlayer(string.format(
            'Current instance definition ID: %u, runtime ID: %u',
            instance:getID(),
            instance:getRuntimeID()
        ))
    else
        player:printToPlayer('Current instance: NONE')
    end
end

return commandObj
