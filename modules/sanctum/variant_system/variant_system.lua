-----------------------------------
-- Sanctum Variant System
-----------------------------------
require('modules/module_utils')

local m = Module:new('sanctum_variant_system')
m:setEnabled(true)

local data        = require('modules/sanctum/variant_system/variant_tables')
local zoneConfigs = require('modules/sanctum/variant_system/variant_zones')

local variantChance        = data.settings.variantChance
local chainbreakerChance   = data.settings.chainbreakerChance
local criticalRevealChance = data.settings.criticalRevealChance
local chainbreakerDelay    = data.settings.chainbreakerDelay
local chainbreakerLockout  = data.settings.chainbreakerLockout
local chainbreakerScale    = data.settings.chainbreakerScale
local claimPriority        = data.settings.claimPriority

local buffCatalog         = data.buffCatalog
local regionBuffPools     = data.regionBuffPools
local weaknessCatalog     = data.weaknessCatalog
local globalWeaknessPool  = data.globalWeaknessPool
local cosmeticPools       = data.cosmeticPools

local mobStates  = {}
local zoneStates = {}

local function selectEntries(pool, count)
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

local function resetAppliedState(state)
    if state == nil then
        return
    end

    -- Mob stat calculation restores base modifiers before every SPAWN listener.
    state.appliedModifiers   = {}
    state.poisonAttacks      = false
    state.skillchainWeakness = false
end

local function addTrackedModifier(mob, state, modifierId, value)
    if modifierId == nil or value == nil or value == 0 then
        return
    end

    mob:addMod(modifierId, value)
    state.appliedModifiers[#state.appliedModifiers + 1] =
    {
        mod   = modifierId,
        value = value,
    }
end

local function applyCatalogEntry(mob, state, entry)
    if entry == nil then
        return
    end

    local modifiers = {}

    for _, modifier in ipairs(entry.modifiers or {}) do
        modifiers[#modifiers + 1] = modifier
    end

    if entry.buildModifiers ~= nil then
        for _, modifier in ipairs(entry.buildModifiers(mob, state) or {}) do
            modifiers[#modifiers + 1] = modifier
        end
    end

    for _, modifier in ipairs(modifiers) do
        addTrackedModifier(mob, state, modifier.mod, modifier.value)
    end

    for flag, value in pairs(entry.flags or {}) do
        state[flag] = value
    end
end

local function getEligibleBuffPool(region, level)
    local eligible = {}

    for _, buffId in ipairs(regionBuffPools[region] or {}) do
        local entry = buffCatalog[buffId]
        local minLevel = entry ~= nil and (entry.minLevel or 1) or 1
        local maxLevel = entry ~= nil and (entry.maxLevel or 255) or 0

        if entry ~= nil and level >= minLevel and level <= maxLevel then
            eligible[#eligible + 1] = buffId
        end
    end

    return eligible
end

local function applyBuffs(mob, state, region, count, automaticHpBonus)
    local pool = getEligibleBuffPool(region, mob:getMainLvl())

    state.buffIds       = selectEntries(pool, count)
    state.poisonAttacks = false

    if automaticHpBonus > 0 then
        addTrackedModifier(mob, state, xi.mod.HPP, automaticHpBonus)
    end

    for _, buffId in ipairs(state.buffIds) do
        applyCatalogEntry(mob, state, buffCatalog[buffId])
    end

    mob:updateHealth()
    mob:setHP(mob:getMaxHP())
end

local function applyWeakness(mob, state)
    state.weaknessId          = nil
    state.weaknessName        = nil
    state.weaknessRevealed    = false
    state.skillchainWeakness  = false
    state.lastSkillchainLink  = 0

    if #globalWeaknessPool == 0 then
        return
    end

    local weaknessId = globalWeaknessPool[math.randomInt(1, #globalWeaknessPool)]
    local weakness   = weaknessCatalog[weaknessId]

    if weakness == nil then
        return
    end

    state.weaknessId   = weaknessId
    state.weaknessName = weakness.name
    applyCatalogEntry(mob, state, weakness)
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
    local reward  = math.floor(amount)

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

local function notifyClaimants(mob, message)
    local notified = false

    for _, player in pairs(mob:getZone():getPlayers()) do
        if player:hasClaim(mob) then
            player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
            notified = true
        end
    end

    return notified
end

local function revealWeakness(mob)
    local state = mobStates[mob:getID()]

    if
        state == nil or
        state.weaknessName == nil or
        state.weaknessRevealed or
        not mob:isAlive()
    then
        return
    end

    local revealed = notifyClaimants(
        mob,
        string.format(
            '%s reveals a weakness: %s.',
            state.displayName or mob:getPacketName(),
            state.weaknessName))

    if revealed then
        state.weaknessRevealed = true
    end
end

local function revealWeaknessOnCriticalHit(mob)
    if math.randomInt(1, 100) <= criticalRevealChance then
        revealWeakness(mob)
    end
end

local function revealWeaknessOnSkillchain(mob)
    local state = mobStates[mob:getID()]

    if state == nil then
        return
    end

    local effect = mob:getStatusEffect(xi.effect.SKILLCHAIN)

    if effect == nil or effect:getTier() <= 0 then
        state.lastSkillchainLink = 0
        return
    end

    local link = math.max(1, effect:getSubPower())

    if link <= state.lastSkillchainLink then
        return
    end

    state.lastSkillchainLink = link
    revealWeakness(mob)
end

local function primeSkillchainWeakness(mob, damage)
    local state = mobStates[mob:getID()]

    if
        state == nil or
        not state.skillchainWeakness or
        damage <= 0 or
        not mob:hasStatusEffect(xi.effect.SKILLCHAIN)
    then
        return
    end

    mob:setMod(
        xi.mod.SENGIKORI_SC_DMG_DEBUFF,
        math.max(25, mob:getMod(xi.mod.SENGIKORI_SC_DMG_DEBUFF)))
end

local function handleDamageTaken(mob, damage, attackType)
    primeSkillchainWeakness(mob, damage)

    if attackType == xi.attackType.SPECIAL then
        revealWeaknessOnSkillchain(mob)
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

local function getCosmeticsForLevel(level)
    local available = {}
    local seen      = {}

    for _, pool in ipairs(cosmeticPools) do
        if level >= pool.minLevel and level <= pool.maxLevel then
            for _, item in ipairs(pool.items) do
                local itemId = type(item) == 'table' and (item.itemId or item.id) or item

                if itemId ~= nil and not seen[itemId] then
                    available[#available + 1] = itemId
                    seen[itemId] = true
                end
            end
        end
    end

    return available
end

local function addCosmeticDrops(boss, chainConfig)
    boss:addListener('ITEM_DROPS', 'SANCTUM_VARIANT_COSMETICS', function(mobArg, loot)
        local available = getCosmeticsForLevel(mobArg:getMainLvl())

        if #available > 0 then
            local firstIndex = math.randomInt(1, #available)

            loot:addItemFixed(available[firstIndex], 1000)
            table.remove(available, firstIndex)

            if #available > 0 and math.randomInt(1, 100) <= 50 then
                loot:addItemFixed(available[math.randomInt(1, #available)], 1000)
            end
        end

        for _, drop in ipairs(chainConfig.specialCosmetics or {}) do
            local itemId = type(drop) == 'table' and (drop.itemId or drop.id) or drop
            local rate   = type(drop) == 'table' and (drop.rate or 1000) or 1000

            if itemId ~= nil and rate > 0 then
                loot:addItemFixed(itemId, math.min(1000, rate))
            end
        end
    end)
end

local function prepareChainbreaker(runtime, mobConfig, boss, level)
    resetAppliedState(mobStates[boss:getID()])

    boss:setMobLevel(level)
    boss:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
    boss:setMobMod(xi.mobMod.NO_DROPS, 0)
    boss:setDropID(0)
    boss:setLocalVar('VariantDeathHandled', 0)

    local state =
    {
        appliedModifiers   = {},
        buffIds            = {},
        displayName        = mobConfig.chainbreaker.displayName,
        lastSkillchainLink = 0,
        poisonAttacks      = false,
        skillchainWeakness = false,
        weaknessId         = nil,
        weaknessName       = nil,
        weaknessRevealed   = false,
    }

    mobStates[boss:getID()] = state

    applyBuffs(boss, state, runtime.config.region, 3, 50)
    applyWeakness(boss, state)

    notifyZone(
        runtime.zone,
        string.format('%s has emerged!', mobConfig.chainbreaker.displayName))
end

local function applyClaimPriority(boss, owner)
    if
        owner == nil or
        not owner:isPC() or
        owner:getZoneID() ~= boss:getZoneID()
    then
        return
    end

    boss:setLocalVar('VariantClaimPriority', 1)
    boss:updateClaim(owner)
    boss:timer(claimPriority, function(mobArg)
        if
            mobArg:isSpawned() and
            mobArg:getLocalVar('VariantClaimPriority') == 1
        then
            mobArg:setLocalVar('VariantClaimPriority', 0)

            if not mobArg:isEngaged() then
                mobArg:updateClaim(nil)
            end
        end
    end)
end

local function spawnChainbreaker(runtime, mobConfig, sourceMob, claimOwner)
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
        applyClaimPriority(boss, claimOwner)
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
        state.runtime.config.region,
        buffCount,
        0)
    applyWeakness(mob, state)

    notifyNearby(
        mob,
        string.format('%s has appeared.', state.config.variantDisplayName),
        100)
end

local function resetVariant(state)
    local mob = state.mob

    resetAppliedState(state)

    state.isVariant          = false
    state.buffIds            = {}
    state.lastSkillchainLink = 0
    state.poisonAttacks      = false
    state.skillchainWeakness = false
    state.weaknessId         = nil
    state.weaknessName       = nil
    state.weaknessRevealed   = false

    mob:setLocalVar('VariantSystemActive', 0)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, state.originalCheckAsNm)
    mob:setModelSize(state.originalModelSize)

    if mob:getPacketName() ~= state.originalPacketName then
        mob:renameEntity(state.originalPacketName, true)
    end

    mob:updateHealth()
    mob:setHP(mob:getMaxHP())
end

local function registerVariantMob(runtime, mobConfig, mob)
    if mobStates[mob:getID()] ~= nil then
        return false
    end

    local state =
    {
        appliedModifiers    = {},
        mob                 = mob,
        config              = mobConfig,
        runtime             = runtime,
        isVariant           = false,
        buffIds             = {},
        displayName         = mobConfig.variantDisplayName,
        lastSkillchainLink  = 0,
        poisonAttacks       = false,
        skillchainWeakness  = false,
        weaknessId          = nil,
        weaknessName        = nil,
        weaknessRevealed    = false,
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

        local claimOwner = getRewardOwner(killer)

        awardBonusExp(
            mobArg,
            killer,
            mobArg:getMainLvl() * #state.buffIds * 3,
            'Variant')

        if
            isChainbreakerAvailable(runtime) and
            math.randomInt(1, 100) <= chainbreakerChance
        then
            spawnChainbreaker(runtime, mobConfig, mobArg, claimOwner)
        end
    end)

    mob:addListener('MELEE_SWING_HIT', 'SANCTUM_VARIANT_POISON', function(mobArg, target)
        applyPoisonAttack(state, mobArg, target)
    end)

    mob:addListener('TAKE_DAMAGE', 'SANCTUM_VARIANT_SC_WEAKNESS', function(mobArg, damage, _, attackType)
        handleDamageTaken(mobArg, damage, attackType)
    end)

    mob:addListener('WEAPONSKILL_TAKE', 'SANCTUM_VARIANT_SKILLCHAIN', function(_, mobArg)
        revealWeaknessOnSkillchain(mobArg)
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
        isAggroable           = false,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,
        onCriticalHit         = function(mob)
            revealWeaknessOnCriticalHit(mob)
        end,
    })

    if boss == nil then
        printf('[Variant System] Failed to create %s in %s.', chainConfig.packetName, runtime.config.zoneName)
        return
    end

    local baseHitbox = boss:getHitboxSize()

    if baseHitbox > 0 then
        boss:setHitboxSize(baseHitbox * chainbreakerScale)
    end

    runtime.chainbreakers[mobConfig.key] = boss

    boss:addListener('MELEE_SWING_HIT', 'SANCTUM_CHAINBREAKER_POISON', function(mobArg, target)
        local state = mobStates[mobArg:getID()]

        if state ~= nil then
            applyPoisonAttack(state, mobArg, target)
        end
    end)

    boss:addListener('TAKE_DAMAGE', 'SANCTUM_CHAINBREAKER_SC_WEAKNESS', function(mobArg, damage, _, attackType)
        handleDamageTaken(mobArg, damage, attackType)
    end)

    boss:addListener('WEAPONSKILL_TAKE', 'SANCTUM_CHAINBREAKER_SKILLCHAIN', function(_, mobArg)
        revealWeaknessOnSkillchain(mobArg)
    end)

    boss:addListener('DEATH', 'SANCTUM_CHAINBREAKER_DEATH', function(mobArg, killer)
        local state     = mobStates[mobArg:getID()]
        local buffCount = state ~= nil and #state.buffIds or 0

        mobArg:setLocalVar('VariantClaimPriority', 0)
        awardBonusExp(
            mobArg,
            killer,
            mobArg:getMainLvl() * buffCount * 10,
            'Chainbreaker')

        if mobArg:getLocalVar('VariantDeathHandled') == 0 then
            local lockoutEnd = GetSystemTime() + chainbreakerLockout

            mobArg:setLocalVar('VariantDeathHandled', 1)
            SetServerVariable(runtime.config.cooldownVar, lockoutEnd, lockoutEnd)
        end
    end)

    addCosmeticDrops(boss, chainConfig)
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
            if mob:getName() == mobConfig.mobName then
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

    if registeredMobs == 0 then
        printf(
            '[Variant System] WARNING: No configured mob names were found in %s.',
            zoneConfig.zoneName)
    end
end

local function makeZoneInitializer(zoneConfig)
    return function(zone)
        super(zone)
        initializeZone(zone, zoneConfig)
    end
end

local function addCriticalRevealOverride(zoneConfig, mobConfig)
    local entityPath = string.format(
        'xi.zones.%s.mobs.%s',
        zoneConfig.zoneName,
        mobConfig.mobName)

    xi.module.ensureTable(entityPath)

    local mobEntity = xi.zones[zoneConfig.zoneName].mobs[mobConfig.mobName]

    mobEntity.onCriticalHit = mobEntity.onCriticalHit or function()
    end

    m:addOverride(entityPath .. '.onCriticalHit', function(mob, attacker)
        super(mob, attacker)
        revealWeaknessOnCriticalHit(mob)
    end)
end

for _, zoneConfig in ipairs(zoneConfigs) do
    m:addOverride(
        string.format('xi.zones.%s.Zone.onInitialize', zoneConfig.zoneName),
        makeZoneInitializer(zoneConfig))

    for _, mobConfig in ipairs(zoneConfig.mobs) do
        addCriticalRevealOverride(zoneConfig, mobConfig)
    end
end

return m
