-----------------------------------
-- Zhayolm Remnants utilities
-----------------------------------
local ID = zones[xi.zone.ZHAYOLM_REMNANTS]
-----------------------------------

local zhayolmGlobal = {}

zhayolmGlobal.thirdFloorPath =
{
    SOUTH = 1,
    NORTH = 2,
}

local secondFloorDoors =
{
    ID.npc.DOOR_2_1,
    ID.npc.DOOR_2_2,
    ID.npc.DOOR_2_3,
    ID.npc.DOOR_2_4,
}

local secondFloorRoutes =
{
    [1] =
    {
        devices = { ID.npc.SLOT },
        groups  =
        {
            utils.slice(ID.mob.DRACO_LIZARD, 1, 8),
            utils.slice(ID.mob.WYVERN, 9, 16),
            utils.slice(ID.mob.WYVERN, 1, 8),
        },
    },
    [2] =
    {
        devices = { ID.npc.SLOT, ID.npc.SOCKET },
        groups  =
        {
            utils.slice(ID.mob.DRACO_LIZARD, 9, 16),
            utils.slice(ID.mob.WYVERN, 9, 16),
            utils.slice(ID.mob.WYVERN, 1, 8),
        },
    },
    [3] =
    {
        devices = { ID.npc.SLOT, ID.npc.SOCKET },
        groups  =
        {
            utils.slice(ID.mob.DRACO_LIZARD, 9, 16),
            utils.slice(ID.mob.DRACO_LIZARD, 1, 8),
            utils.slice(ID.mob.WYVERN, 1, 8),
        },
    },
    [4] =
    {
        devices = { ID.npc.SOCKET },
        groups  =
        {
            utils.slice(ID.mob.DRACO_LIZARD, 9, 16),
            utils.slice(ID.mob.DRACO_LIZARD, 1, 8),
            utils.slice(ID.mob.WYVERN, 9, 16),
        },
    },
}

local thirdFloorRoutes =
{
    [zhayolmGlobal.thirdFloorPath.SOUTH] =
    {
        group =
        {
            utils.slice(ID.mob.MAMOOL_JA_ZENIST, 6, 12),
            utils.slice(ID.mob.MAMOOL_JA_SPEARMAN, 2, 8),
            utils.slice(ID.mob.MAMOOL_JA_STRAPER, 1, 7),
            utils.slice(ID.mob.MAMOOL_JA_BOUNDER, 2, 4),
            ID.mob.ARCHAIC_RAMPART[1],
        },
        x      = 380,
        y      = -4,
        z      = 389,
        dropID = 3409,
    },
    [zhayolmGlobal.thirdFloorPath.NORTH] =
    {
        group =
        {
            utils.slice(ID.mob.MAMOOL_JA_SAVANT, 2, 11),
            utils.slice(ID.mob.MAMOOL_JA_SOPHIST, 1, 10),
            utils.slice(ID.mob.MAMOOL_JA_MIMICKER, 1, 12),
            ID.mob.ARCHAIC_RAMPART[2],
        },
        x      = 300,
        y      = -4,
        z      = 526,
        dropID = 3408,
        maxHP  = 10150,
    },
}

zhayolmGlobal.completeSecondFloorRoute = function(instance, route)
    local routeData = secondFloorRoutes[route]

    if
        not instance or
        not routeData or
        instance:getStage() ~= 2 or
        instance:getProgress() ~= route
    then
        return false
    end

    for _, deviceID in ipairs(routeData.devices) do
        local device = GetNPCByID(deviceID, instance)

        if device then
            device:setStatus(xi.status.NORMAL)
        end
    end

    xi.salvage.unsealDoors(instance, secondFloorDoors)

    for _, group in ipairs(routeData.groups) do
        xi.salvage.spawnGroup(instance, group)
    end

    for index, doorID in ipairs(secondFloorDoors) do
        local door = GetNPCByID(doorID, instance)

        if door then
            xi.salvage.onDoorOpen(door, nil, index == 1 and 5 or nil)
        end
    end

    instance:setLocalVar('stageComplete', 2)
    return true
end

zhayolmGlobal.trySpawnThirdFloorMadame = function(instance, path)
    local routeData = thirdFloorRoutes[path]

    if
        not instance or
        instance:getStage() ~= 3 or
        not routeData or
        not xi.salvage.groupKilled(instance, routeData.group)
    then
        return false
    end

    local madameID = ID.mob.POROGGO_MADAME[3]
    local madame   = GetMobByID(madameID, instance)

    if not madame or madame:getLocalVar('spawned') ~= 0 then
        return false
    end

    madame = SpawnMob(madameID, instance)
    if not madame then
        return false
    end

    madame:setPos(routeData.x, routeData.y, routeData.z)
    madame:setDropID(routeData.dropID)

    if routeData.maxHP then
        madame:setMaxHP(routeData.maxHP)
        madame:updateHealth()
    end

    madame:setLocalVar('spawned', 1)
    return true
end

return zhayolmGlobal
