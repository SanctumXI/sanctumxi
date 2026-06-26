-----------------------------------
-- Level Down
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
-----------------------------------
local m = Module:new('level_down')

local openingDecoration = '\129\154'
local closingDecoration = '\129\154'

m:addOverride('xi.player.onPlayerLevelDown', function(player)
    super(player)

    local decoratedMessage = string.format(
        '%s %s has deleveled to level %u on %s! %s',
        openingDecoration,
        player:getName(),
        player:getMainLvl(),
        xi.jobName[player:getMainJob()][2],
        closingDecoration
    )

    player:printToArea(decoratedMessage, xi.msg.channel.SYSTEM_3, xi.msg.area.SYSTEM, '', false)
end)

return m