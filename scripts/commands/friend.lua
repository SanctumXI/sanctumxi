-----------------------------------
-- func: friend <add|accept|decline|remove|list> <character>
-- desc: Manage Sanctum's mutual friends list.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 'ss'
}

local function usage(player)
    player:printToPlayer('Usage: !friend add|accept|decline|remove <name>, or !friend list', xi.msg.channel.SYSTEM_3, 'Friends')
end

commandObj.onTrigger = function(player, action, targetName)
    action = string.lower(action or '')

    if action == 'list' then
        player:printToPlayer(xi.sanctumFriends.list(player), xi.msg.channel.SYSTEM_3, 'Friends')
        return
    end

    if targetName == nil or targetName == '' then
        usage(player)
        return
    end

    local result
    if action == 'add' then
        result = xi.sanctumFriends.request(player, targetName)
    elseif action == 'accept' then
        result = xi.sanctumFriends.accept(player, targetName)
    elseif action == 'decline' then
        result = xi.sanctumFriends.decline(player, targetName)
    elseif action == 'remove' then
        result = xi.sanctumFriends.remove(player, targetName)
    else
        usage(player)
        return
    end

    player:printToPlayer(result, xi.msg.channel.SYSTEM_3, 'Friends')
end

return commandObj

