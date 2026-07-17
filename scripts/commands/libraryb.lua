-----------------------------------
-- func: !libraryb [clear]
-- desc: Enter or clear Library runtime copy B
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local libraryInstance = require('scripts/globals/library_instance')

commandObj.onTrigger = function(player, action)
    if action == 'clear' then
        libraryInstance.clearCopy('B')
        player:printToPlayer('Library copy B state cleared.')
        return
    elseif action then
        player:printToPlayer('Usage: !libraryb [clear]')
        return
    end

    libraryInstance.enterCopy(player, 'B')
end

return commandObj
