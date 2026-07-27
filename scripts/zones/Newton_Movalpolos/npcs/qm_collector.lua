-----------------------------------
-- Area: Newton_Movalpolos
--  NPC: ??? for Goblin Collector
-----------------------------------
local ID = zones[xi.zone.NEWTON_MOVALPOLOS]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        npcUtil.tradeMatches(trade, xi.item.PREMIUM_BAG) and
        npcUtil.popFromQM(player, npc, ID.mob.GOBLIN_COLLECTOR)
    then
        player:tradeComplete()
    end
end

return entity
