-----------------------------------
-- Area: Wajaom Woodlands
--  NPC: ??? (Spawn Tinnin(ZNM T4))
-- !pos 278 0 -703 51
-----------------------------------
local ID = zones[xi.zone.WAJAOM_WOODLANDS]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        npcUtil.tradeMatches(trade, xi.item.JUG_OF_MONKEY_WINE) and
        npcUtil.popFromQM(player, npc, ID.mob.TINNIN)
    then
        -- Trade Monkey Wine
        player:tradeComplete()
        player:messageSpecial(ID.text.DRAWS_NEAR)
    end
end

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.HEADY_FRAGRANCE)
end

return entity
