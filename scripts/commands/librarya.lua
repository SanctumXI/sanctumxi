-----------------------------------
-- func: !librarya [clear]
-- desc: Enter or clear Library runtime copy A
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
        libraryInstance.clearCopy('A')
        player:printToPlayer('Library copy A state cleared.')
        return
    elseif action then
        player:printToPlayer('Usage: !librarya [clear]')
        return
    end

    libraryInstance.enterCopy(player, 'A')
end

return commandObj
