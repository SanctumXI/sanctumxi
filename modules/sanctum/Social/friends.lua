-----------------------------------
-- Register Sanctum's mutual friends system and friend-login notices.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('sanctum_friends')

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if not zoning then
        player:timer(2500, function(playerArg)
            xi.sanctumFriends.notifyFriendsOfLogin(playerArg)
        end)
    end
end)

return m

