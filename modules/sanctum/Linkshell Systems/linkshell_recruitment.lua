-----------------------------------
-- Deliver pearls approved through the Sanctum companion application.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('linkshell_recruitment')

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if not zoning then
        -- Wait until the character inventory and session have fully settled.
        player:timer(2500, function(playerArg)
            local delivered = xi.linkshellRecruitment.deliverApprovedPearls(playerArg)
            if delivered > 0 then
                playerArg:printToPlayer('Your approved linkshell application has been delivered to your inventory.')
            end
        end)
    end
end)

return m
