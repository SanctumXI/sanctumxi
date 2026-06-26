-----------------------------------
-- func: getenmity
-- desc: Prints the target mob's CE and VE for every alliance member.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = ''
}

local function error(player, msg)
    player:printToPlayer('[ENMITY_ERROR] ' .. msg, xi.msg.channel.SYSTEM_3)
    player:printToPlayer('[ENMITY_ERROR] !getenmity', xi.msg.channel.SYSTEM_3)
end

commandObj.onTrigger = function(player)
    local targ = player:getCursorTarget()

    if not targ or not targ:isMob() then
        error(player, 'You must select a target monster first.')
        return
    end

    local alliance = player:getAlliance()

    if alliance ~= nil then
        for _, member in ipairs(alliance) do
            if member and member:isPC() then
                local ce = targ:getCE(member)
                local ve = targ:getVE(member)

                player:printToPlayer(
                    string.format(
                        '[ENMITY] %s CE:%u VE:%u Total:%u',
                        member:getName(),
                        ce,
                        ve,
                        ce + ve
                    ),
                    xi.msg.channel.SYSTEM_3
                )
            end
        end
    else
        local party = player:getParty()

        if party ~= nil then
            for _, member in ipairs(party) do
                if member and member:isPC() then
                    local ce = targ:getCE(member)
                    local ve = targ:getVE(member)

                    player:printToPlayer(
                        string.format(
                            '[ENMITY] %s CE:%u VE:%u Total:%u',
                            member:getName(),
                            ce,
                            ve,
                            ce + ve
                        ),
                        xi.msg.channel.SYSTEM_3
                    )
                end
            end
        else
            local ce = targ:getCE(player)
            local ve = targ:getVE(player)

            player:printToPlayer(
                string.format(
                    '[ENMITY] %s CE:%u VE:%u Total:%u',
                    player:getName(),
                    ce,
                    ve,
                    ce + ve
                ),
                xi.msg.channel.SYSTEM_3
            )
        end
    end
end

return commandObj