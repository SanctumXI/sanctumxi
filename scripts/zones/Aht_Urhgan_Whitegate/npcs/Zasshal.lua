-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Zasshal
-- Type: Salvage Key Item giver
-- !pos 101.468 -1 -20.088 50
-----------------------------------
local ID = zones[xi.zone.AHT_URHGAN_WHITEGATE]

---@type TNpcEntity
local entity = {}

local permitCost = 500
local earthDay   = 24 * 60 * 60

local purchaseEvents =
{
    [818] = true,
    [820] = true,
}

local permitAreas =
{
    [10] = xi.assault.assaultArea.LEUJAOAM_SANCTUM,
    [11] = xi.assault.assaultArea.MAMOOL_JA_TRAINING_GROUNDS,
    [12] = xi.assault.assaultArea.LEBROS_CAVERN,
    [13] = xi.assault.assaultArea.PERIQIA,
    [14] = xi.assault.assaultArea.ILRUSI_ATOLL,
}

local function meetsPermitRequirements(player)
    return
        player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.GUESTS_OF_THE_EMPIRE) and
        player:getMainLvl() >= 65
end

local function getNextPermitTime(player)
    local lastPermit = player:getCharVar('LAST_PERMIT')
    if lastPermit == 0 then
        return 0
    end

    return lastPermit + earthDay
end

local function canPurchasePermit(player)
    local nextPermit = getNextPermitTime(player)

    return
        not player:hasKeyItem(xi.ki.REMNANTS_PERMIT) and
        meetsPermitRequirements(player) and
        (nextPermit == 0 or nextPermit <= GetSystemTime())
end

local function startPermitShop(player, eventId)
    player:startEvent(eventId,
        player:getAssaultPoint(xi.assault.assaultArea.LEUJAOAM_SANCTUM),
        player:getAssaultPoint(xi.assault.assaultArea.MAMOOL_JA_TRAINING_GROUNDS),
        player:getAssaultPoint(xi.assault.assaultArea.LEBROS_CAVERN),
        player:getAssaultPoint(xi.assault.assaultArea.PERIQIA),
        player:getAssaultPoint(xi.assault.assaultArea.ILRUSI_ATOLL))
end

local function getCurrentPermitPeriod()
    return JstMidnight() - earthDay
end

entity.onTrigger = function(player, npc)
    player:setLocalVar('SalvageValid', 0)

    if player:hasKeyItem(xi.ki.REMNANTS_PERMIT) then
        player:startEvent(821)
    elseif not meetsPermitRequirements(player) then
        player:startEvent(817)
    else
        local nextPermit = getNextPermitTime(player)
        if nextPermit == 0 then
            startPermitShop(player, 818)
        elseif nextPermit <= GetSystemTime() then
            startPermitShop(player, 820)
        else
            player:messageText(npc, ID.text.ZASSHAL_DIALOG)
        end
    end
end

entity.onEventUpdate = function(player, csid, option, npc)
    if purchaseEvents[csid] then
        player:setLocalVar('SalvageValid', 0)

        local permitArea = permitAreas[option]
        if
            permitArea and
            canPurchasePermit(player) and
            player:getAssaultPoint(permitArea) >= permitCost
        then
            player:setLocalVar('SalvageValid', option)
        end
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if purchaseEvents[csid] then
        local permitArea = permitAreas[player:getLocalVar('SalvageValid')]

        if
            option == 100 and
            permitArea and
            canPurchasePermit(player) and
            player:getAssaultPoint(permitArea) >= permitCost
        then
            player:delAssaultPoint(permitArea, permitCost)
            player:addKeyItem(xi.ki.REMNANTS_PERMIT)
            player:setCharVar('LAST_PERMIT', getCurrentPermitPeriod())
        end

        player:setLocalVar('SalvageValid', 0)
    end
end

return entity
