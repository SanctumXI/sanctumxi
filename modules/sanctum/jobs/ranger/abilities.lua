-----------------------------------
-- Sanctum Ranger ability fixes
-----------------------------------
require('modules/module_utils')
require('scripts/globals/combat/ranged_utilities')
require('scripts/globals/job_utils/ranger')
require('scripts/globals/weaponskills')
-----------------------------------

local m = Module:new('sanctum_ranger_abilities')

local function recordAmmoForScavenge(player)
    local ammoId = player:getEquipID(xi.slot.AMMO)
    if ammoId <= 0 then
        return
    end

    local tracked   = player:getLocalVar('ArrowsUsed')
    local trackedId = math.floor(tracked / 10000)
    local used      = trackedId == ammoId and tracked % 10000 or 0

    player:setLocalVar('ArrowsUsed', ammoId * 10000 + math.min(used + 1, 1980))
end

local function interpolateCamouflageChance(distance, lowerBound, upperBound)
    if distance <= lowerBound then
        return 0
    elseif distance >= upperBound then
        return 100
    end

    local progress = (distance - lowerBound) / (upperBound - lowerBound)
    return math.floor(40 + 60 * progress)
end

local function getCamouflageRetentionChance(player, target)
    local distance   = player:checkDistance(target)
    local meleeRange = player:getHitboxSize() + 2 + target:getHitboxSize()

    if player:isBehind(target, 25) then
        return interpolateCamouflageChance(distance, meleeRange + 0.1, meleeRange + 0.6)
    elseif player:isBeside(target, 25) then
        return interpolateCamouflageChance(distance, meleeRange + 3.3, meleeRange + 5)
    end

    return interpolateCamouflageChance(distance, meleeRange + 7.1, meleeRange + 8.1)
end

m:addOverride('xi.combat.ranged.shouldUseAmmo', function(attacker)
    if attacker:isPC() and attacker:hasStatusEffect(xi.effect.UNLIMITED_SHOT) then
        return false
    end

    local shouldUseAmmo = super(attacker)
    if shouldUseAmmo and attacker:isPC() then
        recordAmmoForScavenge(attacker)
    end

    return shouldUseAmmo
end)

m:addOverride('xi.weaponskills.doRangedWeaponskill', function(attacker, target, wsID, params, tp, action, primary)
    local camouflageEffect = attacker:getStatusEffect(xi.effect.CAMOUFLAGE)
    local hadUnlimitedShot  = attacker:hasStatusEffect(xi.effect.UNLIMITED_SHOT)
    local hadBarrage        = attacker:hasStatusEffect(xi.effect.BARRAGE)
    local barrageAcc        = 0
    local barrageRatt       = 0

    if camouflageEffect then
        camouflageEffect:delEffectFlag(xi.effectFlag.DETECTABLE)
    end

    if hadBarrage then
        barrageAcc  = attacker:getMod(xi.mod.BARRAGE_ACC)
        barrageRatt = attacker:getJobPointLevel(xi.jp.BARRAGE_EFFECT) * 3
        attacker:addMod(xi.mod.BARRAGE_ACC, -barrageAcc)
        attacker:addMod(xi.mod.RATT, -barrageRatt)
    end

    local ok, damage, critical, tpHits, extraHits, shadows = pcall(super, attacker, target, wsID, params, tp, action, primary)

    if hadBarrage then
        attacker:delMod(xi.mod.BARRAGE_ACC, -barrageAcc)
        attacker:delMod(xi.mod.RATT, -barrageRatt)
    end

    local currentCamouflage = attacker:getStatusEffect(xi.effect.CAMOUFLAGE)
    if currentCamouflage then
        currentCamouflage:addEffectFlag(xi.effectFlag.DETECTABLE)
    end

    if not ok then
        error(damage, 0)
    end

    if
        camouflageEffect and
        currentCamouflage and
        math.randomInt(0, 99) >= getCamouflageRetentionChance(attacker, target)
    then
        attacker:delStatusEffect(xi.effect.CAMOUFLAGE)
    end

    if
        hadUnlimitedShot and
        attacker:hasStatusEffect(xi.effect.UNLIMITED_SHOT) and
        (tpHits or 0) + (extraHits or 0) > 0
    then
        attacker:delStatusEffect(xi.effect.UNLIMITED_SHOT)
    end

    return damage, critical, tpHits, extraHits, shadows
end)

m:addOverride('xi.job_utils.ranger.useEagleEyeShot', function(player, target, ability, action)
    local jpBonus      = player:getJobPointLevel(xi.jp.EAGLE_EYE_SHOT_EFFECT) * 3
    local previousWsd  = player:getMod(xi.mod.ALL_WSDMG_ALL_HITS)
    local ok, damage   = pcall(super, player, target, ability, action)
    local currentWsd   = player:getMod(xi.mod.ALL_WSDMG_ALL_HITS)

    if jpBonus > 0 and currentWsd >= previousWsd + jpBonus then
        player:delMod(xi.mod.ALL_WSDMG_ALL_HITS, jpBonus)
    end

    if not ok then
        error(damage, 0)
    end

    return damage
end)

m:addOverride('xi.job_utils.ranger.useScavenge', function(player, target, ability, action)
    if xi.job_utils.ranger.tryScavengeQuestItem(player) then
        return
    end

    local bonuses        = (player:getMod(xi.mod.SCAVENGE_EFFECT) + player:getMerit(xi.merit.SCAVENGE_EFFECT)) / 100
    local tracked        = player:getLocalVar('ArrowsUsed')
    local arrowsToReturn = math.floor(tracked % 10000 * (player:getMainLvl() / 200 + bonuses))
    local playerId       = target:getID()

    if arrowsToReturn == 0 then
        action:messageID(playerId, xi.msg.basic.SCAVENGE_FIND_NOTHING)
        return
    end

    arrowsToReturn = math.min(arrowsToReturn, 99)

    local ammoId = math.floor(tracked / 10000)
    if not player:addItem(ammoId, arrowsToReturn) then
        action:messageID(playerId, xi.msg.basic.SCAVENGE_FIND_NOTHING)
        return
    end

    if arrowsToReturn == 1 then
        action:messageID(playerId, xi.msg.basic.SCAVENGE_FIND_ITEM)
    else
        action:messageID(playerId, xi.msg.basic.SCAVENGE_FIND_ITEMS)
        action:additionalEffect(playerId, 1)
        action:addEffectParam(playerId, arrowsToReturn)
    end

    player:setLocalVar('ArrowsUsed', 0)
    return ammoId
end)

m:addOverride('xi.job_utils.ranger.useShadowbind', function(player, target, ability, action)
    if player:getWeaponSkillType(xi.slot.RANGED) == xi.skill.MARKSMANSHIP then
        action:setAnimation(target:getID(), action:getAnimation(target:getID()) + 1)
    end

    local duration = 30 + player:getMod(xi.mod.SHADOW_BIND_EXT) + player:getJobPointLevel(xi.jp.SHADOWBIND_DURATION)
    local applied  = false

    if
        math.randomInt(0, 99) >= target:getMod(xi.mod.BIND_MEVA) and
        not target:hasStatusEffect(xi.effect.BIND)
    then
        applied = target:addStatusEffect(xi.effect.BIND, { duration = duration, origin = player })
    end

    ability:setMsg(applied and xi.msg.basic.IS_EFFECT or xi.msg.basic.JA_MISS)

    local hadUnlimitedShot = player:hasStatusEffect(xi.effect.UNLIMITED_SHOT)

    if xi.combat.ranged.shouldUseAmmo(player) then
        player:removeAmmo(1)
    elseif hadUnlimitedShot and player:hasStatusEffect(xi.effect.UNLIMITED_SHOT) then
        -- Shadowbind keeps its existing Unlimited Shot behavior; only ranged WS retain it on a miss.
        player:delStatusEffect(xi.effect.UNLIMITED_SHOT)
    end

    return xi.effect.BIND
end)

return m
