-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Sanraku
-- Type: Zeni NM pop item and trophy management.
-- !pos -125.724 0.999 22.136 50
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.znm.sanraku.onTrade(player, npc, trade)
       if trade:hasItemQty(xi.item.IMPERIAL_GOLD_PIECE, 1) then
        player:tradeComplete()

        player:addCurrency("zeni_point", 450)

        player:printToPlayer("You receive 450 Zeni.", xi.msg.channel.SYSTEM_3)
       end
end

entity.onTrigger = function(player, npc)
    xi.znm.sanraku.onTrigger(player, npc)
    player:printToPlayer("Trade me an Imperial Gold Piece and see what happens.", xi.msg.channel.SYSTEM_3)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.znm.sanraku.onEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.znm.sanraku.onEventFinish(player, csid, option, npc)
end

return entity
