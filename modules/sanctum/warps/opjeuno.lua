-----------------------------------
-- Lower Jeuno Native Outpost Menu
-----------------------------------
require('modules/module_utils')

local m = Module:new('lower_jeuno_native_outpost')
m:setEnabled(true)

local eventId = 65000
local entity  = {}

entity.onTrigger = function(player, npc)
    xi.conquest.teleporterOnTrigger(player, player:getNation(), eventId)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.conquest.teleporterOnEventUpdate(player, csid, option, eventId)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.conquest.teleporterOnEventFinish(player, csid, option, eventId)
end

xi.module.ensureTable('xi.zones.Lower_Jeuno.npcs')
xi.zones.Lower_Jeuno.npcs.Outpost_Liaison = entity

return m
