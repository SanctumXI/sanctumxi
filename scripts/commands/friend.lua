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
    local friendsApi = xi.sanctumFriends
    if friendsApi == nil then
        player:printToPlayer('The Friends server component has not been built yet.', xi.msg.channel.SYSTEM_3, 'Friends')
        return
    end

    action = string.lower(action or '')

    if action == 'list' then
        player:printToPlayer(friendsApi.list(player), xi.msg.channel.SYSTEM_3, 'Friends')
        return
    end

    if targetName == nil or targetName == '' then
        usage(player)
        return
    end

    local result
    if action == 'add' then
        result = friendsApi.request(player, targetName)
    elseif action == 'accept' then
        result = friendsApi.accept(player, targetName)
    elseif action == 'decline' then
        result = friendsApi.decline(player, targetName)
    elseif action == 'remove' then
        result = friendsApi.remove(player, targetName)
    else
        usage(player)
        return
    end

    player:printToPlayer(result, xi.msg.channel.SYSTEM_3, 'Friends')
end

return commandObj
