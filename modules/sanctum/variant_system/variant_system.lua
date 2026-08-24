-----------------------------------
-- Sanctum Variant System
-----------------------------------
require('modules/module_utils')

local m = Module:new('sanctum_variant_system')
m:setEnabled(true)

local data        = require('modules/sanctum/variant_system/variant_tables')
local effects     = require('modules/sanctum/variant_system/variant_effects')
local rewards     = require('modules/sanctum/variant_system/variant_rewards')
local zoneConfigs = require('modules/sanctum/variant_system/variant_zones')

local variantChance           = data.settings.variantChance
local chainbreakerChance      = data.settings.chainbreakerChance
local criticalRevealChance    = data.settings.criticalRevealChance
local chainbreakerDelay       = data.settings.chainbreakerDelay
local chainbreakerLockoutMin  = data.settings.chainbreakerLockoutMin
local chainbreakerLockoutMax  = data.settings.chainbreakerLockoutMax
local chainbreakerScale       = data.settings.chainbreakerScale
local claimPriority           = data.settings.claimPriority
local zoneBossThreshold       = data.settings.zoneBossThreshold
local zoneBossChance          = data.settings.zoneBossChance
local zoneBossSpawnDelay      = data.settings.zoneBossSpawnDelay
local zoneBossBuffCount       = data.settings.zoneBossBuffCount or 5
local zoneBossActionPoints    = data.settings.zoneBossActionPoints

local addCosmeticDrops  = rewards.addCosmeticDrops
local applyBuffs        = effects.applyBuffs
local applyWeakness     = effects.applyWeakness
local awardBonusExp     = rewards.awardBonusExp
local getBuffNames      = effects.getBuffNames
local getRewardOwner    = rewards.getRewardOwner
local resetAppliedState = effects.resetAppliedState

local mobStates      = {}
local zoneStates     = {}
local zoneBossStates = {}

local healingMessages =
{
    [xi.msg.basic.MAGIC_RECOVERS_HP]  = true,
    [xi.msg.basic.RECOVERS_HP]        = true,
    [xi.msg.basic.RECOVERS_HP_AND_MP] = true,
    [xi.msg.basic.JA_RECOVERS_HP]     = true,
    [xi.msg.basic.SKILL_RECOVERS_HP]  = true,
    [xi.msg.basic.JA_RECOVERS_HP_2]   = true,
}

local zoneBossHealingListeners =
{
    ability = 'SANCTUM_ZONE_BOSS_HEAL_ABILITY',
    magic   = 'SANCTUM_ZONE_BOSS_HEAL_MAGIC',
    skill   = 'SANCTUM_ZONE_BOSS_HEAL_SKILL',
}

local function newEncounterState(config, runtime, displayName)
    return
    {
        appliedModifiers   = {},
        automaticHpBonus   = 0,
        buffIds            = {},
        config             = config,
        displayName        = displayName,
        lastSkillchainLink = 0,
        poisonAttacks      = false,
        runtime            = runtime,
        skillchainWeakness = false,
        weaknessId         = nil,
        weaknessName       = nil,
        weaknessRevealed   = false,
    }
end

local function normalizeLevel(level, fallback)
    return math.floor(math.max(1, math.min(255, tonumber(level) or fallback)))
end

local function getConfiguredMobNames(mobConfig)
    if mobConfig.mobNames ~= nil then
        return mobConfig.mobNames
    end

    return { mobConfig.mobName }
end

local function matchesConfiguredMob(mobConfig, mobName)
    for _, configuredName in ipairs(getConfiguredMobNames(mobConfig)) do
        if configuredName == mobName then
            return true
        end
    end

    return false
end

local function isConfiguredVariantLevel(mobConfig, mob)
    local level = mob:getMainLvl()

    return
        level >= (mobConfig.minLevel or 1) and
        level <= (mobConfig.maxLevel or 255)
end

local function scaleHitbox(mob, scale)
    local baseHitbox = mob:getHitboxSize()

    if baseHitbox > 0 then
        mob:setHitboxSize(baseHitbox * (scale or 1))
    end
end

local function summarizeParticipants(state)
    local participantCount = 0
    local totalPoints       = 0

    for _, participant in pairs(state ~= nil and state.participants or {}) do
        participantCount = participantCount + 1
        totalPoints       = totalPoints + participant.points
    end

    return participantCount, totalPoints
end

local function getEncounterState(mob)
    if mob == nil then
        return nil
    end

    return mobStates[mob:getID()] or zoneBossStates[mob:getID()]
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

local function notifyWeaknessAudience(mob, state, message)
    if not state.isZoneBoss then
        return notifyClaimants(mob, message)
    end

    local notified = false

    for playerId in pairs(state.participants or {}) do
        local player = GetPlayerByID(playerId)

        if
            player ~= nil and
            player:isPC() and
            player:getZoneID() == mob:getZoneID()
        then
            player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
            notified = true
        end
    end

    return notified
end

local function revealWeakness(mob)
    local state = getEncounterState(mob)

    if
        state == nil or
        state.weaknessName == nil or
        state.weaknessRevealed or
        not mob:isAlive()
    then
        return
    end

    local revealed = notifyWeaknessAudience(
        mob,
        state,
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
    local state = getEncounterState(mob)

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
    local state = getEncounterState(mob)

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

local function addEncounterCombatListeners(mob, listenerPrefix, getState)
    mob:addListener('MELEE_SWING_HIT', listenerPrefix .. '_POISON', function(mobArg, target)
        local state = getState(mobArg)

        if state ~= nil then
            applyPoisonAttack(state, mobArg, target)
        end
    end)

    mob:addListener('TAKE_DAMAGE', listenerPrefix .. '_SC_WEAKNESS', function(mobArg, damage, _, attackType)
        handleDamageTaken(mobArg, damage, attackType)
    end)

    mob:addListener('WEAPONSKILL_TAKE', listenerPrefix .. '_SKILLCHAIN', function(_, mobArg)
        revealWeaknessOnSkillchain(mobArg)
    end)
end

local function getChainbreakerCooldownVar(runtime, mobConfig)
    return string.format(
        '[Variant]%u:%s:Cooldown',
        runtime.config.zoneId,
        mobConfig.key)
end

local function isChainbreakerAvailable(runtime, mobConfig)
    if mobConfig.chainbreaker == nil then
        return false
    end

    if runtime.chainbreakerPending[mobConfig.key] then
        return false
    end

    if GetServerVariable(getChainbreakerCooldownVar(runtime, mobConfig)) > GetSystemTime() then
        return false
    end

    local boss = runtime.chainbreakers[mobConfig.key]

    return boss == nil or not boss:isSpawned()
end

local function getZoneBossKillCountVar(runtime)
    return string.format('[Variant]%u:ZoneBossKills', runtime.config.zoneId)
end

local function getZoneBossKillCount(runtime)
    return math.max(0, GetServerVariable(getZoneBossKillCountVar(runtime)))
end

local function setZoneBossKillCount(runtime, count)
    SetServerVariable(
        getZoneBossKillCountVar(runtime),
        math.max(0, math.floor(tonumber(count) or 0)))
end

local function ensureZoneBossParticipant(state, boss, actor)
    local owner = getRewardOwner(actor)

    if
        state == nil or
        not state.active or
        owner == nil or
        owner:getZoneID() ~= boss:getZoneID()
    then
        return nil
    end

    local playerId = owner:getID()
    local participant = state.participants[playerId]

    if participant == nil then
        participant =
        {
            name   = owner:getName(),
            points = 0,
        }

        state.participants[playerId] = participant
    end

    return participant
end

local function recordZoneBossParticipation(boss, actor, actionType, amount)
    local state = boss ~= nil and zoneBossStates[boss:getID()] or nil
    local participant = ensureZoneBossParticipant(state, boss, actor)

    if participant == nil then
        return false
    end

    local pointValues = state.config.pointValues or {}
    local pointsPerAction = pointValues[actionType] or zoneBossActionPoints
    local points = math.floor(math.max(0, tonumber(amount) or 1) * pointsPerAction)

    if points < 1 then
        return false
    end

    participant.points = participant.points + points

    return true
end

local function removeZoneBossHealingListeners(entity)
    if entity == nil then
        return
    end

    pcall(function()
        entity:removeListener(zoneBossHealingListeners.ability)
        entity:removeListener(zoneBossHealingListeners.magic)
        entity:removeListener(zoneBossHealingListeners.skill)
    end)
end

local function clearZoneBossHealingListeners(state)
    for _, entity in pairs(state.healingListeners or {}) do
        removeZoneBossHealingListeners(entity)
    end

    state.healingListeners = {}
end

local function deactivateZoneBoss(state)
    if state == nil then
        return
    end

    state.active = false
    state.listenerGeneration = state.listenerGeneration + 1
    clearZoneBossHealingListeners(state)
    state.participants = {}
end

local function hasZoneBossEnmity(boss, target)
    if target == nil then
        return false
    end

    local targetId = target:getID()

    for _, entry in pairs(boss:getEnmityList() or {}) do
        local entity = entry.entity
        local active = entry.active == true or
            (tonumber(entry.ce) or 0) + (tonumber(entry.ve) or 0) > 0

        if
            active and
            entity ~= nil and
            entity:getID() == targetId
        then
            return true
        end
    end

    return false
end

local function recordZoneBossHealing(boss, actor, target, action)
    if
        boss == nil or
        target == nil or
        action == nil or
        target:getZoneID() ~= boss:getZoneID()
    then
        return false
    end

    local targetId = target:getID()
    local amount    = tonumber(action:getParam(targetId)) or 0
    local messageId = action:getMsg(targetId)

    if
        amount <= 0 or
        not healingMessages[messageId] or
        not hasZoneBossEnmity(boss, target)
    then
        return false
    end

    return recordZoneBossParticipation(boss, actor, 'healing', 1)
end

local function addZoneBossHealingListeners(state, entity)
    if
        entity == nil or
        entity:getZoneID() ~= state.runtime.config.zoneId
    then
        return
    end

    local entityId = entity:getID()
    local existing = state.healingListeners[entityId]

    if existing == entity then
        return
    end

    removeZoneBossHealingListeners(existing)
    removeZoneBossHealingListeners(entity)

    entity:addListener('MAGIC_USE', zoneBossHealingListeners.magic, function(actor, target, _, action)
        recordZoneBossHealing(state.runtime.zoneBoss, actor, target, action)
    end)

    entity:addListener('ABILITY_USE', zoneBossHealingListeners.ability, function(actor, target, _, action)
        recordZoneBossHealing(state.runtime.zoneBoss, actor, target, action)
    end)

    entity:addListener('WEAPONSKILL_USE', zoneBossHealingListeners.skill, function(actor, target, _, _, action)
        recordZoneBossHealing(state.runtime.zoneBoss, actor, target, action)
    end)

    state.healingListeners[entityId] = entity
end

local function syncZoneBossHealingListeners(state)
    local present = {}

    for _, player in pairs(state.runtime.zone:getPlayers()) do
        addZoneBossHealingListeners(state, player)
        present[player:getID()] = true

        local pet = player:getPet()

        if pet ~= nil then
            addZoneBossHealingListeners(state, pet)
            present[pet:getID()] = true
        end
    end

    for entityId, entity in pairs(state.healingListeners) do
        if not present[entityId] then
            removeZoneBossHealingListeners(entity)
            state.healingListeners[entityId] = nil
        end
    end
end

local function scheduleZoneBossHealingSync(state, generation)
    state.runtime.zoneBoss:timer(1000, function()
        if
            not state.active or
            state.listenerGeneration ~= generation
        then
            return
        end

        syncZoneBossHealingListeners(state)
        scheduleZoneBossHealingSync(state, generation)
    end)
end

local function prepareZoneBoss(runtime, level)
    local boss       = runtime.zoneBoss
    local bossConfig = runtime.config.zoneBoss
    local state      = zoneBossStates[boss:getID()]

    clearZoneBossHealingListeners(state)
    resetAppliedState(state)

    state.active           = true
    state.automaticHpBonus = 0
    state.buffIds          = {}
    state.deathHandled     = false
    state.lastSkillchainLink = 0
    state.listenerGeneration = (state.listenerGeneration or 0) + 1
    state.participants = {}
    state.weaknessId   = nil
    state.weaknessName = nil
    state.weaknessRevealed = false
    runtime.zoneBossPending = false

    boss:setMobLevel(level or bossConfig.level)
    -- Zone bosses must not use the tracking-list level exemption for variants.
    boss:setLocalVar('VariantSystemActive', 0)
    boss:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
    boss:setMobMod(xi.mobMod.CLAIM_TYPE, xi.claimType.UNCLAIMABLE)
    boss:setMobMod(xi.mobMod.NO_AGGRO, 1)
    boss:setMobMod(xi.mobMod.NO_DROPS, 1)
    boss:setMobMod(
        xi.mobMod.BASE_DAMAGE_MULTIPLIER,
        bossConfig.damageMultiplier or 100)
    boss:setDropID(0)

    if bossConfig.maxHp ~= nil then
        boss:setMaxHP(bossConfig.maxHp)
    end

    applyBuffs(boss, state, zoneBossBuffCount, 0)
    applyWeakness(boss, state)

    local generation = state.listenerGeneration

    syncZoneBossHealingListeners(state)
    scheduleZoneBossHealingSync(state, generation)
end

local function spawnZoneBoss(runtime, positionSource, level)
    local boss       = runtime.zoneBoss
    local bossConfig = runtime.config.zoneBoss

    if
        boss == nil or
        bossConfig == nil or
        runtime.zoneBossPending or
        boss:isSpawned()
    then
        return false
    end

    local spawn = bossConfig.spawn

    if positionSource ~= nil then
        spawn =
        {
            x        = positionSource:getXPos(),
            y        = positionSource:getYPos(),
            z        = positionSource:getZPos(),
            rotation = positionSource:getRotPos(),
        }
    end

    if spawn == nil then
        return false
    end

    runtime.zoneBossPending = true
    boss:setSpawn(spawn.x, spawn.y, spawn.z, spawn.rotation or 0)
    boss:spawn()
    prepareZoneBoss(runtime, level)

    return true
end

local function trySpawnZoneBoss(runtime, timerSource)
    if runtime.config.zoneBoss == nil or runtime.zoneBoss == nil then
        return false
    end

    local state = zoneBossStates[runtime.zoneBoss:getID()]

    if
        runtime.zoneBossPending or
        (state ~= nil and state.active)
    then
        return false
    end

    local killCount = getZoneBossKillCount(runtime) + 1

    setZoneBossKillCount(runtime, killCount)

    if
        killCount < zoneBossThreshold or
        math.randomInt(1, 100) > zoneBossChance
    then
        return false
    end

    runtime.zoneBossPending = true
    setZoneBossKillCount(runtime, 0)

    timerSource:timer(zoneBossSpawnDelay, function()
        runtime.zoneBossPending = false

        if not spawnZoneBoss(runtime) then
            setZoneBossKillCount(
                runtime,
                math.max(zoneBossThreshold, getZoneBossKillCount(runtime)))
        end
    end)

    return true
end

local function insertZoneBoss(runtime)
    local bossConfig = runtime.config.zoneBoss

    if bossConfig == nil then
        return
    end

    local spawn = bossConfig.spawn or { x = 0, y = 0, z = 0, rotation = 0 }
    local boss = runtime.zone:insertDynamicEntity(
    {
        objtype               = xi.objType.MOB,
        name                  = bossConfig.name,
        packetName            = bossConfig.packetName,
        groupId               = bossConfig.groupId,
        groupZoneId           = bossConfig.groupZoneId,
        look                  = bossConfig.look,
        modelHitboxSize       = bossConfig.baseHitbox,
        x                     = spawn.x,
        y                     = spawn.y,
        z                     = spawn.z,
        rotation              = spawn.rotation or 0,
        minLevel              = bossConfig.level,
        maxLevel              = bossConfig.level,
        dropId                = 0,
        respawn               = 0,
        isAggroable           = false,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,
        onCriticalHit         = function(mob, attacker)
            ensureZoneBossParticipant(zoneBossStates[mob:getID()], mob, attacker)
            revealWeaknessOnCriticalHit(mob)
        end,
    })

    if boss == nil then
        printf(
            '[Variant System] Failed to create Zone Boss %s in %s.',
            bossConfig.packetName,
            runtime.config.zoneName)
        return
    end

    scaleHitbox(boss, bossConfig.hitboxScale)

    runtime.zoneBoss = boss
    local state = newEncounterState(bossConfig, runtime, bossConfig.displayName)

    state.active             = false
    state.deathHandled       = false
    state.healingListeners   = {}
    state.isZoneBoss         = true
    state.listenerGeneration = 0
    state.participants       = {}
    zoneBossStates[boss:getID()] = state

    boss:setMobMod(xi.mobMod.CLAIM_TYPE, xi.claimType.UNCLAIMABLE)
    boss:setMobMod(xi.mobMod.NO_AGGRO, 1)
    boss:setMobMod(xi.mobMod.NO_DROPS, 1)
    boss:setDropID(0)

    boss:addListener('ATTACKED', 'SANCTUM_ZONE_BOSS_MELEE_POINTS', function(mobArg, attacker)
        recordZoneBossParticipation(mobArg, attacker, 'melee', 1)
    end)

    boss:addListener('MAGIC_TAKE', 'SANCTUM_ZONE_BOSS_MAGIC_POINTS', function(mobArg, caster)
        recordZoneBossParticipation(mobArg, caster, 'magic', 1)
    end)

    boss:addListener('WEAPONSKILL_TAKE', 'SANCTUM_ZONE_BOSS_WS_POINTS', function(user, mobArg)
        recordZoneBossParticipation(mobArg, user, 'weaponskill', 1)
        revealWeaknessOnSkillchain(mobArg)
    end)

    boss:addListener('ABILITY_TAKE', 'SANCTUM_ZONE_BOSS_ABILITY_POINTS', function(user, mobArg)
        recordZoneBossParticipation(mobArg, user, 'ability', 1)
    end)

    boss:addListener('TAKE_DAMAGE', 'SANCTUM_ZONE_BOSS_RANGED_POINTS', function(mobArg, damage, attacker, attackType)
        handleDamageTaken(mobArg, damage, attackType)

        if damage > 0 and attackType == xi.attackType.RANGED then
            recordZoneBossParticipation(mobArg, attacker, 'ranged', 1)
        end
    end)

    boss:addListener('MELEE_SWING_HIT', 'SANCTUM_ZONE_BOSS_POISON', function(mobArg, target)
        local state = zoneBossStates[mobArg:getID()]

        if state ~= nil then
            applyPoisonAttack(state, mobArg, target)
        end
    end)

    boss:addListener('DEATH', 'SANCTUM_ZONE_BOSS_DEATH', function(mobArg)
        local state = zoneBossStates[mobArg:getID()]

        if state == nil or state.deathHandled then
            return
        end

        state.deathHandled = true
        rewards.awardZoneBossRewards(mobArg, state)
        deactivateZoneBoss(state)
    end)

    boss:addListener('DESPAWN', 'SANCTUM_ZONE_BOSS_DESPAWN', function(mobArg)
        deactivateZoneBoss(zoneBossStates[mobArg:getID()])
    end)
end

local function prepareChainbreaker(runtime, mobConfig, boss, level)
    resetAppliedState(mobStates[boss:getID()])

    boss:setAnimationSub(mobConfig.chainbreaker.animationSub or 0)
    boss:setMobLevel(level)
    boss:setLocalVar('VariantSystemActive', 1)
    boss:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
    boss:setMobMod(xi.mobMod.NO_DROPS, 0)
    boss:setDropID(0)
    boss:setLocalVar('VariantDeathHandled', 0)

    local state = newEncounterState(
        mobConfig,
        runtime,
        mobConfig.chainbreaker.displayName)

    state.isChainbreaker = true

    mobStates[boss:getID()] = state

    applyBuffs(boss, state, 3, 75)
    applyWeakness(boss, state)
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

local function queueChainbreaker(runtime, mobConfig, sourceMob, claimOwner, state)
    if not isChainbreakerAvailable(runtime, mobConfig) then
        return
    end

    runtime.chainbreakerPending[mobConfig.key] = true
    state.pendingChainbreaker =
    {
        claimOwnerId = claimOwner ~= nil and claimOwner:getID() or nil,
        level        = sourceMob:getMainLvl(),
        x            = sourceMob:getXPos(),
        y            = sourceMob:getYPos(),
        z            = sourceMob:getZPos(),
        rotation     = sourceMob:getRotPos(),
    }
end

local function scheduleChainbreaker(runtime, mobConfig, timerSource, pending)
    timerSource:timer(chainbreakerDelay, function()
        runtime.chainbreakerPending[mobConfig.key] = false

        local boss = runtime.chainbreakers[mobConfig.key]

        if boss == nil or not isChainbreakerAvailable(runtime, mobConfig) then
            return
        end

        boss:setSpawn(pending.x, pending.y, pending.z, pending.rotation)
        boss:spawn()
        prepareChainbreaker(runtime, mobConfig, boss, pending.level)

        local claimOwner = pending.claimOwnerId ~= nil and
            GetPlayerByID(pending.claimOwnerId) or nil

        applyClaimPriority(boss, claimOwner)
    end)
end

local function activateVariant(state)
    local mob       = state.mob
    local buffCount = math.randomInt(1, 2)

    state.isVariant = true
    mob:setLocalVar('VariantSystemActive', 1)
    mob:renameEntity(state.variantPacketName, true)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)

    applyBuffs(
        mob,
        state,
        buffCount,
        0)
    applyWeakness(mob, state)
end

local function resetVariant(state)
    local mob = state.mob

    resetAppliedState(state)

    state.isVariant           = false
    state.automaticHpBonus    = 0
    state.buffIds             = {}
    state.lastSkillchainLink  = 0
    state.poisonAttacks       = false
    state.pendingChainbreaker = nil
    state.skillchainWeakness  = false
    state.weaknessId          = nil
    state.weaknessName        = nil
    state.weaknessRevealed    = false

    mob:setLocalVar('VariantSystemActive', 0)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, state.originalCheckAsNm)

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

    local originalPacketName = mob:getPacketName()
    local variantPacketNames = mobConfig.variantPacketNames or {}
    local variantPacketName  =
        variantPacketNames[originalPacketName] or
        variantPacketNames[mob:getName()] or
        mobConfig.variantPacketName or
        string.format('V %s', originalPacketName)
    local variantDisplayName = mobConfig.variantDisplayName or string.format('Variant %s', originalPacketName)
    local state              = newEncounterState(mobConfig, runtime, variantDisplayName)

    state.mob                = mob
    state.isVariant          = false
    state.isChainbreaker     = false
    state.originalPacketName = originalPacketName
    state.originalCheckAsNm  = mob:getMobMod(xi.mobMod.CHECK_AS_NM)
    state.variantPacketName  = variantPacketName
    state.variantDisplayName = variantDisplayName

    mobStates[mob:getID()] = state

    mob:addListener('SPAWN', 'SANCTUM_VARIANT_SPAWN', function()
        resetVariant(state)

        if
            isConfiguredVariantLevel(mobConfig, mob) and
            math.randomInt(1, 100) <= variantChance
        then
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
            'Variant',
            true)

        if
            isChainbreakerAvailable(runtime, mobConfig) and
            math.randomInt(1, 100) <= chainbreakerChance
        then
            queueChainbreaker(runtime, mobConfig, mobArg, claimOwner, state)
        end
    end)

    mob:addListener('DESPAWN', 'SANCTUM_VARIANT_DESPAWN', function(mobArg)
        local pending = state.pendingChainbreaker

        if pending == nil then
            return
        end

        state.pendingChainbreaker = nil
        scheduleChainbreaker(runtime, mobConfig, mobArg, pending)
    end)

    addEncounterCombatListeners(mob, 'SANCTUM_VARIANT', function()
        return state
    end)

    return true
end

local function insertChainbreaker(runtime, mobConfig)
    local chainConfig = mobConfig.chainbreaker

    if chainConfig == nil then
        return
    end

    local boss = runtime.zone:insertDynamicEntity(
    {
        objtype               = xi.objType.MOB,
        name                  = chainConfig.name,
        packetName            = chainConfig.packetName,
        groupId               = chainConfig.groupId,
        groupZoneId           = chainConfig.groupZoneId,
        look                  = chainConfig.look,
        modelHitboxSize       = chainConfig.baseHitbox,
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

    scaleHitbox(boss, chainConfig.scale or chainbreakerScale)

    runtime.chainbreakers[mobConfig.key] = boss

    addEncounterCombatListeners(boss, 'SANCTUM_CHAINBREAKER', function(mobArg)
        return mobStates[mobArg:getID()]
    end)

    boss:addListener('DEATH', 'SANCTUM_CHAINBREAKER_DEATH', function(mobArg, killer)
        if mobArg:getLocalVar('VariantDeathHandled') ~= 0 then
            return
        end

        mobArg:setLocalVar('VariantDeathHandled', 1)

        local state     = mobStates[mobArg:getID()]
        local buffCount = state ~= nil and #state.buffIds or 0

        mobArg:setLocalVar('VariantClaimPriority', 0)
        local expAwarded = awardBonusExp(
            mobArg,
            killer,
            mobArg:getMainLvl() * buffCount * 10,
            'Chainbreaker')

        if expAwarded then
            local lockoutDuration = math.randomInt(
                chainbreakerLockoutMin,
                chainbreakerLockoutMax)
            local lockoutEnd = GetSystemTime() + lockoutDuration

            SetServerVariable(
                getChainbreakerCooldownVar(runtime, mobConfig),
                lockoutEnd,
                lockoutEnd)
        end

        trySpawnZoneBoss(runtime, mobArg)
    end)

    addCosmeticDrops(boss, chainConfig)
end

local function initializeZone(zone, zoneConfig)
    local runtime =
    {
        zone                = zone,
        config              = zoneConfig,
        chainbreakers       = {},
        chainbreakerPending = {},
        zoneBoss            = nil,
        zoneBossPending     = false,
    }

    zoneStates[zoneConfig.zoneId] = runtime

    local registeredMobs = 0

    insertZoneBoss(runtime)

    for _, mobConfig in ipairs(zoneConfig.mobs) do
        if mobConfig.chainbreaker ~= nil then
            insertChainbreaker(runtime, mobConfig)
        end
    end

    for _, mob in pairs(zone:getMobs()) do
        for _, mobConfig in ipairs(zoneConfig.mobs) do
            if matchesConfiguredMob(mobConfig, mob:getName()) then
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

local variantApi = {}

function variantApi.getRuntime(zoneId)
    return zoneStates[zoneId]
end

function variantApi.isZoneConfigured(zoneId)
    for _, zoneConfig in ipairs(zoneConfigs) do
        if zoneConfig.zoneId == zoneId then
            return true
        end
    end

    return false
end

function variantApi.getConfigs(runtime)
    return runtime ~= nil and runtime.config.mobs or {}
end

function variantApi.findMobConfig(runtime, identifier)
    if runtime == nil or identifier == nil then
        return nil
    end

    local wanted = tostring(identifier):lower():gsub('[%s%-]+', '_')

    for _, mobConfig in ipairs(runtime.config.mobs) do
        local chainConfig = mobConfig.chainbreaker
        local names       = {}
        local function addName(name)
            if name ~= nil then
                names[#names + 1] = name
            end
        end

        addName(mobConfig.key)
        addName(mobConfig.packetName)
        addName(mobConfig.variantPacketName)
        addName(mobConfig.variantDisplayName)

        if chainConfig ~= nil then
            addName(chainConfig.name)
            addName(chainConfig.packetName)
            addName(chainConfig.displayName)
        end

        for _, mobName in ipairs(getConfiguredMobNames(mobConfig)) do
            local packetName = mobName:gsub('_', ' ')

            addName(mobName)
            addName(string.format('V %s', packetName))
            addName(string.format('Variant %s', packetName))
        end

        for _, name in ipairs(names) do
            if tostring(name):lower():gsub('[%s%-]+', '_') == wanted then
                return mobConfig
            end
        end
    end

    return nil
end

function variantApi.getMobConfig(mob)
    if mob == nil then
        return nil
    end

    local state = mobStates[mob:getID()]

    return state ~= nil and state.config or nil
end

function variantApi.forceVariant(mob)
    if mob == nil or not mob:isMob() then
        return false, 'Target a configured monster.'
    end

    local state = mobStates[mob:getID()]

    if state == nil or state.mob ~= mob then
        return false, 'That monster is not a configured Variant source.'
    end

    if not mob:isSpawned() or not mob:isAlive() then
        return false, 'That monster is not alive.'
    end

    if state.isVariant then
        return false, 'That monster is already a Variant.'
    end

    resetVariant(state)
    activateVariant(state)

    return true, state.variantDisplayName
end

function variantApi.forceChainbreaker(runtime, mobConfig, player, sourceMob, level)
    if runtime == nil or mobConfig == nil or player == nil then
        return false, 'A configured family in the current zone is required.'
    end

    if mobConfig.chainbreaker == nil then
        return false, 'That Variant family does not have a Chainbreaker configured yet.'
    end

    local boss = runtime.chainbreakers[mobConfig.key]

    if boss == nil then
        return false, 'The Chainbreaker entity was not created.'
    end

    if boss:isSpawned() then
        return false, 'That Chainbreaker is already active.'
    end

    local positionSource = player
    if
        sourceMob ~= nil and
        sourceMob:isMob() and
        sourceMob:getZoneID() == player:getZoneID()
    then
        positionSource = sourceMob
    end

    local spawnLevel = tonumber(level)
    if spawnLevel == nil and sourceMob ~= nil and sourceMob:isMob() then
        spawnLevel = sourceMob:getMainLvl()
    end

    spawnLevel = normalizeLevel(spawnLevel, player:getMainLvl())
    runtime.chainbreakerPending[mobConfig.key] = false

    boss:setSpawn(
        positionSource:getXPos(),
        positionSource:getYPos(),
        positionSource:getZPos(),
        positionSource:getRotPos())
    boss:spawn()
    prepareChainbreaker(runtime, mobConfig, boss, spawnLevel)
    applyClaimPriority(boss, player)

    return true, mobConfig.chainbreaker.displayName
end

function variantApi.getStatus(runtime, mobConfig)
    if runtime == nil or mobConfig == nil then
        return nil
    end

    if mobConfig.chainbreaker == nil then
        return
        {
            key               = mobConfig.key,
            displayName       = mobConfig.variantDisplayName or mobConfig.packetName or mobConfig.key,
            hasChainbreaker   = false,
            active            = false,
            pending           = false,
            cooldownRemaining = 0,
        }
    end

    local boss        = runtime.chainbreakers[mobConfig.key]
    local cooldownEnd = GetServerVariable(getChainbreakerCooldownVar(runtime, mobConfig))

    return
    {
        key               = mobConfig.key,
        displayName       = mobConfig.chainbreaker.displayName,
        hasChainbreaker   = true,
        active            = boss ~= nil and boss:isSpawned(),
        pending           = runtime.chainbreakerPending[mobConfig.key] == true,
        cooldownRemaining = math.max(0, cooldownEnd - GetSystemTime()),
    }
end

function variantApi.clearCooldown(runtime, mobConfig)
    if runtime == nil or mobConfig == nil or mobConfig.chainbreaker == nil then
        return false
    end

    SetServerVariable(getChainbreakerCooldownVar(runtime, mobConfig), 0)
    return true
end

function variantApi.forceZoneBoss(runtime, player, level)
    if
        runtime == nil or
        runtime.config.zoneBoss == nil or
        runtime.zoneBoss == nil
    then
        return false, 'This zone has no configured Zone Boss.'
    end

    if runtime.zoneBossPending or runtime.zoneBoss:isSpawned() then
        return false, 'The Zone Boss is already active or pending.'
    end

    local spawnLevel = normalizeLevel(level, runtime.config.zoneBoss.level)

    if not spawnZoneBoss(runtime, player, spawnLevel) then
        return false, 'The Zone Boss could not be spawned.'
    end

    return true, runtime.config.zoneBoss.displayName
end

function variantApi.getZoneBossStatus(runtime)
    if runtime == nil or runtime.config.zoneBoss == nil then
        return nil
    end

    local state = runtime.zoneBoss ~= nil and
        zoneBossStates[runtime.zoneBoss:getID()] or nil
    local participantCount, totalPoints = summarizeParticipants(state)

    return
    {
        active           = runtime.zoneBoss ~= nil and runtime.zoneBoss:isSpawned(),
        chance           = zoneBossChance,
        displayName      = runtime.config.zoneBoss.displayName,
        killCount        = getZoneBossKillCount(runtime),
        participantCount = participantCount,
        pending          = runtime.zoneBossPending == true,
        threshold        = zoneBossThreshold,
        totalPoints      = totalPoints,
        xpCap            = runtime.config.zoneBoss.xpCap,
        xpPerPoint       = runtime.config.zoneBoss.xpPerPoint,
    }
end

function variantApi.setZoneBossKillCount(runtime, count)
    if runtime == nil or runtime.config.zoneBoss == nil then
        return false
    end

    setZoneBossKillCount(runtime, count)
    return true
end

function variantApi.recordZoneBossAction(boss, actor, actionType, amount)
    return recordZoneBossParticipation(
        boss,
        actor,
        tostring(actionType or 'action'),
        amount or 1)
end

function variantApi.describeMob(mob)
    if mob == nil then
        return nil
    end

    local zoneBossState = zoneBossStates[mob:getID()]

    if zoneBossState ~= nil then
        local participantCount, totalPoints = summarizeParticipants(zoneBossState)

        return
        {
            active           = zoneBossState.active,
            automaticHpBonus = zoneBossState.automaticHpBonus or 0,
            buffNames        = getBuffNames(zoneBossState),
            displayName      = zoneBossState.config.displayName,
            kind             = 'Zone Boss',
            participantCount = participantCount,
            totalPoints      = totalPoints,
            weaknessName     = zoneBossState.weaknessName,
            weaknessRevealed = zoneBossState.weaknessRevealed == true,
        }
    end

    local state = mobStates[mob:getID()]
    if state == nil then
        return nil
    end

    return
    {
        displayName      = state.displayName or mob:getPacketName(),
        active           = state.isChainbreaker or state.isVariant,
        kind             = state.isChainbreaker and 'Chainbreaker' or
            (state.isVariant and 'Variant' or 'Normal'),
        buffNames        = getBuffNames(state),
        automaticHpBonus = state.automaticHpBonus or 0,
        weaknessName     = state.weaknessName,
        weaknessRevealed = state.weaknessRevealed == true,
    }
end

_G.SanctumVariantSystem = variantApi

local function makeZoneInitializer(zoneConfig)
    return function(zone)
        super(zone)
        initializeZone(zone, zoneConfig)
    end
end

local function addCriticalRevealOverride(zoneConfig, mobName)
    local entityPath = string.format(
        'xi.zones.%s.mobs.%s',
        zoneConfig.zoneName,
        mobName)

    xi.module.ensureTable(entityPath)

    local mobEntity = xi.zones[zoneConfig.zoneName].mobs[mobName]

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
        for _, mobName in ipairs(getConfiguredMobNames(mobConfig)) do
            addCriticalRevealOverride(zoneConfig, mobName)
        end
    end
end

return m
