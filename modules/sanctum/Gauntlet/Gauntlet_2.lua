require('modules/module_utils')
require('scripts/globals/npc_util')

local definitions = require('modules/sanctum/Gauntlet/gauntlet_definitions')
local lockout     = require('modules/sanctum/Gauntlet/gauntlet_lockout')
local mobCatalog  = require('modules/sanctum/Gauntlet/gauntlet_mobs')
local rewards     = require('modules/sanctum/Gauntlet/gauntlet_rewards')

local m = Module:new('SanctumGauntletSystem')
m:setEnabled(true)

local runtimes = {}
local mobStates = {}

local failGauntlet
local resetGauntlet
local checkProgress

local function isInteger(value, minimum)
    return
        type(value) == 'number' and
        value == math.floor(value) and
        value >= minimum
end

local function validateDrops(config, waveIndex, entryIndex, dropConfig)
    if dropConfig == nil then
        return
    end

    local prefix = string.format(
        "Gauntlet '%s', wave %u, mob entry %u",
        config.key,
        waveIndex,
        entryIndex)

    for dropIndex, drop in ipairs(dropConfig.fixed or {}) do
        assert(isInteger(drop.itemId, 1), string.format('%s has an invalid fixed drop item at index %u.', prefix, dropIndex))
        assert(isInteger(drop.rate or 1000, 0) and (drop.rate or 1000) <= 1000,
            string.format('%s has an invalid fixed drop rate at index %u.', prefix, dropIndex))
        assert(isInteger(drop.quantity or 1, 1),
            string.format('%s has an invalid fixed drop quantity at index %u.', prefix, dropIndex))
    end

    for groupIndex, group in ipairs(dropConfig.groups or {}) do
        assert(isInteger(group.rate or 1000, 0) and (group.rate or 1000) <= 1000,
            string.format('%s has an invalid drop group rate at index %u.', prefix, groupIndex))
        assert(type(group.items) == 'table' and #group.items > 0,
            string.format('%s has an empty drop group at index %u.', prefix, groupIndex))

        for itemIndex, drop in ipairs(group.items) do
            assert(isInteger(drop.itemId, 1),
                string.format('%s has an invalid group item at group %u, index %u.', prefix, groupIndex, itemIndex))
            assert(isInteger(drop.weight or 1, 1),
                string.format('%s has an invalid group weight at group %u, index %u.', prefix, groupIndex, itemIndex))
            assert(isInteger(drop.quantity or 1, 1),
                string.format('%s has an invalid group quantity at group %u, index %u.', prefix, groupIndex, itemIndex))
        end
    end
end

local function applyRuleDefaults(config)
    local rules = config.rules

    rules.minPlayers        = rules.minPlayers or 1
    rules.maxPlayers        = rules.maxPlayers or 6
    rules.minLevel          = rules.minLevel or 1
    rules.levelCap          = rules.levelCap or 99
    rules.participantRange = rules.participantRange or 50
    rules.timeLimitSeconds  = rules.timeLimitSeconds or 30 * 60
    rules.monitorDelayMs    = rules.monitorDelayMs or 5000
    rules.waveDelayMs       = rules.waveDelayMs or 90000
    rules.spawn             = rules.spawn or {}
    rules.spawn.minDistance = rules.spawn.minDistance or 3
    rules.spawn.maxDistance = rules.spawn.maxDistance or 10
    rules.spawn.attempts    = rules.spawn.attempts or 20
    config.entry.quantity   = config.entry.quantity or 1
end

local function getRiftPositions(config)
    if config.rift.positions then
        return config.rift.positions
    end

    return { config.rift.position }
end

local function validateDefinition(config, keys)
    assert(type(config.key) == 'string' and config.key ~= '', 'Every gauntlet requires a unique key.')
    assert(not keys[config.key], string.format("Duplicate gauntlet key '%s'.", config.key))
    keys[config.key] = true

    assert(type(config.zoneName) == 'string' and config.zoneName ~= '',
        string.format("Gauntlet '%s' requires a zoneName.", config.key))
    assert(isInteger(config.zoneId, 1), string.format("Gauntlet '%s' requires a valid zoneId.", config.key))
    assert(lockout.isValidTier(config.tier), string.format("Gauntlet '%s' requires a valid reward tier.", config.key))
    assert(type(config.rift) == 'table', string.format("Gauntlet '%s' requires a rift.", config.key))
    assert(not (config.rift.position and config.rift.positions),
        string.format("Gauntlet '%s' cannot define both position and positions.", config.key))

    local riftPositions = getRiftPositions(config)

    assert(type(riftPositions) == 'table' and #riftPositions > 0,
        string.format("Gauntlet '%s' requires at least one rift position.", config.key))
    assert(#riftPositions == 1 or config.confrontationKey == nil,
        string.format("Gauntlet '%s' must use automatic confrontation keys when it has multiple rifts.", config.key))

    for positionIndex, position in ipairs(riftPositions) do
        assert(
            type(position) == 'table' and
            type(position.x) == 'number' and
            type(position.y) == 'number' and
            type(position.z) == 'number' and
            isInteger(position.rotation or 0, 0) and
            (position.rotation or 0) <= 255,
            string.format("Gauntlet '%s' has an invalid rift position at index %u.", config.key, positionIndex))
    end

    assert(type(config.rift.name) == 'string' and #config.rift.name <= 15,
        string.format("Gauntlet '%s' requires a rift name no longer than 15 characters.", config.key))
    assert(type(config.rift.packetName or config.rift.name) == 'string' and #(config.rift.packetName or config.rift.name) <= 15,
        string.format("Gauntlet '%s' requires a rift packet name no longer than 15 characters.", config.key))
    assert(type(config.entry) == 'table' and isInteger(config.entry.itemId, 1),
        string.format("Gauntlet '%s' requires a valid entry item.", config.key))
    assert(type(config.rules) == 'table', string.format("Gauntlet '%s' requires rules.", config.key))
    assert(type(config.waves) == 'table' and #config.waves > 0,
        string.format("Gauntlet '%s' requires at least one wave.", config.key))

    applyRuleDefaults(config)

    local rules = config.rules
    local spawn = rules.spawn

    assert(isInteger(config.entry.quantity, 1), string.format("Gauntlet '%s' has an invalid entry quantity.", config.key))
    assert(isInteger(rules.minPlayers, 1) and isInteger(rules.maxPlayers, rules.minPlayers),
        string.format("Gauntlet '%s' has invalid party limits.", config.key))
    assert(isInteger(rules.minLevel, 1) and isInteger(rules.levelCap, rules.minLevel),
        string.format("Gauntlet '%s' has invalid level limits.", config.key))
    assert(type(rules.participantRange) == 'number' and rules.participantRange > 0,
        string.format("Gauntlet '%s' has an invalid participant range.", config.key))
    assert(isInteger(rules.timeLimitSeconds, 1),
        string.format("Gauntlet '%s' has an invalid time limit.", config.key))
    assert(isInteger(rules.monitorDelayMs, 1),
        string.format("Gauntlet '%s' has an invalid monitor delay.", config.key))
    assert(isInteger(rules.waveDelayMs, 0),
        string.format("Gauntlet '%s' has an invalid wave delay.", config.key))
    assert(isInteger(spawn.minDistance, 0) and isInteger(spawn.maxDistance, spawn.minDistance),
        string.format("Gauntlet '%s' has invalid spawn distances.", config.key))
    assert(isInteger(spawn.attempts, 1), string.format("Gauntlet '%s' has invalid spawn attempts.", config.key))
    assert(config.waveCount == #config.waves,
        string.format("Gauntlet '%s' declares %s waves but defines %u.", config.key, tostring(config.waveCount), #config.waves))

    local bossWaveCount = 0

    for waveIndex, wave in ipairs(config.waves) do
        assert(type(wave.mobs) == 'table' and #wave.mobs > 0,
            string.format("Gauntlet '%s' wave %u has no mobs.", config.key, waveIndex))
        assert(wave.bossWave == nil or type(wave.bossWave) == 'boolean',
            string.format("Gauntlet '%s' wave %u has an invalid bossWave value.", config.key, waveIndex))

        if wave.bossWave then
            bossWaveCount = bossWaveCount + 1
        end

        if wave.nextWaveDelayMs ~= nil then
            assert(isInteger(wave.nextWaveDelayMs, 0),
                string.format("Gauntlet '%s' wave %u has an invalid next-wave delay.", config.key, waveIndex))
        end

        if wave.reward then
            assert(isInteger(wave.reward.exp, 1),
                string.format("Gauntlet '%s' wave %u has an invalid EXP reward.", config.key, waveIndex))
        end

        for entryIndex, entry in ipairs(wave.mobs) do
            local definition = mobCatalog.get(entry.mob)

            assert(type(entry.mob) == 'string' and definition ~= nil,
                string.format("Gauntlet '%s' wave %u references unknown mob '%s'.", config.key, waveIndex, tostring(entry.mob)))
            assert(isInteger(entry.count, 1),
                string.format("Gauntlet '%s' wave %u has an invalid count at mob entry %u.", config.key, waveIndex, entryIndex))
            assert(type(definition.name) == 'string' and #(definition.packetName or definition.name) <= 15,
                string.format("Gauntlet mob '%s' requires a packet name no longer than 15 characters.", entry.mob))
            assert(isInteger(definition.groupId, 1) and isInteger(definition.groupZoneId, 1),
                string.format("Gauntlet mob '%s' has invalid group IDs.", entry.mob))
            assert(isInteger(definition.minLevel, 1) and isInteger(definition.maxLevel, definition.minLevel),
                string.format("Gauntlet mob '%s' has invalid levels.", entry.mob))
            assert(wave.bossWave or entry.drops == nil,
                string.format("Gauntlet '%s' wave %u assigns boss drops to a non-boss wave.", config.key, waveIndex))
            validateDrops(config, waveIndex, entryIndex, entry.drops)
        end
    end

    assert(bossWaveCount > 0, string.format("Gauntlet '%s' requires at least one boss wave.", config.key))
end

local function newRun(generation)
    return
    {
        generation                = generation,
        active                    = false,
        currentWave               = 0,
        allWavesSpawned           = false,
        deadline                  = 0,
        initiatorId               = 0,
        participantIds            = {},
        spawnedMobIds             = {},
        confrontationEffectIds    = {},
        levelRestrictionEffectIds = {},
        waveAlive                 = {},
        waveCleared               = {},
        waveRewarded              = {},
        rewardClaims              = {},
        lockoutNotified           = {},
    }
end

local function getNpc(runtime)
    if runtime.npcId == 0 then
        return nil
    end

    return GetNPCByID(runtime.npcId)
end

local function getEffectPower(entity, effectId)
    local effect = entity:getStatusEffect(effectId)

    return effect and effect:getPower() or 0
end

local function getParticipant(runtime, run, id)
    local member = GetPlayerByID(id)
    local npc = getNpc(runtime)

    if
        member == nil or
        npc == nil or
        not member:isPC() or
        member:getZoneID() ~= npc:getZoneID() or
        getEffectPower(member, xi.effect.CONFRONTATION) ~= runtime.confrontationKey
    then
        return nil
    end

    return member
end


local function getInitiator(runtime, run)
    if run.initiatorId == 0 then
        return nil
    end

    return getParticipant(runtime, run, run.initiatorId)
end

local function getEngageTarget(runtime, run)
    local initiator = getInitiator(runtime, run)

    if initiator and initiator:isAlive() then
        return initiator
    end

    for _, id in ipairs(run.participantIds) do
        local member = getParticipant(runtime, run, id)

        if member and member:isAlive() then
            return member
        end
    end

    return nil
end

local function notifyParticipants(run, message)
    for _, id in ipairs(run.participantIds) do
        local member = GetPlayerByID(id)

        if member and member:isPC() then
            member:printToPlayer(message, xi.msg.channel.SYSTEM_3)
        end
    end
end

local function removeRunEffects(runtime, run)
    for id in pairs(run.confrontationEffectIds) do
        local member = GetPlayerByID(id)

        if
            member and
            getEffectPower(member, xi.effect.CONFRONTATION) == runtime.confrontationKey
        then
            member:delStatusEffect(xi.effect.CONFRONTATION)
        end
    end

    for id in pairs(run.levelRestrictionEffectIds) do
        local member = GetPlayerByID(id)

        if
            member and
            getEffectPower(member, xi.effect.LEVEL_RESTRICTION) == runtime.config.rules.levelCap
        then
            member:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
        end
    end
end

resetGauntlet = function(runtime)
    local oldRun = runtime.run
    oldRun.active = false
    runtime.generation = runtime.generation + 1
    runtime.run = newRun(runtime.generation)

    local mobIds = {}

    for id in pairs(oldRun.spawnedMobIds) do
        table.insert(mobIds, id)
    end

    for _, id in ipairs(mobIds) do
        mobStates[id] = nil

        local mob = GetMobByID(id)

        if mob and mob:isSpawned() then
            DespawnMob(id)
        end
    end

    removeRunEffects(runtime, oldRun)

    local npc = getNpc(runtime)

    if npc then
        npc:setStatus(xi.status.NORMAL)
    end
end

failGauntlet = function(runtime, message)
    local run = runtime.run

    if not run.active then
        return
    end

    notifyParticipants(run, message)
    resetGauntlet(runtime)
end

local function getPartyPCs(player)
    local party = player:getParty()
    local members = {}
    local seen = {}

    if party == nil or #party == 0 then
        party = { player }
    end

    for _, member in ipairs(party) do
        if member and member:isPC() and not seen[member:getID()] then
            seen[member:getID()] = true
            table.insert(members, member)
        end
    end

    return members
end

local function validateMembers(runtime, player, npc)
    local rules = runtime.config.rules
    local members = getPartyPCs(player)

    if #members < rules.minPlayers or #members > rules.maxPlayers then
        return nil, string.format(
            'The gauntlet requires between %u and %u players.',
            rules.minPlayers,
            rules.maxPlayers)
    end

    for _, member in ipairs(members) do
        if
            member:getZoneID() ~= npc:getZoneID() or
            member:checkDistance(npc) > rules.participantRange
        then
            return nil, 'All party members must be near the Gauntlet Rift.'
        end

        if not member:isAlive() then
            return nil, 'All party members must be alive to begin the gauntlet.'
        end

        if member:getMainLvl() < rules.minLevel then
            return nil, string.format('All party members must be at least level %u.', rules.minLevel)
        end

        if
            member:hasStatusEffect(xi.effect.CONFRONTATION) or
            member:hasStatusEffect(xi.effect.LEVEL_RESTRICTION) or
            member:hasStatusEffect(xi.effect.LEVEL_SYNC)
        then
            return nil, 'A party member is already participating in restricted content.'
        end
    end

    return members
end

local function applyRunEffects(runtime, run, members)
    for _, member in ipairs(members) do
        local id = member:getID()

        if not member:addStatusEffect(xi.effect.CONFRONTATION, { power = runtime.confrontationKey, origin = member }) then
            return false
        end

        run.confrontationEffectIds[id] = true

        if not member:addStatusEffect(xi.effect.LEVEL_RESTRICTION, { power = runtime.config.rules.levelCap, origin = member }) then
            return false
        end

        run.levelRestrictionEffectIds[id] = true
    end

    return true
end

local function getEligibleRewardMembers(runtime, run)
    local npc = getNpc(runtime)
    local rules = runtime.config.rules
    local members = {}

    if npc == nil then
        return members
    end

    for _, id in ipairs(run.participantIds) do
        local member = getParticipant(runtime, run, id)

        if
            member and
            member:checkDistance(npc) <= rules.participantRange and
            member:getMainLvl() >= rules.minLevel and
            member:getMainLvl() <= rules.levelCap
        then
            table.insert(members, member)
        end
    end

    return members
end

local function getRewardMembers(runtime, run)
    local members = {}

    for _, member in ipairs(getEligibleRewardMembers(runtime, run)) do
        local id = member:getID()

        if run.rewardClaims[id] then
            table.insert(members, member)
        else
            local claimed, claimCount = lockout.claim(member, runtime.config.tier)

            if claimed then
                run.rewardClaims[id] = true
                table.insert(members, member)
                member:printToPlayer(
                    string.format(
                        'Tier %u gauntlet reward claim %u/%u used. Claims reset at conquest tally.',
                        runtime.config.tier,
                        claimCount,
                        lockout.getLimit()),
                    xi.msg.channel.SYSTEM_3)
            elseif not run.lockoutNotified[id] then
                run.lockoutNotified[id] = true
                member:printToPlayer(
                    string.format(
                        'Tier %u weekly reward limit reached. You receive gauntlet kill EXP only.',
                        runtime.config.tier),
                    xi.msg.channel.SYSTEM_3)
            end
        end
    end

    return members
end

local function awardReadyWaveRewards(runtime, run)
    local clearedThrough = true

    for waveIndex, wave in ipairs(runtime.config.waves) do
        clearedThrough = clearedThrough and run.waveCleared[waveIndex] == true

        if clearedThrough and wave.reward and not run.waveRewarded[waveIndex] then
            run.waveRewarded[waveIndex] = true

            local rewardGiven = rewards.awardExp(
                getRewardMembers(runtime, run),
                wave.reward.exp,
                wave.reward.message or string.format('Wave %u reward.', waveIndex))

            if not rewardGiven then
                notifyParticipants(run, string.format('No registered participants had a tier reward available for wave %u.', waveIndex))
            end
        end
    end
end

checkProgress = function(runtime, run)
    if not run.active or runtime.run ~= run then
        return
    end

    awardReadyWaveRewards(runtime, run)

    if run.allWavesSpawned and next(run.spawnedMobIds) == nil then
        notifyParticipants(run, runtime.config.completionMessage or 'The gauntlet is complete!')
        resetGauntlet(runtime)
    end
end

local function getMobContext(runtime, run, mobState)
    return
    {
        gauntlet  = runtime.config,
        wave      = runtime.config.waves[mobState.waveIndex],
        waveIndex = mobState.waveIndex,
        bossWave  = mobState.bossWave,
    }
end

local function resolveMobRun(mob)
    local mobState = mobStates[mob:getID()]

    if mobState == nil then
        return nil
    end

    local runtime = runtimes[mobState.runtimeKey]

    if
        runtime == nil or
        not runtime.run.active or
        runtime.run.generation ~= mobState.generation
    then
        return mobState, runtime, nil
    end

    return mobState, runtime, runtime.run
end

local function onGauntletMobSpawn(mob)
    local mobState, runtime, run = resolveMobRun(mob)

    if run == nil then
        return
    end

    mobCatalog.applyStats(mob, mobState.definition)
    mob:addStatusEffect(xi.effect.CONFRONTATION, { power = runtime.confrontationKey, origin = mob })
    rewards.prepareMob(mob)
    mobCatalog.onSpawn(mob, mobState.definition, getMobContext(runtime, run, mobState))

    local target = getEngageTarget(runtime, run)

    if target then
        mob:updateEnmity(target)
    end
end

local function onGauntletMobFight(mob, target)
    local mobState, runtime, run = resolveMobRun(mob)

    if run then
        mobCatalog.onFight(mob, target, mobState.definition, getMobContext(runtime, run, mobState))
    end
end

local function onGauntletMobDeath(mob, player, optParams)
    local mobState, runtime, run = resolveMobRun(mob)

    if
        run == nil or
        not optParams or
        not optParams.isKiller or
        mob:getLocalVar('gauntletDeathHandled') == 1
    then
        return
    end

    local id = mob:getID()
    mob:setLocalVar('gauntletDeathHandled', 1)
    mob:setLocalVar('gauntletKilled', 1)
    run.spawnedMobIds[id] = nil
    run.waveAlive[mobState.waveIndex] = math.max(0, (run.waveAlive[mobState.waveIndex] or 1) - 1)

    if rewards.hasDrops(mobState.drops) then
        rewards.awardPersonalDrops(
            mob,
            mobState.drops,
            getRewardMembers(runtime, run),
            getEligibleRewardMembers(runtime, run))
    end

    mobCatalog.onDeath(
        mob,
        player,
        optParams,
        mobState.definition,
        getMobContext(runtime, run, mobState))

    if run.waveAlive[mobState.waveIndex] == 0 then
        run.waveCleared[mobState.waveIndex] = true
    end

    checkProgress(runtime, run)
end

local function onGauntletMobDespawn(mob)
    local mobState, runtime, run = resolveMobRun(mob)

    if mobState == nil then
        return
    end

    mobStates[mob:getID()] = nil

    if run == nil then
        return
    end

    mobCatalog.onDespawn(mob, mobState.definition, getMobContext(runtime, run, mobState))

    local wasTracked = run.spawnedMobIds[mob:getID()] == true
    run.spawnedMobIds[mob:getID()] = nil

    if wasTracked and mob:getLocalVar('gauntletKilled') == 0 then
        failGauntlet(runtime, 'A gauntlet monster despawned. You have failed the gauntlet.')
    end
end

local function getRandomSpawnPosition(runtime, zone, x, y, z)
    local spawn = runtime.config.rules.spawn

    for _ = 1, spawn.attempts do
        local angle = math.randomFloat(0, 1) * math.pi * 2
        local distance = math.randomInt(spawn.minDistance, spawn.maxDistance)
        local spawnX = x + math.cos(angle) * distance
        local spawnZ = z + math.sin(angle) * distance

        if zone:isNavigablePoint({ x = spawnX, y = y, z = spawnZ }) then
            return spawnX, y, spawnZ
        end
    end

    return nil
end

local function spawnMob(runtime, run, waveIndex, entry)
    local npc = getNpc(runtime)

    if npc == nil then
        return nil
    end

    local zone = npc:getZone()
    local x, y, z = getRandomSpawnPosition(runtime, zone, npc:getXPos(), npc:getYPos(), npc:getZPos())

    if x == nil then
        return nil
    end

    local definition = mobCatalog.get(entry.mob)
    local entity =
    {
        objtype     = xi.objType.MOB,
        name        = definition.name,
        groupId     = definition.groupId,
        groupZoneId = definition.groupZoneId,

        x        = x,
        y        = y,
        z        = z,
        rotation = definition.rotation or 0,

        minLevel = definition.minLevel,
        maxLevel = definition.maxLevel,

        specialSpawnAnimation = definition.specialSpawnAnimation ~= false,
        releaseIdOnDisappear  = true,

        onMobSpawn   = onGauntletMobSpawn,
        onMobFight   = onGauntletMobFight,
        onMobDeath   = onGauntletMobDeath,
        onMobDespawn = onGauntletMobDespawn,
    }

    if definition.packetName then
        entity.packetName = definition.packetName
    end

    if definition.look then
        entity.look = definition.look
    end

    local mob = zone:insertDynamicEntity(entity)

    if mob == nil then
        return nil
    end

    local id = mob:getID()
    local wave = runtime.config.waves[waveIndex]

    mobStates[id] =
    {
        runtimeKey   = runtime.key,
        generation  = run.generation,
        waveIndex   = waveIndex,
        bossWave    = wave.bossWave == true,
        definition  = definition,
        drops       = entry.drops,
    }

    run.spawnedMobIds[id] = true
    run.waveAlive[waveIndex] = (run.waveAlive[waveIndex] or 0) + 1

    mob:setSpawn(x, y, z, definition.rotation or 0)
    mob:spawn()

    if
        not mob:isSpawned() or
        mob:getConfrontationEffect() ~= runtime.confrontationKey
    then
        run.spawnedMobIds[id] = nil
        run.waveAlive[waveIndex] = math.max(0, run.waveAlive[waveIndex] - 1)
        mobStates[id] = nil
        DespawnMob(id)
        return nil
    end

    return id
end

local function scheduleWave(runtime, run, waveIndex)
    local npc = getNpc(runtime)

    if npc == nil then
        failGauntlet(runtime, 'The Gauntlet Rift is no longer available.')
        return
    end

    local previousWave = runtime.config.waves[waveIndex - 1]
    local delay = previousWave.nextWaveDelayMs or runtime.config.rules.waveDelayMs
    local generation = run.generation

    npc:timer(delay, function(_)
        if
            runtime.run.active and
            runtime.run.generation == generation
        then
            local currentRun = runtime.run
            local wave = runtime.config.waves[waveIndex]

            if getInitiator(runtime, currentRun) == nil then
                failGauntlet(runtime, 'The gauntlet initiator is no longer present. You have failed the gauntlet.')
                return
            end

            if getEngageTarget(runtime, currentRun) == nil then
                failGauntlet(runtime, 'No active gauntlet participants remain. You have failed the gauntlet.')
                return
            end

            currentRun.currentWave = waveIndex
            currentRun.waveAlive[waveIndex] = 0

            for _, entry in ipairs(wave.mobs) do
                for _ = 1, entry.count do
                    if spawnMob(runtime, currentRun, waveIndex, entry) == nil then
                        failGauntlet(runtime, string.format('Gauntlet wave %u could not be created. The gauntlet has been reset.', waveIndex))
                        return
                    end
                end
            end

            notifyParticipants(
                currentRun,
                wave.message or string.format('%s %u has begun!', wave.bossWave and 'Boss wave' or 'Wave', waveIndex))

            if waveIndex == #runtime.config.waves then
                currentRun.allWavesSpawned = true
            else
                scheduleWave(runtime, currentRun, waveIndex + 1)
            end

            checkProgress(runtime, currentRun)
        end
    end)
end

local function spawnFirstWave(runtime, run)
    local wave = runtime.config.waves[1]

    run.currentWave = 1
    run.waveAlive[1] = 0

    for _, entry in ipairs(wave.mobs) do
        for _ = 1, entry.count do
            if spawnMob(runtime, run, 1, entry) == nil then
                failGauntlet(runtime, 'Gauntlet wave 1 could not be created. The gauntlet has been reset.')
                return false
            end
        end
    end

    notifyParticipants(run, wave.message or 'Wave 1 has begun!')

    if #runtime.config.waves == 1 then
        run.allWavesSpawned = true
    else
        scheduleWave(runtime, run, 2)
    end

    return true
end

local function monitorGauntlet(runtime, generation)
    local npc = getNpc(runtime)

    if npc == nil then
        failGauntlet(runtime, 'The Gauntlet Rift is no longer available.')
        return
    end

    npc:timer(runtime.config.rules.monitorDelayMs, function(_)
        local run = runtime.run

        if not run.active or run.generation ~= generation then
            return
        end

        if GetSystemTime() >= run.deadline then
            failGauntlet(runtime, string.format(
                'The %u-minute gauntlet time limit has expired.',
                math.floor(runtime.config.rules.timeLimitSeconds / 60)))
            return
        end

        if getInitiator(runtime, run) == nil then
            failGauntlet(runtime, 'The gauntlet initiator is no longer present. You have failed the gauntlet.')
            return
        end

        if getEngageTarget(runtime, run) == nil then
            failGauntlet(runtime, 'No active gauntlet participants remain. You have failed the gauntlet.')
            return
        end

        monitorGauntlet(runtime, generation)
    end)
end

local function notifyRewardStatus(player, tier)
    local remaining = lockout.getRemaining(player, tier)

    if remaining > 0 then
        player:printToPlayer(
            string.format(
                'Tier %u gauntlet rewards remaining this conquest week: %u/%u.',
                tier,
                remaining,
                lockout.getLimit()),
            xi.msg.channel.SYSTEM_3)
    else
        player:printToPlayer(
            string.format(
                'Tier %u weekly reward limit reached. You may still participate for kill EXP.',
                tier),
            xi.msg.channel.SYSTEM_3)
    end
end

local function startGauntlet(runtime, player, npc, members)
    runtime.generation = runtime.generation + 1
    runtime.run = newRun(runtime.generation)

    local run = runtime.run
    run.active = true
    run.deadline = GetSystemTime() + runtime.config.rules.timeLimitSeconds
    run.initiatorId = player:getID()

    for _, member in ipairs(members) do
        table.insert(run.participantIds, member:getID())
    end

    if not applyRunEffects(runtime, run, members) then
        failGauntlet(runtime, 'The gauntlet could not apply its battle restrictions.')
        return false
    end

    npc:setStatus(xi.status.DISAPPEAR)

    if not spawnFirstWave(runtime, run) then
        return false
    end

    for _, member in ipairs(members) do
        notifyRewardStatus(member, runtime.config.tier)
    end

    player:tradeComplete()
    monitorGauntlet(runtime, run.generation)
    return true
end

local function getRiftPrompt(config)
    if config.rift.prompt then
        return config.rift.prompt
    end

    return string.format(
        'A mysterious gauntlet awaits awakening... [%u-%u Players - Level Cap: %u - Minimum Level: %u - Time Limit: %u Minutes - Waves: %u]',
        config.rules.minPlayers,
        config.rules.maxPlayers,
        config.rules.levelCap,
        config.rules.minLevel,
        math.floor(config.rules.timeLimitSeconds / 60),
        config.waveCount)
end

local function insertRift(zone, runtime)
    local config = runtime.config
    local position = runtime.position

    assert(zone:getID() == config.zoneId,
        string.format("Gauntlet '%s' expected zone %u but loaded in zone %u.", config.key, config.zoneId, zone:getID()))

    local entity =
    {
        objtype = xi.objType.NPC,
        name    = string.format('%s %s', config.rift.name, runtime.key),
        packetName = config.rift.packetName or config.rift.name,
        look    = config.rift.look,

        x        = position.x,
        y        = position.y,
        z        = position.z,
        rotation = position.rotation or 0,

        onTrade = function(player, npc, trade)
            if runtime.run.active then
                player:printToPlayer('A gauntlet is already in progress.', xi.msg.channel.SYSTEM_3)
                return
            end

            if not npcUtil.tradeMatches(trade, { { config.entry.itemId, config.entry.quantity } }) then
                return
            end

            local members, validationError = validateMembers(runtime, player, npc)

            if members == nil then
                player:printToPlayer(validationError, xi.msg.channel.SYSTEM_3)
                return
            end

            startGauntlet(runtime, player, npc, members)
        end,

        onTrigger = function(player, _)
            if runtime.run.active then
                player:printToPlayer('The gauntlet is already in progress.', xi.msg.channel.SYSTEM_3)
            else
                player:printToPlayer(getRiftPrompt(config), xi.msg.channel.SYSTEM_3)
                notifyRewardStatus(player, config.tier)
            end
        end,
    }

    local rift = zone:insertDynamicEntity(entity)

    if rift == nil then
        printf('[SanctumGauntletSystem] Failed to create the %s rift in %s.', runtime.key, config.zoneName)
        return
    end

    runtime.npcId = rift:getID()
    runtime.confrontationKey = config.confrontationKey or rift:getTargID()

    assert(runtime.confrontationKey > 0,
        string.format("Gauntlet '%s' could not acquire a confrontation key.", config.key))
end

local function registerZoneOverride(zoneName, zoneRuntimes)
    m:addOverride(string.format('xi.zones.%s.Zone.onInitialize', zoneName), function(zone)
        super(zone)

        for _, runtime in ipairs(zoneRuntimes) do
            insertRift(zone, runtime)
        end
    end)
end

local keys = {}
local definitionsByZone = {}

for _, config in ipairs(definitions) do
    validateDefinition(config, keys)

    for positionIndex, position in ipairs(getRiftPositions(config)) do
        local runtimeKey = string.format('%s:%u', config.key, positionIndex)
        local runtime =
        {
            key                = runtimeKey,
            config             = config,
            position           = position,
            npcId              = 0,
            confrontationKey   = 0,
            generation         = 0,
            run                = newRun(0),
        }

        runtimes[runtimeKey] = runtime

        if not config.disabled then
            definitionsByZone[config.zoneName] = definitionsByZone[config.zoneName] or {}
            table.insert(definitionsByZone[config.zoneName], runtime)
        end
    end
end

for zoneName, zoneRuntimes in pairs(definitionsByZone) do
    registerZoneOverride(zoneName, zoneRuntimes)
end

return m
