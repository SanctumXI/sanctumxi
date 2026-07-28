-----------------------------------
-- Area: Eastern Adoulin (257)
--  NPC: Eppel-Treppel
-- The Linkshell Concierge service is currently available in Aht Urhgan Whitegate.
-- !pos -90.922 -2.650 -80.891 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:printToPlayer('Please visit the Linkshell Concierge beside Hugo in Aht Urhgan Whitegate.', xi.msg.channel.SYSTEM_3)
end

return entity
