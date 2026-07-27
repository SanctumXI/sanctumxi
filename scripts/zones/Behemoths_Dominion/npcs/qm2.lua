-----------------------------------
-- Area: Behemoth's Dominion
--  NPC: qm2 (???)
-- Spawns Behemoth or King Behemoth
-- !pos -267 -19 74 127
-----------------------------------
local ID = zones[xi.zone.BEHEMOTHS_DOMINION]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        not GetMobByID(ID.mob.BEHEMOTH):isSpawned() and
        not GetMobByID(ID.mob.KING_BEHEMOTH):isSpawned()
    then
        if
            npcUtil.tradeMatches(trade, xi.item.BEASTLY_SHANK) and
            npcUtil.popFromQM(player, npc, ID.mob.BEHEMOTH)
        then
            player:tradeComplete()
        elseif
            npcUtil.tradeMatches(trade, xi.item.SAVORY_SHANK) and
            npcUtil.popFromQM(player, npc, ID.mob.KING_BEHEMOTH)
        then
            player:tradeComplete()
        end
    end
end

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.IRREPRESSIBLE_MIGHT)
end

return entity
