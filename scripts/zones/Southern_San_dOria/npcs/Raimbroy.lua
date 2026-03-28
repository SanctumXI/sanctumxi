-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Raimbroy
-- Starts and Finishes Quest: The Sweetest Things
-- !zone 230
-----------------------------------
local ID = require("scripts/zones/Southern_San_dOria/IDs")
-----------------------------------
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(7864)
end

entity.onTrade = function(player, npc, trade)
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
end

return entity
