-----------------------------------
-- Area: Attohwa Chasm
--  NPC: Jakaka
-- Type: ENM
-- !pos -144.711 6.246 -250.309 7
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------

---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    -- Trade 2000 gil to teleport to Boneyard Gully
    if npcUtil.tradeMatches(trade, { gil = 2000 }) then
        player:tradeComplete()

        -- Boneyard Gully
        player:setPos(0, 0, 0, 0, xi.zone.BONEYARD_GULLY)
        return
    end

    -- Trade Parradamo Stones
    if
        trade:hasItemQty(xi.item.POUCH_OF_PARRADAMO_STONES, 1) and
        trade:getItemCount() == 1
    then
        player:tradeComplete()
        player:startEvent(12)
        return
    end
end

entity.onTrigger = function(player, npc)
    player:printToPlayer('Jakaka reminds you: Trade me 2,000 gil to teleport to Boneyard Gully.', xi.msg.channel.SYSTEM_3)

    local miasmaFilterCD = player:getCharVar('[ENM]MiasmaFilter')

    if player:hasKeyItem(xi.ki.MIASMA_FILTER) then
        player:startEvent(11)
    else
        if miasmaFilterCD >= GetSystemTime() then
            player:startEvent(14, VanadielTime() + (miasmaFilterCD - GetSystemTime()))
        else
            if
                player:hasItem(xi.item.POUCH_OF_PARRADAMO_STONES) or
                player:hasItem(xi.item.FLAXEN_POUCH)
            then
                player:startEvent(15)
            else
                player:startEvent(13)
            end
        end
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 12 then
        npcUtil.giveKeyItem(player, xi.ki.MIASMA_FILTER)
        player:setCharVar('[ENM]MiasmaFilter', GetSystemTime() + (xi.settings.main.ENM_COOLDOWN * 3600))
    elseif csid == 13 then
        npcUtil.giveItem(player, xi.item.FLAXEN_POUCH)
    end
end

return entity