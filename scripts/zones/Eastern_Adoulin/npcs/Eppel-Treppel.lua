-----------------------------------
-- Area: Eastern Adoulin (257)
--  NPC: Eppel-Treppel
-- Speak to Eppel-Treppel to enter the Celennia Memorial Library.
-- !pos -90.922 -2.650 -80.891 257
-----------------------------------
---@type TNpcEntity
local libraryInstance = require('scripts/globals/library_instance')

local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(591)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 591 and option == 1 then
        libraryInstance.enter(player)
    end
end

return entity
