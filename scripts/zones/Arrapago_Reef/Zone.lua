-----------------------------------
-- Zone: Arrapago_Reef (54)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    zone:registerCuboidTriggerArea(1, -462, -4, -420, -455, -1, -392) -- approach the Cutter
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-456, -3, -405, 64)
    end

    if
        prevZone == xi.zone.THE_ASHU_TALIF and
        player:getCharVar('AgainstAllOdds') == 3
    then
        cs = 238
    elseif prevZone == xi.zone.ILRUSI_ATOLL then
        player:setPos(9.304, -7.377, 620.133, 0)
    end

    return cs
end

zoneObject.afterZoneIn = function(player)
    player:entityVisualPacket('1pb1')
    player:entityVisualPacket('2pb1')
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
    if
        player:getQuestStatus(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AGAINST_ALL_ODDS) == xi.questStatus.QUEST_ACCEPTED and
        player:getCharVar('AgainstAllOdds') == 1
    then
        player:startEvent(237)
    end
end

zoneObject.onGameDay = function()
    xi.apkallu.updateHate(xi.zone.ARRAPAGO_REEF, -3)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
    -- Enter instance: Illrusi Atoll
    if csid == 108 then
        player:setPos(0, 0, 0, 0, 55)

    -- Party member entry cutscene, shared by Black Coffin and Ilrusi assaults.
    elseif csid == 222 then
        -- Only zone the player here for Black Coffin (The Ashu Talif).
        -- Ilrusi assault members are teleported by the leader's confirm event (xi.instance.onEventFinish);
        -- zoning them here too caused a double teleport to the wrong destination.
        local instance = player:getInstance()
        if instance and instance:getZone():getID() == xi.zone.THE_ASHU_TALIF then
            player:setPos(0, 0, 0, 0, xi.zone.THE_ASHU_TALIF)
        end
    elseif csid == 237 then
        player:startEvent(240)
    elseif csid == 238 then
        npcUtil.completeQuest(player, xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AGAINST_ALL_ODDS, { item = 15266, var = 'AgainstAllOdds' })
    elseif csid == 240 then
        player:setCharVar('AgainstAllOdds', 2)
    end
end

return zoneObject
