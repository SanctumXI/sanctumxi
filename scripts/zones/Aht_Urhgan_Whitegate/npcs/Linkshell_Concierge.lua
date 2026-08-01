-----------------------------------
-- Area: Aht Urhgan Whitegate (50)
-- NPC: Linkshell Concierge
-- !pos -80.674 0.000 -63.628 50
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    require('scripts/globals/sanctum/linkshell_concierge').onTrigger(player, npc)
end

return entity
