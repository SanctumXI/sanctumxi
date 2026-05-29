require('modules/module_utils')
require('scripts/globals/npc_util')

local m = Module:new('AltepaGauntlet2')
m:setEnabled(true)

local zoneName = 'Western_Altepa_Desert'

local waveDelay = 90000 -- 10000 for 10 seconds for testing. Use 90000 for 1 minute 30 seconds.
local maxWaves = 10
local activeTrial = false
local currentWave = 0
local trialTarget = nil
local wavebonus = 30000
local bossbonus = 50000
local minlevel = 40
local maxlevel = 50
local aliveNormalMobs = 0
local nmKilled = false
local allWavesSpawned = false
local normalWaveRewardGiven = false
local trialMembers = {}
local spawnedMobs = {}
local trialNpc = nil

local minSpawnDistance = 3
local maxSpawnDistance = 10

local npcPos =
{
    x = 290,
    y = 1.5,
    z = 101,
    rotation = 0,
}

local function getRandomSpawnPos(centerX, centerY, centerZ)
    local angle = math.random() * math.pi * 2
    local distance = math.random(minSpawnDistance, maxSpawnDistance)

    local x = centerX + math.cos(angle) * distance
    local z = centerZ + math.sin(angle) * distance

    return x, centerY, z
end

local function getTrialMembers(player)
    local members = player:getParty()

    if members == nil or #members == 0 then
        return { player }
    end

    return members
end

local function addConfrontation(player)
    trialMembers = getTrialMembers(player)

    for _, member in ipairs(trialMembers) do
        if member ~= nil and member:isPC() then
            member:addStatusEffect(xi.effect.CONFRONTATION, { power = 1, origin = member })
            member:addStatusEffect(xi.effect.LEVEL_RESTRICTION, { power = 50, origin = player })
        end
    end
end

local function removeConfrontation()
    for _, member in ipairs(trialMembers) do
        if member ~= nil and member:isPC() then
            member:delStatusEffect(xi.effect.CONFRONTATION)
            member:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
        end
    end

    trialMembers = {}
end

local function resetTrial()
    activeTrial = false
    currentWave = 0
    trialTarget = nil
    aliveNormalMobs = 0
    nmKilled = false
    allWavesSpawned = false
    normalWaveRewardGiven = false

    for _, mob in ipairs(spawnedMobs) do
        if mob ~= nil and mob:isSpawned() then
            DespawnMob(mob:getID())
        end
    end

    spawnedMobs = {}

    removeConfrontation()

    if trialNpc then
        trialNpc:setStatus(xi.status.NORMAL)
    end

    trialNpc = nil
end

local function awardGauntletReward(mob, player, totalEXP, message)
    if player == nil then
        return
    end

    local members = player:getParty()

    if members == nil or #members == 0 then
        members = { player }
    end

    local eligibleMembers = {}
    local seen = {}
    local allValid = true

    for _, member in ipairs(members) do
        if member ~= nil and member:isPC() then
            local id = member:getID()

            if not seen[id] then
                seen[id] = true

            if member:getZoneID() == mob:getZoneID() and member:checkDistance(mob) <= 50 then
                table.insert(eligibleMembers, member)

                    local level = member:getMainLvl()

                    if level < minlevel or level > maxlevel then
                    allValid = false
                    end
                end
            end
        end
    end

    if #eligibleMembers == 0 then
        player:printToPlayer('No eligible party members were in range.', xi.msg.channel.SYSTEM_3)
        return
    end

    if allValid then
        local bonusExp = math.floor(totalEXP / #eligibleMembers)

        for _, member in ipairs(eligibleMembers) do
            member:addExp(bonusExp)
            member:printToPlayer(message, xi.msg.channel.SYSTEM_3)
        end
    end
end

local function checkNormalWaveReward(mob, player)
    if not activeTrial then
        return
    end

    if normalWaveRewardGiven then
        return
    end

    if not allWavesSpawned then
        return
    end

    if aliveNormalMobs > 0 then
        return
    end

    normalWaveRewardGiven = true

        awardGauntletReward(
        mob,
        player,
        wavebonus,
        'You receive bonus EXP for clearing all normal enemy waves.'
    )
end

local function checkGauntletComplete(mob, player)
    if not activeTrial then
        return
    end

    if not allWavesSpawned then
        return
    end

    if aliveNormalMobs > 0 then
        return
    end

    if not nmKilled then
        return
    end

    if player then
        player:printToPlayer('The gauntlet is complete!', xi.msg.channel.SYSTEM_3)
    end

    awardGauntletReward(
        mob,
        player,
        bossbonus,
        'You receive bonus EXP for defeating the Gauntlet boss!'
    )

    resetTrial()
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

        minLevel = 53,
        maxLevel = 54,

        specialSpawnAnimation = true,
        releaseIdOnDisappear  = true,

        onMobSpawn = function(mob)
            mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)
            mob:setMobMod(xi.mobMod.SPELL_LIST, 153)
            mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
            mob:setMobMod(xi.mobMod.SOUND_RANGE, 15)
            mob:setMobAbilityEnabled(true)
            mob:addStatusEffect(xi.effect.CONFRONTATION, { power = 1, origin = mob })

            if trialTarget then
                mob:updateEnmity(trialTarget)
            end
        end,

        onMobDeath = function(mob, player, optParams)
            mob:setLocalVar('killed', 1)
            aliveNormalMobs = math.max(aliveNormalMobs - 1, 0)
            checkNormalWaveReward(mob, player)
            checkGauntletComplete(mob, player)
        end,

        onMobDespawn = function(mob)
            if activeTrial and mob:getLocalVar('killed') == 0 then
                aliveNormalMobs = math.max(aliveNormalMobs - 1, 0)

                if trialTarget then
                    trialTarget:printToPlayer(
                        'A gauntlet monster despawned. You have failed the gauntlet.',
                        xi.msg.channel.SYSTEM_3
                    )
                end

                resetTrial()
            end
        end,
    })

    if mob then
        aliveNormalMobs = aliveNormalMobs + 1
        mob:setSpawn(x, y, z, 0)
        mob:spawn()
        table.insert(spawnedMobs, mob)
    end

    return mob
end

local function spawnNM(zone, x, y, z, npc)
    local nm = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Bastard Worm',
        groupId     = 37,
        groupZoneId = 81,

        x = x,
        y = y,
        z = z,
        rotation = 0,

        minLevel = 60,
        maxLevel = 60,

        specialSpawnAnimation = true,
        releaseIdOnDisappear  = true,

        onMobSpawn = function(mob)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)
            mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
            mob:setMaxHP(mob:getMaxHP() * 3)
            mob:setHP(mob:getMaxHP())
            mob:setMobMod(xi.mobMod.EXP_BONUS, 500)
            mob:setMod(xi.mod.ATTP, 100)
            mob:setMod(xi.mod.DEFP, 100)
            mob:setMod(xi.mod.ACC, 100)
            mob:setMod(xi.mod.EVA, 50)
            mob:addStatusEffect(xi.effect.CONFRONTATION, { power = 1, origin = mob })
            mob:setMobMod(xi.mobMod.SPELL_LIST, 154)
            mob:setMobAbilityEnabled(true)

            if trialTarget then
                mob:updateEnmity(trialTarget)
            end
        end,

        onMobDeath = function(mob, player, optParams)
            nmKilled = true
            checkGauntletComplete(mob, player)
        end,

        onMobDespawn = function(mob)
            if activeTrial and not nmKilled then
                if trialTarget then
                    trialTarget:printToPlayer(
                        'The Gauntlet boss despawned. You have failed the gauntlet.',
                        xi.msg.channel.SYSTEM_3
                    )
                end

                resetTrial()
            end
        end,
    })

    if nm then
        nm:setSpawn(x, y, z, 0)
        nm:spawn()
        table.insert(spawnedMobs, nm)
    end

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
        spawnNM(zone, spawnX, spawnY, spawnZ, npc)
        return
    end

    for i = 1, 3 do
        local spawnX, spawnY, spawnZ = getRandomSpawnPos(x, y, z)
        spawnNormalMob(zone, spawnX, spawnY, spawnZ)
    end

    if currentWave == maxWaves then
        allWavesSpawned = true
    end

    npc:timer(waveDelay, function(npc)
        spawnWave(npc)
    end)
end

m:addOverride(string.format('xi.zones.%s.Zone.onInitialize', zoneName), function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name    = 'Gauntlet Rift',
        look    = 1045,

        x = npcPos.x,
        y = npcPos.y,
        z = npcPos.z,
        rotation = npcPos.rotation,

        onTrade = function(player, npc, trade)
            if activeTrial then
                player:printToPlayer('A gauntlet is already in progress.', xi.msg.channel.SYSTEM_3)
                return
            end

            if npcUtil.tradeHasExactly(trade, xi.item.WATER_CRYSTAL) then
                player:tradeComplete()

                activeTrial = true
                currentWave = 0
                trialTarget = player
                trialNpc = npc

                aliveNormalMobs = 0
                nmKilled = false
                allWavesSpawned = false
                normalWaveRewardGiven = false

                addConfrontation(player)

                npc:setStatus(xi.status.DISAPPEAR)

                player:printToPlayer(
                    'Get ready for the gauntlet. Wave 1 initializing... ',
                    xi.msg.channel.SYSTEM_3
                )

                spawnWave(npc)
            end
        end,

        onTrigger = function(player, npc)
            if activeTrial then
                player:printToPlayer('The gauntlet is already in progress.', xi.msg.channel.SYSTEM_3)
            else
                player:printToPlayer(
                    'A mysterious gauntlet awaits awakening... [6 Player - Level Cap: 50 - Minimum Level Needed: 40]',
                    xi.msg.channel.SYSTEM_3
                )
            end
        end,
    })
end)

return m