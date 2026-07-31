-----------------------------------
-- func: salvagecheck
-- desc: Displays useful state while testing a Salvage instance
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = '',
}

local salvageZones =
{
    [xi.zone.ZHAYOLM_REMNANTS] =
    {
        name      = 'Zhayolm Remnants',
        fireflies = xi.item.CAGE_OF_Z_REMNANTS_FIREFLIES,
    },
    [xi.zone.ARRAPAGO_REMNANTS] =
    {
        name      = 'Arrapago Remnants',
        fireflies = xi.item.CAGE_OF_A_REMNANTS_FIREFLIES,
    },
    [xi.zone.BHAFLAU_REMNANTS] =
    {
        name      = 'Bhaflau Remnants',
        fireflies = xi.item.CAGE_OF_B_REMNANTS_FIREFLIES,
    },
    [xi.zone.SILVER_SEA_REMNANTS] =
    {
        name      = 'Silver Sea Remnants',
        fireflies = xi.item.CAGE_OF_S_REMNANTS_FIREFLIES,
    },
}

local pathosEffects =
{
    xi.effect.ENCUMBRANCE_I,
    xi.effect.OBLIVISCENCE,
    xi.effect.OMERTA,
    xi.effect.IMPAIRMENT,
    xi.effect.DEBILITATION,
}

local boolToNumber = function(value)
    return value and 1 or 0
end

commandObj.onTrigger = function(player)
    local zoneData = salvageZones[player:getZoneID()]
    local instance = player:getInstance()

    if not zoneData or not instance then
        player:printToPlayer('You must be inside a Salvage instance.')
        return
    end

    local mobCount     = 0
    local spawnedCount = 0
    local aliveCount   = 0

    for _, mob in pairs(instance:getMobs()) do
        mobCount = mobCount + 1

        if mob:isSpawned() then
            spawnedCount = spawnedCount + 1
        end

        if mob:isAlive() then
            aliveCount = aliveCount + 1
        end
    end

    local pathosState = {}
    for _, effectID in ipairs(pathosEffects) do
        table.insert(pathosState, tostring(boolToNumber(player:hasStatusEffect(effectID))))
    end

    local timeEntered = instance:getLocalVar('timeEntered')
    local elapsed     = timeEntered > 0 and GetSystemTime() - timeEntered or 0

    player:printToPlayer(string.format(
        '%s | Instance %u (runtime %s)',
        zoneData.name,
        instance:getID(),
        tostring(instance:getRuntimeID())))
    player:printToPlayer(string.format(
        'Stage %u | Progress %u | Stage complete %u | Complete %u | Failed %u',
        instance:getStage(),
        instance:getProgress(),
        instance:getLocalVar('stageComplete'),
        boolToNumber(instance:completed()),
        boolToNumber(instance:failed())))
    player:printToPlayer(string.format(
        'Mobs %u total | %u spawned | %u alive | Elapsed %us',
        mobCount,
        spawnedCount,
        aliveCount,
        elapsed))
    player:printToPlayer(string.format(
        'Transport %u | Party %u | Cells %u | NMs %u | Day %u',
        instance:getLocalVar('transportUser'),
        instance:getLocalVar('allySize'),
        instance:getLocalVar('cellsUsed'),
        instance:getLocalVar('killedNMs'),
        instance:getLocalVar('dayElement')))
    player:printToPlayer(string.format(
        '5F NM %u | 4F return %u | 6F door %u | Exit %u',
        instance:getLocalVar('spawned5th'),
        instance:getLocalVar('notComplete'),
        instance:getLocalVar('6th Door'),
        instance:getLocalVar('exitPoint')))
    player:printToPlayer(string.format(
        'Permit %u | Fireflies %u | Pathos Enc/Obl/Omr/Imp/Deb %s',
        boolToNumber(player:hasKeyItem(xi.ki.REMNANTS_PERMIT)),
        boolToNumber(player:hasItem(zoneData.fireflies, xi.inventoryLocation.TEMPITEMS)),
        table.concat(pathosState, '/')))
end

return commandObj
