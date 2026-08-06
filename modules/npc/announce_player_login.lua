-----------------------------------
-- Announce when a player logs in
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('announce_player_login')

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if not zoning then
        -- Allow linkshell state and online-session rows to settle before selecting recipients.
        player:timer(2500, function(playerArg)
            xi.announcePlayerLogin.notifyLinkshellOneMembers(playerArg)
        end)
    end
end)

return m
