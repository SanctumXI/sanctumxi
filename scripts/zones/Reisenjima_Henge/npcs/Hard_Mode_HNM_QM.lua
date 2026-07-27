-----------------------------------
-- Area: Reisenjima Henge (292)
--  NPC: Hard Mode HNM ???
-- Note: FIRE_CRYSTAL and EARTH_CRYSTAL are temporary placeholder costs.
-----------------------------------
require('scripts/globals/npc_util')

local ID = zones[xi.zone.REISENJIMA_HENGE]

local selectionVar = 'HengeHnmSelection'
local requiredItems =
{
    xi.item.FIRE_CRYSTAL,
    xi.item.EARTH_CRYSTAL,
}

local encounters =
{
    {
        name  = 'Roc',
        mobId = ID.mob.HARD_MODE_ROC,
    },
    {
        name  = 'Simurgh',
        mobId = ID.mob.HARD_MODE_SIMURGH,
    },
    {
        name  = 'King Arthro',
        mobId = ID.mob.HARD_MODE_KING_ARTHRO,
    },
}

local function getEncounter(mobId)
    for _, encounter in ipairs(encounters) do
        if encounter.mobId == mobId then
            return encounter
        end
    end

    return nil
end

local function getActiveEncounter(instance)
    for _, encounter in ipairs(encounters) do
        local mob = GetMobByID(encounter.mobId, instance)
        if mob and mob:isSpawned() then
            return encounter
        end
    end

    return nil
end

local function selectEncounter(player, encounter)
    player:setLocalVar(selectionVar, encounter.mobId)
    player:printToPlayer(string.format(
        '%s selected. Trade one Fire Crystal and one Earth Crystal to the ???.',
        encounter.name
    ))
end

---@type TNpcEntity
local entity = {}

entity.onSpawn = function(npc)
    npc:renameEntity('???', true)
end

entity.onTrade = function(player, npc, trade)
    local instance       = npc:getInstance()
    local playerInstance = player:getInstance()
    if
        not instance or
        not playerInstance or
        playerInstance:getRuntimeID() ~= instance:getRuntimeID()
    then
        player:printToPlayer('This encounter can only be started inside its Henge instance.')
        return
    end

    local activeEncounter = getActiveEncounter(instance)
    if activeEncounter then
        player:printToPlayer(string.format('%s is already active in this instance.', activeEncounter.name))
        return
    end

    local encounter = getEncounter(player:getLocalVar(selectionVar))
    if not encounter then
        player:printToPlayer('Touch the ??? and select an HNM before trading.')
        return
    end

    if not npcUtil.tradeMatches(trade, requiredItems) then
        player:printToPlayer('Trade exactly one Fire Crystal and one Earth Crystal.')
        return
    end

    local mob = SpawnMob(encounter.mobId, instance)
    if not mob then
        player:printToPlayer('The selected HNM could not be spawned. Your items were not consumed.')
        return
    end

    player:tradeComplete()
    player:setLocalVar(selectionVar, 0)
    mob:updateClaim(player)
    player:printToPlayer(string.format('%s has been spawned.', encounter.name))
end

entity.onTrigger = function(player, npc)
    local instance        = npc:getInstance()
    local activeEncounter = instance and getActiveEncounter(instance) or nil
    if activeEncounter then
        player:printToPlayer(string.format('%s is already active in this instance.', activeEncounter.name))
        return
    end

    local options = {}
    for _, encounter in ipairs(encounters) do
        local selectedEncounter = encounter
        table.insert(options,
        {
            string.format('%s: Fire + Earth Crystal', selectedEncounter.name),
            function(playerArg)
                selectEncounter(playerArg, selectedEncounter)
            end,
        })
    end

    player:customMenu(
    {
        title   = 'Select a hard-mode HNM',
        options = options,
    })
end

return entity
