-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Hugo
-- Sanctum Linkshell HNM Treasury
-----------------------------------

local treasuryNpc = require('scripts/globals/sanctum/linkshell_treasury_npc')

---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if player:hasKeyItem(xi.ki.MAP_OF_AL_ZAHBI) then
        player:startEvent(5065, { text_table = 0 })
    else
        player:startEvent(5066, { text_table = 0 })
    end
end

return entity
