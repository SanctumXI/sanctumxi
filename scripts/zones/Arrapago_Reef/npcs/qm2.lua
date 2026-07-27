-----------------------------------
-- Area: Arrapago Reef
--  NPC: ??? (Spawn Velionis(ZNM T1))
-- !pos 311 -3 27 54
-----------------------------------
local ID = zones[xi.zone.ARRAPAGO_REEF]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        npcUtil.tradeMatches(trade, xi.item.GOLDEN_TEETH) and
        npcUtil.popFromQM(player, npc, ID.mob.VELIONIS, { message = ID.text.DRAWS_NEAR })
    then
        player:tradeComplete()
    end
end

return entity
