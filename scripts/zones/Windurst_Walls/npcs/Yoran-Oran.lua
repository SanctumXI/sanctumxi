-----------------------------------
-- Area: Windurst Walls
--  NPC: Yoran-Oran
-- !pos -109.987 -14 203.338 239
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD) ~= xi.questStatus.QUEST_AVAILABLE then
        if npcUtil.tradeMatches(trade, xi.item.CORNETTE, true) then
            player:startEvent(251, xi.settings.main.GIL_RATE * 200)
        elseif npcUtil.tradeMatches(trade, xi.item.PINCH_OF_YUHTUNGA_SULFUR, true) then
            player:startEvent(252, xi.settings.main.GIL_RATE * 250)
        elseif npcUtil.tradeMatches(trade, xi.item.THREE_LEAF_MANDRAGORA_BUD, true) then
            player:startEvent(253, xi.settings.main.GIL_RATE * 1200)
        elseif npcUtil.tradeMatches(trade, xi.item.FOUR_LEAF_MANDRAGORA_BUD, true) then
            player:startEvent(254, xi.settings.main.GIL_RATE * 120)
        elseif npcUtil.tradeMatches(trade, xi.item.SNOBBY_LETTER, true) then
            player:startEvent(255, xi.settings.main.GIL_RATE * 5500)
        else
            player:startEvent(250)
        end
    end
end

entity.onTrigger = function(player, npc)
    local mandragoraMad = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD)

    if mandragoraMad == xi.questStatus.QUEST_AVAILABLE then
        player:startEvent(249)
    elseif mandragoraMad == xi.questStatus.QUEST_ACCEPTED then
        player:startEvent(256)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 249 then
        player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD)

    -- TODO: This can easily be handled as a table, keyed by csid - 250 when in range
    elseif csid == 251 then
        npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD, { fame = 10, fameArea = xi.fameArea.WINDURST })
        player:addGil(xi.settings.main.GIL_RATE * 200)
        player:tradeComplete()
    elseif csid == 252 then
        npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD, { fame = 25, fameArea = xi.fameArea.WINDURST })
        player:addGil(xi.settings.main.GIL_RATE * 250)
        player:tradeComplete()
    elseif csid == 253 then
        npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD, { fame = 50, fameArea = xi.fameArea.WINDURST })
        player:addGil(xi.settings.main.GIL_RATE * 1200)
        player:tradeComplete()
    elseif csid == 254 then
        npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD, { fame = 10, fameArea = xi.fameArea.WINDURST })
        player:addGil(xi.settings.main.GIL_RATE * 120)
        player:tradeComplete()
    elseif csid == 255 then
        npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD, { fame = 100, fameArea = xi.fameArea.WINDURST })
        player:addGil(xi.settings.main.GIL_RATE * 5500)
        player:tradeComplete()
    end
end

return entity
