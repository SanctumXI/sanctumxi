-----------------------------------
-- func: ra repeat
-- desc: Toggles automatic ranged attack repeat. While it is on and the player
--     : is engaged with a weapon drawn, ranged attacks fire on their own.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's'
}

commandObj.onTrigger = function(player, mode)
    if mode ~= 'repeat' then
        player:printToPlayer('Usage: !ra repeat')
        return
    end

    if player:getLocalVar('rangedRepeat') == 1 then
        player:setLocalVar('rangedRepeat', 0)
        player:printToPlayer('Ranged attack repeat off.')
    else
        player:setLocalVar('rangedRepeat', 1)
        player:printToPlayer('Ranged attack repeat on.')
    end
end

return commandObj
