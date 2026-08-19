-----------------------------------
-- Sanctum Variant System
-----------------------------------
require('modules/module_utils')

local m = Module:new('sanctum_variant_system')
m:setEnabled(true)

local variantChance       = 8
local chainbreakerChance  = 15
local chainbreakerDelay   = 5000
local chainbreakerLockout = 3600
local variantExpPerBuff   = 100
local chainbreakerExp     = 1000

local buffCatalog =
{
    hp_25 =
    {
        name = 'HP +25%',
        apply = function(mob)
            mob:addMod(xi.mod.HPP, 25)
        end,
    },

    base_stats_10 =
    {
        name = 'Base Stats +10%',
        apply = function(mob)
            local stats =
            {
                xi.mod.STR,
                xi.mod.DEX,
                xi.mod.VIT,
                xi.mod.AGI,
                xi.mod.INT,
                xi.mod.MND,
                xi.mod.CHR,
            }

            for _, stat in ipairs(stats) do
                mob:addMod(stat, math.max(1, math.floor(mob:getStat(stat) * 0.10)))
            end
        end,
    },

    attack_15 =
    {
        name = 'Attack +15%',
        apply = function(mob)
            mob:addMod(xi.mod.ATTP, 15)
        end,
    },

    defense_20 =
    {
        name = 'Defense +20%',
        apply = function(mob)
            mob:addMod(xi.mod.DEFP, 20)
        end,
    },

    accuracy_25 =
    {
        name = 'Accuracy +25',
        apply = function(mob)
            mob:addMod(xi.mod.ACC, 25)
        end,
    },

    evasion_25 =
    {
        name = 'Evasion +25',
        apply = function(mob)
            mob:addMod(xi.mod.EVA, 25)
        end,
    },

    haste_10 =
    {
        name = 'Haste +10%',
        apply = function(mob)
            mob:addMod(xi.mod.HASTE_ABILITY, 1000)
        end,
    },

    double_attack_10 =
    {
        name = 'Double Attack +10%',
        apply = function(mob)
            mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
        end,
    },

    regain_50 =
    {
        name = 'Regain +50',
        apply = function(mob)
            mob:addMod(xi.mod.REGAIN, 50)
        end,
    },

    regen_3 =
    {
        name = 'Regen +3',
        apply = function(mob)
            mob:addMod(xi.mod.REGEN, 3)
        end,
    },

    poison_attacks =
    {
        name = 'Poison Attacks',
        apply = function(_, state)
            state.poisonAttacks = true
        end,
    },
}

local regionBuffPools =
{
    [xi.region.ZULKHEIM] =
    {
        'hp_25',
        'base_stats_10',
        'attack_15',
        'defense_20',
        'accuracy_25',
        'evasion_25',
        'haste_10',
        'double_attack_10',
        'regain_50',
        'regen_3',
        'poison_attacks',
    },
}

local zoneConfigs =
{
    {
        zoneId       = xi.zone.VALKURM_DUNES,
        zoneName     = 'Valkurm_Dunes',
        region       = xi.region.ZULKHEIM,
        cooldownVar  = '[Variant]103Cooldown',
        cosmetics =
        {
            xi.item.RABBIT_BELT,
            xi.item.WORM_BELT,
            xi.item.GOBLIN_BELT,
            xi.item.CHOCOBO_PULLUS_TORQUE,
        },
        mobs =
        {
            {
                key               = 'thread_leech',
                poolId            = 3901,
                packetName        = 'Thread Leech',
                variantPacketName = 'V Thread Leech',
                chainbreaker =
                {
                    name        = 'Valkurm_Leech_King',
                    packetName  = 'CB Leech King',
                    groupId     = 14,
                    groupZoneId = 274,
                },
            },
        },
    },
}

local mobStates  = {}
local zoneStates = {}

local function getBuffNames(buffIds)
    local names = {}

    for _, buffId in ipairs(buffIds) do
        names[#names + 1] = buffCatalog[buffId].name
    end

    return names
end

local function selectBuffs(pool, count)
    local available = {}
    local selected  = {}

    for index, buffId in ipairs(pool) do
        available[index] = buffId
    end

    for _ = 1, math.min(count, #available) do
        local index = math.randomInt(1, #available)

        selected[#selected + 1] = available[index]
        table.remove(available, index)
    end

    return selected
end

local function applyBuffs(mob, state, pool, count, automaticHpBonus)
    state.buffIds       = selectBuffs(pool, count)
    state.poisonAttacks = false

    if automaticHpBonus > 0 then
        mob:addMod(xi.mod.HPP, automaticHpBonus)
    end

    for _, buffId in ipairs(state.buffIds) do
        buffCatalog[buffId].apply(mob, state)
    end

    mob:updateHealth()
    mob:setHP(mob:getMaxHP())
end

local function getRewardOwner(killer)
    local owner = killer

    while owner ~= nil and not owner:isPC() do
        local master = owner:getMaster()

        if master == nil or master:getID() == owner:getID() then
            return nil
        end

        owner = master
    end

    return owner
end

local function awardBonusExp(mob, killer, amount, label)
    local owner = getRewardOwner(killer)

    if owner == nil then
        return
    end

    local members = owner:getAlliance()
    local seen    = {}
    local reward  = math.floor(amount * xi.settings.main.EXP_RATE)

    for _, member in ipairs(members) do
        if
            member ~= nil and
            member:isPC() and
            not member:isDead() and
            member:getZoneID() == mob:getZoneID() and
            member:checkKillCredit(mob) and
            not seen[member:getID()]
        then
            seen[member:getID()] = true
            member:addExp(reward)
            member:printToPlayer(
                string.format('%s bonus: %u EXP.', label, reward),
                xi.msg.channel.SYSTEM_3)
        end
    end
end

local function notifyNearby(mob, message, distance)
    for _, player in pairs(mob:getZone():getPlayers()) do
        if player:checkDistance(mob) <= distance then
            player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
        end
    end
end

local function notifyZone(zone, message)
    for _, player in pairs(zone:getPlayers()) do
        player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
    end
end

local function applyPoisonAttack(state, mob, target)
    if
        state.poisonAttacks and
        target ~= nil and
        math.randomInt(1, 100) <= 10
    then
        target:addStatusEffect(xi.effect.POISON,
        {
            power    = math.max(1, math.floor(mob:getMainLvl() / 10)),
            duration = 30,
            origin   = mob,
        })
    end
end

local function isChainbreakerAvailable(runtime)
    if runtime.chainbreakerPending then
        return false
    end

    if GetServerVariable(runtime.config.cooldownVar) > GetSystemTime() then
        return false
    end

    for _, boss in pairs(runtime.chainbreakers) do
        if boss ~= nil and boss:isSpawned() then
            return false
        end
    end

    return true
end

local function addCosmeticDrops(boss, zoneConfig)
    boss:addListener('ITEM_DROPS', 'SANCTUM_VARIANT_COSMETICS', function(_, loot)
        local available = {}

        for index, itemId in ipairs(zoneConfig.cosmetics) do
            available[index] = itemId
        end

        if #available == 0 then
            return
        end

        local firstIndex = math.randomInt(1, #available)

        loot:addItemFixed(available[firstIndex], 1000)
        table.remove(available, firstIndex)

        if #available > 0 and math.randomInt(1, 100) <= 50 then
            loot:addItemFixed(available[math.randomInt(1, #available)], 1000)
        end
    end)
end

local function prepareChainbreaker(runtime, mobConfig, boss, level)
    boss:setMobLevel(level)
    boss:setModelSize(3)
    boss:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
    boss:setMobMod(xi.mobMod.NO_DROPS, 0)
    boss:setDropID(0)
    boss:setLocalVar('VariantDeathHandled', 0)

    local state =
    {
        buffIds       = {},
        poisonAttacks = false,
    }

    mobStates[boss:getID()] = state

    applyBuffs(boss, state, regionBuffPools[runtime.config.region], 3, 50)

    notifyZone(
        runtime.zone,
        string.format(
            '%s has emerged! Traits: %s.',
            mobConfig.chainbreaker.packetName,
            table.concat(getBuffNames(state.buffIds), ', ')))
end

local function spawnChainbreaker(runtime, mobConfig, sourceMob)
    if not isChainbreakerAvailable(runtime) then
        return
    end

    runtime.chainbreakerPending = true

    local boss     = runtime.chainbreakers[mobConfig.key]
    local level    = sourceMob:getMainLvl()
    local x        = sourceMob:getXPos()
    local y        = sourceMob:getYPos()
    local z        = sourceMob:getZPos()
    local rotation = sourceMob:getRotPos()

    sourceMob:timer(chainbreakerDelay, function()
        runtime.chainbreakerPending = false

        if boss == nil or not isChainbreakerAvailable(runtime) then
            return
        end

        boss:setSpawn(x, y, z, rotation)
        boss:spawn()
        prepareChainbreaker(runtime, mobConfig, boss, level)
    end)
end

local function activateVariant(state)
    local mob       = state.mob
    local buffCount = math.randomInt(1, 2)

    state.isVariant = true
    mob:setLocalVar('VariantSystemActive', 1)
    mob:renameEntity(state.config.variantPacketName, true)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)

    applyBuffs(
        mob,
        state,
        regionBuffPools[state.runtime.config.region],
        buffCount,
        0)

    notifyNearby(
        mob,
        string.format(
            '%s has appeared with: %s.',
            state.config.variantPacketName,
            table.concat(getBuffNames(state.buffIds), ', ')),
        100)
end

local function resetVariant(state)
    local mob = state.mob

    state.isVariant     = false
    state.buffIds       = {}
    state.poisonAttacks = false

    mob:setLocalVar('VariantSystemActive', 0)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, state.originalCheckAsNm)
    mob:setModelSize(state.originalModelSize)

    if mob:getPacketName() ~= state.originalPacketName then
        mob:renameEntity(state.originalPacketName, true)
    end
end

local function registerVariantMob(runtime, mobConfig, mob)
    if mobStates[mob:getID()] ~= nil then
        return false
    end

    local state =
    {
        mob                 = mob,
        config              = mobConfig,
        runtime             = runtime,
        isVariant           = false,
        buffIds             = {},
        poisonAttacks       = false,
        originalPacketName  = mob:getPacketName(),
        originalModelSize   = mob:getModelSize(),
        originalCheckAsNm   = mob:getMobMod(xi.mobMod.CHECK_AS_NM),
    }

    mobStates[mob:getID()] = state

    mob:addListener('SPAWN', 'SANCTUM_VARIANT_SPAWN', function()
        resetVariant(state)

        if math.randomInt(1, 100) <= variantChance then
            activateVariant(state)
        end
    end)

    mob:addListener('DEATH', 'SANCTUM_VARIANT_DEATH', function(mobArg, killer)
        if not state.isVariant then
            return
        end

        awardBonusExp(
            mobArg,
            killer,
            variantExpPerBuff * #state.buffIds,
            'Variant')

        if
            isChainbreakerAvailable(runtime) and
            math.randomInt(1, 100) <= chainbreakerChance
        then
            spawnChainbreaker(runtime, mobConfig, mobArg)
        end
    end)

    mob:addListener('MELEE_SWING_HIT', 'SANCTUM_VARIANT_POISON', function(mobArg, target)
        applyPoisonAttack(state, mobArg, target)
    end)

    return true
end

local function insertChainbreaker(runtime, mobConfig)
    local chainConfig = mobConfig.chainbreaker
    local boss = runtime.zone:insertDynamicEntity(
    {
        objtype               = xi.objType.MOB,
        name                  = chainConfig.name,
        packetName            = chainConfig.packetName,
        groupId               = chainConfig.groupId,
        groupZoneId           = chainConfig.groupZoneId,
        minLevel              = 1,
        maxLevel              = 1,
        dropId                = 0,
        respawn               = 0,
        modelSize             = 3,
        isAggroable           = false,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,
    })

    if boss == nil then
        printf('[Variant System] Failed to create %s in %s.', chainConfig.packetName, runtime.config.zoneName)
        return
    end

    runtime.chainbreakers[mobConfig.key] = boss

    boss:addListener('MELEE_SWING_HIT', 'SANCTUM_CHAINBREAKER_POISON', function(mobArg, target)
        local state = mobStates[mobArg:getID()]

        if state ~= nil then
            applyPoisonAttack(state, mobArg, target)
        end
    end)

    boss:addListener('DEATH', 'SANCTUM_CHAINBREAKER_DEATH', function(mobArg, killer)
        awardBonusExp(mobArg, killer, chainbreakerExp, 'Chainbreaker')

        if mobArg:getLocalVar('VariantDeathHandled') == 0 then
            local lockoutEnd = GetSystemTime() + chainbreakerLockout

            mobArg:setLocalVar('VariantDeathHandled', 1)
            SetServerVariable(runtime.config.cooldownVar, lockoutEnd, lockoutEnd)
        end
    end)

    addCosmeticDrops(boss, runtime.config)
end

local function initializeZone(zone, zoneConfig)
    local runtime =
    {
        zone                = zone,
        config              = zoneConfig,
        chainbreakers       = {},
        chainbreakerPending = false,
    }

    zoneStates[zoneConfig.zoneId] = runtime

    local registeredMobs = 0

    for _, mobConfig in ipairs(zoneConfig.mobs) do
        insertChainbreaker(runtime, mobConfig)
    end

    for _, mob in pairs(zone:getMobs()) do
        for _, mobConfig in ipairs(zoneConfig.mobs) do
            if
                mob:getPool() == mobConfig.poolId and
                mob:getPacketName() == mobConfig.packetName
            then
                if registerVariantMob(runtime, mobConfig, mob) then
                    registeredMobs = registeredMobs + 1
                end
            end
        end
    end

    printf(
        '[Variant System] Registered %u configured mobs in %s.',
        registeredMobs,
        zoneConfig.zoneName)
end

local function makeZoneInitializer(zoneConfig)
    return function(zone)
        super(zone)
        initializeZone(zone, zoneConfig)
    end
end

for _, zoneConfig in ipairs(zoneConfigs) do
    m:addOverride(
        string.format('xi.zones.%s.Zone.onInitialize', zoneConfig.zoneName),
        makeZoneInitializer(zoneConfig))
end

return m
