-----------------------------------
-- func: !libraryinstance
-- desc: Enter the shared Celennia Memorial Library test instance
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = '',
}

local libraryInstance = require('scripts/globals/library_instance')

commandObj.onTrigger = function(player)
    libraryInstance.enter(player)
end

return commandObj
