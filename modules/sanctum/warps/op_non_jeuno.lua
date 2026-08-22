-----------------------------------
-- Non-Jeuno Native Outpost Menus
-----------------------------------
require('modules/module_utils')

local m = Module:new('non_jeuno_native_outposts')
m:setEnabled(true)

local eventId = 10000

local function outpostLiaison()
    local entity = {}

    entity.onTrigger = function(player, npc)
        xi.conquest.teleporterOnTrigger(player, player:getNation(), eventId)
    end

    entity.onEventUpdate = function(player, csid, option, npc)
        xi.conquest.teleporterOnEventUpdate(player, csid, option, eventId)
    end

    entity.onEventFinish = function(player, csid, option, npc)
        xi.conquest.teleporterOnEventFinish(player, csid, option, eventId)
    end

    return entity
end

xi.module.ensureTable('xi.zones.Tavnazian_Safehold.npcs')
xi.zones.Tavnazian_Safehold.npcs.Outpost_Liaison = outpostLiaison()

xi.module.ensureTable('xi.zones.Aht_Urhgan_Whitegate.npcs')
xi.zones.Aht_Urhgan_Whitegate.npcs.Outpost_Liaison = outpostLiaison()

return m
