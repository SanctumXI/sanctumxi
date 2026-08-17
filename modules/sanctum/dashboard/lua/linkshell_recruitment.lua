-----------------------------------
-- Register companion recruitment support with the module system.
-- Approved pearls are claimed from a Linkshell Concierge.
-----------------------------------
require('modules/module_utils')
local libraryInstance = require('scripts/globals/library_instance')
-----------------------------------
local m = Module:new('linkshell_recruitment')

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if not zoning then
        local reservedLinkshellName = xi.linkshellRecruitment.getPendingLinkpearlName(player)
        if reservedLinkshellName and reservedLinkshellName ~= '' then
            xi.linkshellRecruitment.markPendingLinkpearlNotified(player, reservedLinkshellName)
        end

        -- Allow the character session to settle before showing a one-time
        -- login reminder for the oldest pending linkpearl.
        player:timer(2500, function(playerArg)
            local linkshellName = xi.linkshellRecruitment.getPendingLinkpearlName(playerArg)
            if linkshellName and linkshellName ~= '' then
                local secondsRemaining = xi.linkshellRecruitment.getPendingLinkpearlSecondsRemaining(playerArg)
                if secondsRemaining > 0 then
                    playerArg:printToPlayer(string.format(
                        'A linkpearl for %s is waiting at a Linkshell Concierge. You have %s remaining to claim it.',
                        linkshellName,
                        libraryInstance.formatRegistrationCooldown(secondsRemaining)
                    ), 0, 'LS Concierge')
                end
            end
        end)
    end
end)

return m
