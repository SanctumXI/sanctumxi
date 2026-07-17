-----------------------------------
-- func: !hengeinstance [clear]
-- desc: Enter or clear the shared Reisenjima Henge HNM test instance
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local hnmInstances = require('scripts/globals/sanctum/hnm_instances')

commandObj.onTrigger = function(player, action)
    if action == 'clear' then
        hnmInstances.clearTest()
        player:printToPlayer('Reisenjima Henge test instance state cleared.')
        return
    elseif action then
        player:printToPlayer('Usage: !hengeinstance [clear]')
        return
    end

    hnmInstances.enterTest(player)
end

return commandObj
