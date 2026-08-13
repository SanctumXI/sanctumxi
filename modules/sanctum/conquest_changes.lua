require('modules/module_utils')

local m = Module:new('conquest_changes')

m:addOverride('xi.conquest.sendConquestTallyEndMessage', function(player, messageBase, owner, ranking, isConquestAlliance)
    super(player, messageBase, owner, ranking, isConquestAlliance)
    xi.steelConquest.refresh(player)
end)

return m
