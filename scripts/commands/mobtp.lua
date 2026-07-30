-----------------------------------
-- func: mobtp
-- desc: Displays the current TP of the selected mob
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = '',
}

commandObj.onTrigger = function(player)
    local target = player:getCursorTarget()
    if not target or not target:isMob() then
        player:printToPlayer('Select a mob with the in-game cursor first.', xi.msg.channel.SYSTEM_3)
        return
    end

    player:printToPlayer(
        string.format('%s currently has %u TP.', target:getName(), math.floor(target:getTP())),
        xi.msg.channel.SYSTEM_3
    )
end

return commandObj
