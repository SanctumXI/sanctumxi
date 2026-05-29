require('modules/module_utils')
require('scripts/globals/npc_util')

local m = Module:new('water_crystal_wave_trial')
m:setEnabled(true)

local zoneName = 'Western_Altepa_Desert'

local waveDelay = 10000 -- 1 minute 30 seconds
local maxWaves = 10

local activeTrial = false
local currentWave = 0
local trialTarget = nil

local minSpawnDistance = 3
local maxSpawnDistance = 10

local npcPos =
{
    x = 298,
    y = 1.5,
    z = 107,
    rotation = 0,
}

local function getRandomSpawnPos(centerX, centerY, centerZ)
    local angle = math.random() * math.pi * 2
    local distance = math.random(minSpawnDistance, maxSpawnDistance)

    local x = centerX + math.cos(angle) * distance
    local z = centerZ + math.sin(angle) * distance

    return x, centerY, z
end

local function spawnNormalMob(zone, x, y, z)
    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Doom Worm',
        groupId     = 42,
        groupZoneId = 5,

        x = x,
        y = y,
        z = z,
        rotation = 0,

        minLevel = 50,
        maxLevel = 50,

        specialSpawnAnimation = true,
        releaseIdOnDisappear  = true,

        onMobSpawn = function(mob)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)
            mob:setMobMod(xi.mobMod.SPELL_LIST, 153)
            mob:setMobAbilityEnabled(true)

        end,
    })

    mob:setSpawn(x, y, z, 0)
    mob:spawn()

    return mob
end

local function spawnNM(zone, x, y, z)
    local nm = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Bastard Worm',
        groupId     = 37,
        groupZoneId = 81,

        x = x,
        y = y,
        z = z,
        rotation = 0,

        minLevel = 55,
        maxLevel = 55,

        specialSpawnAnimation = true,
        releaseIdOnDisappear  = true,

        onMobSpawn = function(mob)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)

            mob:setMaxHP(mob:getMaxHP() * 3)
            mob:setHP(mob:getMaxHP())

            mob:setMod(xi.mod.ATTP, 100)
            mob:setMod(xi.mod.DEFP, 100)
            mob:setMod(xi.mod.ACC, 100)
            mob:setMod(xi.mod.EVA, 50)

            mob:setMobMod(xi.mobMod.SPELL_LIST, 154)
            mob:setMobAbilityEnabled(true)
        end,

        onMobDeath = function(mob, player, optParams)
            activeTrial = false
            currentWave = 0
            trialTarget = nil

            if player then
                player:printToPlayer('The trial is complete!', xi.msg.channel.SYSTEM_3)
            end
        end,
    })

    nm:setSpawn(x, y, z, 0)
    nm:spawn()

    return nm
end

local function spawnWave(npc)
    if not activeTrial then
        return
    end

    currentWave = currentWave + 1

    local zone = npc:getZone()
    local x = npc:getXPos()
    local y = npc:getYPos()
    local z = npc:getZPos()

    if currentWave > maxWaves then
        local spawnX, spawnY, spawnZ = getRandomSpawnPos(x, y, z)
        spawnNM(zone, spawnX, spawnY, spawnZ)
        return
    end

    for i = 1, 3 do
        local spawnX, spawnY, spawnZ = getRandomSpawnPos(x, y, z)
        spawnNormalMob(zone, spawnX, spawnY, spawnZ)
    end

    npc:timer(waveDelay, function(npcArg)
        spawnWave(npcArg)
    end)
end

m:addOverride(string.format('xi.zones.%s.Zone.onInitialize', zoneName), function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name    = 'Gauntlet Rift',
        look    = 298,
        x = npcPos.x,
        y = npcPos.y,
        z = npcPos.z,
        rotation = npcPos.rotation,

        onTrade = function(player, npc, trade)
            if activeTrial then
                player:printToPlayer('A trial is already in progress.', xi.msg.channel.SYSTEM_3)
                return
            end

            if npcUtil.tradeHasExactly(trade, xi.item.WATER_CRYSTAL) then
                player:tradeComplete()

                activeTrial = true
                currentWave = 0
                trialTarget = player

                player:printToPlayer('Get ready for the Gauntlet. Wave 1 initializing...', xi.msg.channel.SYSTEM_3)

                spawnWave(npc)
            end
        end,

        onTrigger = function(player, npc)
            if activeTrial then
                player:printToPlayer('The trial is already in progress.', xi.msg.channel.SYSTEM_3)
            else
                player:printToPlayer('Trade me a Water Crystal to begin the trial.', xi.msg.channel.SYSTEM_3)
            end
        end,
    })
end)

return m