-----------------------------------
-- Sanctum level-75 Blood Pacts
-----------------------------------
require('modules/module_utils')
require('scripts/globals/summon')
require('scripts/globals/job_utils/summoner')
require('scripts/globals/combat/damage_multipliers')
require('scripts/globals/mobskills')
-----------------------------------

local m = Module:new('sanctum_summoner_blood_pacts')

local function isPlayerAvatar(pet)
    local master = pet:getMaster()
    return pet:isAvatar() and master ~= nil and master:isPC()
end

-- Classic Blood Pacts use 0/1500/3000 TP, not weaponskill 1000/2000/3000 anchors.
local function pactTPFactor(tp, values)
    tp = utils.clamp(tp, 0, 3000)
    if tp < 1500 then
        return values[1] + (values[2] - values[1]) * tp / 1500
    end

    return values[2] + (values[3] - values[2]) * (tp - 1500) / 1500
end

m:addOverride('xi.summon.avatarPhysicalMove', function(pet, target, skill, hits, acc, first, extra, tpEffect, ftp0, ftp1500, ftp3000)
    if
        not isPlayerAvatar(pet) or
        tpEffect ~= xi.mobskills.physicalTpBonus.DMG_VARIES
    then
        return super(pet, target, skill, hits, acc, first, extra, tpEffect, ftp0, ftp1500, ftp3000)
    end

    local info = super(pet, target, skill, hits, acc, first, extra, xi.mobskills.physicalTpBonus.NO_EFFECT, ftp0, ftp1500, ftp3000)
    info.damage = info.damage * pactTPFactor(skill:getTP() + pet:getMod(xi.mod.TP_BONUS), { ftp0, ftp1500, ftp3000 })
    return info
end)

m:addOverride('xi.summon.avatarFinalAdjustments', function(info, mob, skill, target, skilltype, damagetype, shadowbehav)
    if not isPlayerAvatar(mob) or skilltype ~= xi.attackType.PHYSICAL then
        return super(info, mob, skill, target, skilltype, damagetype, shadowbehav)
    end

    info.shadowsUsed = 0
    local missMessage = xi.msg.basic.SKILL_MISS
    if mob:getCurrentAction() == xi.action.category.PET_MOBABILITY_FINISH then
        missMessage = xi.msg.basic.JA_MISS_2
    end

    local dmg = info.damage

    if dmg == 0 then
        skill:setMsg(missMessage)

        return 0
    end

    if mob:getCurrentAction() == xi.action.category.PET_MOBABILITY_FINISH then
        if skill:getMsg() ~= xi.msg.basic.JA_MAGIC_BURST then
            skill:setMsg(xi.msg.basic.USES_JA_TAKE_DAMAGE)
        end
    else
        skill:setMsg(xi.msg.basic.DAMAGE)
    end

    local preShadowDmg = dmg
    local shadowsUsed  = 0
    local shadowsToRemove = shadowbehav or info.hitslanded or 1
    if shadowsToRemove ~= xi.mobskills.shadowBehavior.IGNORE_SHADOWS then
        shadowsToRemove = math.min(shadowsToRemove, info.hitslanded or shadowsToRemove)
        dmg, shadowsUsed = utils.takeShadows(target, dmg, shadowsToRemove)
    end

    info.shadowsUsed = shadowsUsed
    info.hitslanded = math.max(0, (info.hitslanded or 1) - shadowsUsed)

    if preShadowDmg > 0 and dmg == 0 then
        skill:setMsg(xi.msg.basic.SHADOW_ABSORB)
        return 0
    end

    local teye = target:getStatusEffect(xi.effect.THIRD_EYE)

    if teye ~= nil then
        if shadowbehav == xi.mobskills.shadowBehavior.WIPE_SHADOWS then
            target:delStatusEffect(xi.effect.THIRD_EYE)
        elseif shadowbehav ~= xi.mobskills.shadowBehavior.IGNORE_SHADOWS then
            local prevAnt = teye:getPower()
            if prevAnt == 0 then
                teye:setPower(1)
                skill:setMsg(xi.msg.basic.ANTICIPATE)
                return 0
            end

            if math.randomFloat(0, 1) * 10 < 8 - prevAnt then
                teye:setPower(prevAnt + 1)
                skill:setMsg(xi.msg.basic.ANTICIPATE)
                return 0
            end

            target:delStatusEffect(xi.effect.THIRD_EYE)
        end
    end

    if
        target:hasStatusEffect(xi.effect.PHYSICAL_SHIELD) or
        target:hasStatusEffect(xi.effect.INVINCIBLE)
    then
        return 0
    end

    if
        target:hasStatusEffect(xi.effect.PERFECT_DODGE) or
        target:hasStatusEffect(xi.effect.ALL_MISS)
    then
        skill:setMsg(missMessage)

        return 0
    end

    dmg = math.floor(dmg * xi.combat.damage.physicalElementSDT(target, damagetype))
    dmg = math.floor(dmg * xi.combat.damage.calculateDamageAdjustment(target, true, false, false, false))

    local bloodPactDamageBonus = mob:getMod(xi.mod.BP_DAMAGE) + xi.wsEffect.getSpiritTakerSummonerPetDamageBonus(mob)
    dmg = math.floor(dmg + dmg * bloodPactDamageBonus / 100)

    if dmg < 0 then
        return dmg
    end

    dmg = target:handleSevereDamage(dmg, true)
    dmg = utils.handlePhalanx(target, dmg)
    dmg = utils.handleStoneskin(target, dmg)

    dmg = target:checkDamageCap(dmg)

    return dmg
end)

m:addOverride('xi.mobskills.mobMagicalMove', function(mob, target, skill, action, skillParams)
    if not isPlayerAvatar(mob) then
        return super(mob, target, skill, action, skillParams)
    end

    local returnInfo = {}

    local damage               = utils.defaultIfNil(skillParams.baseDamage, mob:getMainLvl() + 2)
    local additiveDamage       = utils.defaultIfNil(skillParams.additiveDamage, { 0, 0, 0 })
    local fTPScale             = utils.defaultIfNil(skillParams.fTP, { 1.00, 1.00, 1.00 })
    local fTPBonus             = utils.defaultIfNil(skillParams.fTPBonus, 0)
    local actionElement        = utils.defaultIfNil(skillParams.element, 0)
    local attackType           = utils.defaultIfNil(skillParams.attackType, xi.attackType.MAGICAL)
    local damageType           = utils.defaultIfNil(skillParams.damageType, xi.damageType.ELEMENTAL)
    local shadowsToRemove      = utils.defaultIfNil(skillParams.shadowBehavior, xi.mobskills.shadowBehavior.NUMSHADOWS_1)
    local mATTBonusfTP         = utils.defaultIfNil(skillParams.mATTBonus, { 0, 0, 0 })
    local mACCBonusfTP         = utils.defaultIfNil(skillParams.mACCBonus, { 0, 0, 0 })
    local skipDamageAdjustment = utils.defaultIfNil(skillParams.skipDamageAdjustment and true, false)
    local skipMagicBonusDiff   = utils.defaultIfNil(skillParams.skipMagicBonusDiff and true, false)
    local skipStoneskin        = utils.defaultIfNil(skillParams.skipStoneSkin and true, false)
    local resistTierOverride   = utils.defaultIfNil(skillParams.resistTierOverride, 0)
    local dStatMultiplier      = utils.defaultIfNil(skillParams.dStatMultiplier, 0)
    local dStatAttackerMod     = utils.defaultIfNil(skillParams.dStatAttackerMod, xi.mod.INT)
    local dStatDefenderMod     = utils.defaultIfNil(skillParams.dStatDefenderMod, xi.mod.INT)
    local canMagicBurst        = utils.defaultIfNil(skillParams.canMagicBurst and true, false)
    local primaryMessage       = utils.defaultIfNil(skillParams.primaryMessage, xi.msg.basic.DAMAGE)

    local strWSC = skillParams.str_wSC
    local dexWSC = skillParams.dex_wSC
    local vitWSC = skillParams.vit_wSC
    local agiWSC = skillParams.agi_wSC
    local intWSC = skillParams.int_wSC
    local mndWSC = skillParams.mnd_wSC
    local chrWSC = skillParams.chr_wSC

    returnInfo.damage              = 0
    returnInfo.hitsLanded          = 0
    returnInfo.attackType          = attackType
    returnInfo.damageType          = damageType

    skill:setMsg(primaryMessage)

    if mob:hasStatusEffect(xi.effect.HYSTERIA) then
        skill:setMsg(xi.msg.basic.NONE)

        return returnInfo
    end

    local wscMods = xi.combat.physical.calculateWSC(mob, strWSC, dexWSC, vitWSC, agiWSC, intWSC, mndWSC, chrWSC)

    local bonusTP             = mob:getMod(xi.mod.TP_BONUS) + fTPBonus
    local tpValue             = math.min(skill:getTP() + bonusTP, 3000)
    local baseDamagefTPMult   = pactTPFactor(tpValue, fTPScale)
    local additiveBonusDamage = math.floor(pactTPFactor(tpValue, additiveDamage))

    local dStat = 0

    if skillParams.dStatMultiplier then
        dStat = mob:getStat(dStatAttackerMod) - target:getStat(dStatDefenderMod)

        if not mob:isAvatar() then
            if dStat < 0 then
                dStatMultiplier = dStatMultiplier - 0.5

                if dStatMultiplier < 1 then
                    dStat = -1
                end
            end
        end

        dStat = math.floor(dStat * dStatMultiplier)
        dStat = utils.clamp(dStat, -65, 999)
    end

    damage = math.floor((damage + wscMods + mob:getMod(xi.mod.MAGIC_DAMAGE)) * baseDamagefTPMult + dStat + additiveBonusDamage)
    damage = math.max(0, damage)

    local hitsLanded      = 1
    local hitAbsorbed     = false
    local shadowsConsumed = 0

    hitAbsorbed, shadowsConsumed = xi.mobskills.handleShadowConsumption(target, skill, skillParams, shadowsToRemove)

    if hitAbsorbed then
        skill:setMsg(xi.msg.basic.SHADOW_ABSORB)

        returnInfo.damage     = shadowsConsumed
        returnInfo.hitsLanded = 0

        return returnInfo
    end

    local absorbDamage  = 1
    local nullifyDamage = 1

    if attackType == xi.attackType.BREATH then
        nullifyDamage  = xi.spells.damage.calculateNullification(target, actionElement, false, true)
    else
        nullifyDamage  = xi.spells.damage.calculateNullification(target, actionElement, true, false)
    end

    if nullifyDamage == 0 then
        returnInfo.damage     = 0
        returnInfo.hitsLanded = hitsLanded

        return returnInfo
    end

    if attackType == xi.attackType.BREATH then
        absorbDamage  = xi.spells.damage.calculateAbsorption(target, actionElement, false)
    else
        absorbDamage  = xi.spells.damage.calculateAbsorption(target, actionElement, true)
    end

    local mAccuracyBonus = 0
    local mAttackBonus   = 0

    mAccuracyBonus = pactTPFactor(tpValue, mACCBonusfTP)

    mAttackBonus = pactTPFactor(tpValue, mATTBonusfTP)

    local petAccuracyBonus = xi.mobskills.calculatePetMagicAccuracyBonus(mob, target, actionElement)

    mAccuracyBonus = mAccuracyBonus + petAccuracyBonus

    local sdt                   = xi.combat.damage.magicalElementSDT(target, actionElement)
    local resistTier            = 1
    local dayAndWeather         = xi.spells.damage.calculateDayAndWeather(mob, actionElement, false)
    local steamJacketMultiplier = xi.combat.damage.steamJacketMultiplier(target, actionElement)
    local magicBonusDiff        = 1
    local magicDamageAdjustment = 1
    local bloodPactMultiplier   = 1
    local magicBurst            = 1
    local magicBurstBonus       = 1

    if absorbDamage > 0 then
        resistTier = xi.combat.magicHitRate.calculateResistRate(mob, target, 0, 0, 0, actionElement, dStatAttackerMod, 0, mAccuracyBonus)

        if mob:isAvatar() then
            bloodPactMultiplier = 1 + (mob:getMod(xi.mod.BP_DAMAGE) + xi.wsEffect.getSpiritTakerSummonerPetDamageBonus(mob)) / 100
        end

        if
            not skipDamageAdjustment and
            attackType == xi.attackType.BREATH
        then
            magicDamageAdjustment = xi.combat.damage.calculateDamageAdjustment(target, false, false, false, true)
        elseif not skipDamageAdjustment then
            magicDamageAdjustment = xi.combat.damage.calculateDamageAdjustment(target, false, true, false, false)
        end

        if canMagicBurst then
            local skillchainCount = xi.combat.magicBurst.getMagicBurstTier(target, actionElement)

            if skillchainCount > 0 then
                magicBurst      = xi.spells.damage.calculateIfMagicBurst(target, actionElement, skillchainCount)
                magicBurstBonus = xi.spells.damage.calculateIfMagicBurstBonus(mob, target, 0, 0, actionElement)

                skill:setMsg(xi.msg.basic.JA_MAGIC_BURST)
            end
        end
    end

    if not skipMagicBonusDiff then
        magicBonusDiff = xi.spells.damage.calculateMagicBonusDiff(mob, target, 0, 0, actionElement, mAttackBonus)
    end

    if skillParams.resistTierOverride then
        resistTier = resistTierOverride
    end

    damage = math.floor(damage * sdt)
    damage = math.floor(damage * resistTier)
    damage = math.floor(damage * dayAndWeather)
    damage = math.floor(damage * steamJacketMultiplier)
    damage = math.floor(damage * magicBonusDiff)
    damage = math.floor(damage * magicDamageAdjustment)
    damage = math.floor(damage * bloodPactMultiplier)
    damage = math.floor(damage * absorbDamage)
    damage = math.floor(damage * magicBurst)
    damage = math.floor(damage * magicBurstBonus)

    if absorbDamage < 0 then
        returnInfo.damage     = damage
        returnInfo.hitsLanded = hitsLanded

        return returnInfo
    end

    damage = math.floor(target:handleSevereDamage(damage, false))
    damage = math.floor(target:checkDamageCap(damage))
    damage = math.floor(utils.handleAutomatonAutoAnalyzer(target, skill, damage))
    damage = utils.handlePhalanx(target, damage)
    damage = utils.handleOneForAll(target, damage)

    if not skipStoneskin then
        damage = utils.handleStoneskin(target, damage, attackType)
    end

    target:handleAfflatusMiseryDamage(damage)

    -- Magical pacts consume the saved TP; only the damaged target receives TP.
    if damage > 0 then
        target:addTP(xi.combat.tp.calculateTPGainOnPhysicalDamage(mob, target, damage, mob:getBaseDelay()))
    end

    returnInfo.damage     = damage
    returnInfo.hitsLanded = hitsLanded

    return returnInfo
end)

m:addOverride('xi.summon.avatarPhysicalHit', function(skill, damage)
    local message = skill:getMsg()
    return damage > 0 and (message == xi.msg.basic.DAMAGE or message == xi.msg.basic.USES_JA_TAKE_DAMAGE)
end)

local addedEffects =
{
    poison_nails   = { effect = xi.effect.POISON, power = 1, duration = 60, tick = 3, preserve = true },
    tail_whip      = { effect = xi.effect.WEIGHT, power = 50, duration = 120, resist = true, preserve = true },
    moonlit_charge = { effect = xi.effect.BLINDNESS, power = 20, duration = 30 },
    crescent_fang  = { effect = xi.effect.PARALYSIS, power = 22.5, duration = 90 },
    shock_strike   = { effect = xi.effect.STUN, power = 1, duration = 2 },
    chaotic_strike = { effect = xi.effect.STUN, power = 1, duration = 2 },
}

local function applyAddedEffect(pet, target, data)
    if data.preserve and target:hasStatusEffect(data.effect) then
        return
    end

    local duration = data.duration
    if data.resist then
        local resist = xi.combat.magicHitRate.calculateResistRate(pet, target, 0, 0, 0, xi.element.NONE, xi.mod.INT, data.effect, 0)
        if resist < 0.25 then
            return
        end

        duration = math.floor(duration * resist)
    end

    target:addStatusEffect(data.effect, { power = data.power, duration = duration, origin = pet, tick = data.tick or 0 })
end

local physicalPacts =
{
    axe_kick         = { hits = 1, acc = 1, first = 3.5, extra = 0, damageType = xi.damageType.BLUNT },
    barracuda_dive   = { hits = 1, acc = 1, first = 3.5, extra = 0, damageType = xi.damageType.SLASHING },
    camisado         = { hits = 1, acc = 1, first = 3.5, extra = 0, damageType = xi.damageType.BLUNT },
    chaotic_strike   = { hits = 3, acc = 1, first = 9, extra = 2, damageType = xi.damageType.BLUNT, effect = 'chaotic_strike' },
    claw             = { hits = 1, acc = 1, first = 3.5, extra = 0, damageType = xi.damageType.PIERCING },
    crescent_fang    = { hits = 1, acc = 1, first = 6, extra = 0, damageType = xi.damageType.PIERCING, effect = 'crescent_fang' },
    double_punch     = { hits = 2, acc = 1, first = 6, extra = 2, damageType = xi.damageType.BLUNT },
    double_slap      = { hits = 2, acc = 1, first = 6, extra = 2, damageType = xi.damageType.HAND_TO_HAND },
    eclipse_bite     = { hits = 3, acc = 1, first = 8, extra = 2, damageType = xi.damageType.SLASHING },
    megalith_throw   = { hits = 1, acc = 1, first = 5.5, extra = 0, damageType = xi.damageType.SLASHING },
    moonlit_charge   = { hits = 1, acc = 1, first = 4, extra = 0, damageType = xi.damageType.BLUNT, effect = 'moonlit_charge' },
    mountain_buster  = { hits = 1, acc = 1, first = 12, extra = 0, damageType = xi.damageType.SLASHING },
    poison_nails     = { hits = 1, acc = 1, first = 2.5, extra = 0, damageType = xi.damageType.PIERCING, effect = 'poison_nails' },
    predator_claws   = { hits = 3, acc = 1, first = 10, extra = 2, damageType = xi.damageType.SLASHING },
    punch            = { hits = 1, acc = 1, first = 3.5, extra = 0, damageType = xi.damageType.BLUNT },
    regal_scratch    = { hits = 3, acc = -5, first = 3, extra = 1, damageType = xi.damageType.SLASHING },
    rock_buster      = { hits = 1, acc = 1, first = 4, extra = 0, damageType = xi.damageType.SLASHING },
    rock_throw       = { hits = 1, acc = 1, first = 3.5, extra = 0, damageType = xi.damageType.SLASHING },
    roundhouse       = { hits = 1, acc = 1, first = 5.0, extra = 0, damageType = xi.damageType.BLUNT, tpReturn = true, tpEffect = xi.mobskills.physicalTpBonus.CRIT_VARIES },
    rush             = { hits = 5, acc = 1, first = 5, extra = 2, damageType = xi.damageType.BLUNT },
    shock_strike     = { hits = 1, acc = 1, first = 3.5, extra = 0, damageType = xi.damageType.BLUNT, effect = 'shock_strike' },
    spinning_dive    = { hits = 1, acc = 1, first = 12, extra = 0, damageType = xi.damageType.BLUNT },
    tail_whip        = { hits = 1, acc = 1, first = 5, extra = 0, damageType = xi.damageType.PIERCING, effect = 'tail_whip' },
    welt             = { hits = 1, acc = 1, first = 3.0, extra = 0, damageType = xi.damageType.SLASHING, tpReturn = true, tpEffect = xi.mobskills.physicalTpBonus.CRIT_VARIES },
}

for name, params in pairs(physicalPacts) do
    m:addOverride('xi.actions.abilities.pets.' .. name .. '.onPetAbility', function(target, pet, skill, master, action)
        xi.job_utils.summoner.onUseBloodPact(target, skill, master, action)

        local tpEffect = params.tpEffect or xi.mobskills.physicalTpBonus.NO_EFFECT
        local info = xi.summon.avatarPhysicalMove(pet, target, skill, params.hits, params.acc, params.first, params.extra, tpEffect, 1, 2, 3)
        local damage = xi.summon.avatarFinalAdjustments(info, pet, skill, target, xi.attackType.PHYSICAL, params.damageType, params.hits)

        if params.tpReturn and damage ~= 0 and info.hitslanded > 0 then
            local tpReturn = xi.combat.tp.getSingleMeleeHitTPReturn(pet, false) + 10 * (info.hitslanded - 1)
            pet:addTP(tpReturn)
        end

        if damage ~= 0 then
            target:takeDamage(damage, pet, xi.attackType.PHYSICAL, params.damageType)
            target:updateEnmityFromDamage(pet, damage)
        end

        if damage > 0 and info.hitslanded > 0 and params.effect then
            applyAddedEffect(pet, target, addedEffects[params.effect])
        end

        -- The packet needs a shadow count, but takeDamage must never receive it.
        if skill:getMsg() == xi.msg.basic.SHADOW_ABSORB then
            return info.shadowsUsed
        end

        return damage
    end)
end

local function useHybridPact(target, pet, petskill, summoner, action, hits, first, extra)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    local physicalDamage = xi.summon.avatarPhysicalMove(pet, target, petskill, hits, 1, first, extra, xi.mobskills.magicalTpBonus.NO_EFFECT, 1, 2, 3)
    local magicDamage    = 0

    local damage = xi.summon.avatarFinalAdjustments(physicalDamage, pet, petskill, target, xi.attackType.PHYSICAL, xi.damageType.BLUNT, hits)

    if petskill:getMsg() == xi.msg.basic.SHADOW_ABSORB then
        return physicalDamage.shadowsUsed
    end

    if damage > 0 and physicalDamage.hitslanded > 0 then
        local dINT = utils.clamp(pet:getStat(xi.mod.INT) - target:getStat(xi.mod.INT), -65, 999)

        magicDamage = math.max(0, math.floor(damage / 2 + dINT))

        local nullifyDamage         = xi.spells.damage.calculateNullification(target, xi.element.FIRE, true, false)
        local absorbDamage          = xi.spells.damage.calculateAbsorption(target, xi.element.FIRE, true)
        local sdt                   = 1
        local resist                = 1
        local magicDamageAdjustment = 1
        local dayAndWeather         = 1
        local magicBonusDiff        = 1

        local petAccBonus = xi.mobskills.calculatePetMagicAccuracyBonus(pet, target, xi.element.FIRE)

        if absorbDamage > 0 then
            sdt                   = xi.combat.damage.magicalElementSDT(target, xi.element.FIRE)
            resist                = xi.combat.magicHitRate.calculateResistRate(pet, target, 0, 0, 0, xi.element.FIRE, xi.mod.INT, 0, petAccBonus)
            magicDamageAdjustment = xi.combat.damage.calculateDamageAdjustment(target, false, true, false, false)
        end

        dayAndWeather   = xi.spells.damage.calculateDayAndWeather(pet, xi.element.FIRE, false)
        magicBonusDiff  = xi.spells.damage.calculateMagicBonusDiff(pet, target, 0, 0, xi.element.FIRE, 0)

        magicDamage = math.floor(magicDamage * sdt)
        magicDamage = math.floor(magicDamage * resist)
        magicDamage = math.floor(magicDamage * dayAndWeather)
        magicDamage = math.floor(magicDamage * magicBonusDiff)
        magicDamage = math.floor(magicDamage * magicDamageAdjustment)
        magicDamage = math.floor(magicDamage * absorbDamage)
        magicDamage = math.floor(magicDamage * nullifyDamage)
    end

    if magicDamage > 0 then
        magicDamage = target:checkDamageCap(magicDamage)
        magicDamage = utils.handleOneForAll(target, magicDamage)
        magicDamage = utils.handlePhalanx(target, magicDamage)
        magicDamage = utils.handleStoneskin(target, magicDamage)
    end

    if damage > 0 then
        target:takeDamage(damage, pet, xi.attackType.PHYSICAL, xi.damageType.BLUNT)
        target:takeDamage(magicDamage, pet, xi.attackType.MAGICAL, xi.damageType.FIRE)
        target:updateEnmityFromDamage(pet, damage + magicDamage)
    end

    return damage + magicDamage
end

m:addOverride('xi.actions.abilities.pets.burning_strike.onPetAbility', function(target, pet, skill, master, action)
    return useHybridPact(target, pet, skill, master, action, 1, 2.75, 0)
end)

m:addOverride('xi.actions.abilities.pets.flaming_crush.onPetAbility', function(target, pet, skill, master, action)
    return useHybridPact(target, pet, skill, master, action, 2, 6, 1)
end)

m:addOverride('xi.actions.abilities.pets.meteorite.onPetAbility', function(target, pet, skill, master, action)
    xi.job_utils.summoner.onUseBloodPact(target, skill, master, action)

    local dINT = pet:getStat(xi.mod.INT) - target:getStat(xi.mod.INT)
    local params =
    {
        baseDamage = math.max(0, 500 + 1.5 * dINT + skill:getTP() / 20),
        element = xi.element.LIGHT,
        attackType = xi.attackType.MAGICAL,
        damageType = xi.damageType.LIGHT,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
        canMagicBurst = true,
        primaryMessage = xi.msg.basic.USES_JA_TAKE_DAMAGE,
    }

    local info = xi.mobskills.mobMagicalMove(pet, target, skill, action, params)
    if xi.mobskills.processDamage(pet, target, skill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

local magicalPacts =
{
    fire_iv      = { fTP = { 3.6250, 5.3125, 6.1250 }, element = xi.element.FIRE, damageType = xi.damageType.FIRE, shadows = xi.mobskills.shadowBehavior.IGNORE_SHADOWS },
    sonic_buffet = { fTP = { 2.0, 3.0, 4.0 }, element = xi.element.WIND, damageType = xi.damageType.WIND, shadows = xi.mobskills.shadowBehavior.NUMSHADOWS_1, dispel = true },
    tornado_ii   = { fTP = { 6.0000, 7.6875, 8.5000 }, element = xi.element.WIND, damageType = xi.damageType.WIND, shadows = xi.mobskills.shadowBehavior.IGNORE_SHADOWS },
}

for name, data in pairs(magicalPacts) do
    m:addOverride('xi.actions.abilities.pets.' .. name .. '.onPetAbility', function(target, pet, petskill, summoner, action)
        xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

        local params = {}

        params.baseDamage      = pet:getMainLvl() + 2
        params.fTP             = data.fTP
        params.int_wSC         = 0.30
        params.element         = data.element
        params.attackType      = xi.attackType.MAGICAL
        params.damageType      = data.damageType
        params.shadowBehavior  = data.shadows
        params.dStatMultiplier = 1.5
        params.canMagicBurst   = true
        params.primaryMessage  = xi.msg.basic.USES_JA_TAKE_DAMAGE

        local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

        if xi.mobskills.processDamage(pet, target, petskill, action, info) then
            target:takeDamage(info.damage, pet, info.attackType, info.damageType)
        end

        if data.dispel then
            local resist = xi.combat.magicHitRate.calculateResistRate(pet, target, 0, 0, 0, xi.element.WIND, 0, 0, 0)
            if resist > 0.0625 then
                target:dispelStatusEffect()
            end
        end

        return info.damage
    end)
end

m:addOverride('xi.actions.abilities.pets.healing_ruby.onPetAbility', function(target, pet, petskill, summoner, action)
    local base = 14 + target:getMainLvl() + petskill:getTP() / 12

    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    if pet:getMainLvl() > 30 then
        base = 44 + 3 * (pet:getMainLvl() - 30) + petskill:getTP() / 12 * (pet:getMainLvl() * 0.075 - 1)
    end

    if target:getHP() + base > target:getMaxHP() then
        base = target:getMaxHP() - target:getHP()
    end

    petskill:setMsg(xi.msg.basic.JA_RECOVERS_HP_2)
    target:addHP(base)
    return base
end)

m:addOverride('xi.actions.abilities.pets.spring_water.onPetAbility', function(target, pet, petskill, summoner, action)
    local base = 47 + pet:getMainLvl() * 3
    local tp   = petskill:getTP()

    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    if tp < 1000 then
        tp = 1000
    end

    base = base * tp / 1000

    if target:getHP() + base > target:getMaxHP() then
        base = target:getMaxHP() - target:getHP()
    end

    target:delStatusEffect(xi.effect.BLINDNESS)
    target:delStatusEffect(xi.effect.POISON)
    target:delStatusEffect(xi.effect.PARALYSIS)
    target:delStatusEffect(xi.effect.DISEASE)
    target:delStatusEffect(xi.effect.PLAGUE)
    target:delStatusEffect(xi.effect.PETRIFICATION)
    target:wakeUp()
    target:delStatusEffect(xi.effect.SILENCE)
    target:addStatusEffect(xi.effect.REFRESH, { power = 2, duration = 180, origin = pet })

    if math.randomInt(1, 100) <= 50 then
        target:delStatusEffect(xi.effect.SLOW)
    end

    if target:getID() == action:getPrimaryTargetID() then
        petskill:setMsg(xi.msg.basic.JA_RECOVERS_HP_2)
    else
        petskill:setMsg(xi.msg.basic.SELF_HEAL_SECONDARY)
    end

    target:addHP(base)
    return base
end)

return m
