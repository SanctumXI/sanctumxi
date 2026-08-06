-----------------------------------
-- Sanctum weapon-skill integration snapshot
-- Source: scripts/globals/job_utils/paladin.lua
-- Generated from the current custom implementation so the module remains
-- independent from later edits to the original script.
-----------------------------------
require('modules/module_utils')
-----------------------------------

-----------------------------------
-- Paladin Job Utilities
-----------------------------------
xi = xi or {}
xi.job_utils = xi.job_utils or {}
xi.job_utils.paladin = xi.job_utils.paladin or {}

local shieldMasteryIILevel = 50
local shieldMasteryIITP    = 20
local resolveMaxStacks     = 5
local resolveChargedIcon   = 26
local resolveEffectFlags   =
    xi.effectFlag.DEATH +
    xi.effectFlag.ON_ZONE +
    xi.effectFlag.NO_LOSS_MESSAGE +
    xi.effectFlag.ON_JOBCHANGE +
    xi.effectFlag.NO_CANCEL

-----------------------------------
-- Job Trait Functions
-----------------------------------
xi.job_utils.paladin.restoreShieldMasteryMP = function(player)
    if
        player:isPC() and
        player:getMainJob() == xi.job.PLD and
        player:getMainLvl() >= shieldMasteryIILevel and
        player:getMod(xi.mod.SHIELD_MASTERY_TP) >= shieldMasteryIITP
    then
        return player:addMP(math.randomInt(1, 3))
    end

    return 0
end

xi.job_utils.paladin.getResolveStacks = function(player)
    local resolveEffect = player:getStatusEffect(xi.effect.RESOLVE)

    if resolveEffect then
        return utils.clamp(resolveEffect:getPower(), 0, resolveMaxStacks)
    end

    return 0
end

xi.job_utils.paladin.addResolveStack = function(player)
    if not player:hasStatusEffect(xi.effect.PALISADE) then
        return 0
    end

    local resolveEffect = player:getStatusEffect(xi.effect.RESOLVE)

    if not resolveEffect then
        player:addStatusEffect(xi.effect.RESOLVE, {
            power  = 1,
            origin = player,
            icon   = 0,
            flag   = resolveEffectFlags,
            silent = true,
        })

        return xi.job_utils.paladin.getResolveStacks(player)
    end

    local stacks = math.min(resolveEffect:getPower() + 1, resolveMaxStacks)

    resolveEffect:setPower(stacks)

    if
        stacks == resolveMaxStacks and
        resolveEffect:getIcon() ~= resolveChargedIcon
    then
        resolveEffect:setIcon(resolveChargedIcon)
    end

    return stacks
end

xi.job_utils.paladin.consumeResolve = function(player)
    local stacks = xi.job_utils.paladin.getResolveStacks(player)

    if stacks > 0 then
        player:delStatusEffectSilent(xi.effect.RESOLVE)
    end

    return stacks
end

xi.job_utils.paladin.applyResolveDamageBonus = function(damage, stacks, percentPerStack)
    local stackCount = utils.clamp(stacks, 0, resolveMaxStacks)

    return math.floor(damage * (100 + stackCount * percentPerStack) / 100)
end

-----------------------------------
-- Ability Check Functions
-----------------------------------
xi.job_utils.paladin.checkCover = function(player, target, ability)
    if
        target == nil or
        target:getID() == player:getID() or
        not target:isPC()
    then
        return xi.msg.basic.CANNOT_PERFORM_TARG, 0
    else
        return 0, 0
    end
end

xi.job_utils.paladin.checkIntervene = function(player, target, ability)
    if player:getShieldSize() == 0 then
        return xi.msg.basic.REQUIRES_SHIELD, 0
    else
        ability:setRecast(math.max(0, ability:getRecast() - player:getMod(xi.mod.ONE_HOUR_RECAST) * 60))

        return 0, 0
    end
end

xi.job_utils.paladin.checkInvincible = function(player, target, ability)
    local jpValue = player:getJobPointLevel(xi.jp.INVINCIBLE_EFFECT)

    ability:setVE(ability:getVE() + 100 * jpValue)
    ability:setRecast(math.max(0, ability:getRecast() - player:getMod(xi.mod.ONE_HOUR_RECAST) * 60))

    return 0, 0
end

xi.job_utils.paladin.checkSepulcher = function(player, target, ability)
    if target:isUndead() then
        return 0, 0
    else
        return xi.msg.basic.CANNOT_ON_THAT_TARG, 0
    end
end

xi.job_utils.paladin.checkShieldBash = function(player, target, ability)
    if player:getShieldSize() == 0 then
        return xi.msg.basic.REQUIRES_SHIELD, 0
    else
        return 0, 0
    end
end

-----------------------------------
-- Ability Use Functions
-----------------------------------
xi.job_utils.paladin.useChivalry = function(player, target, ability, action)
    local meritLevel = math.floor(player:getMerit(xi.merit.CHIVALRY) / 5)
    local tp = target:getTP()
    local mnd = target:getStat(xi.mod.MND)
    meritLevel = utils.clamp(meritLevel, 1, 5)

    -- Sanctum Custom formula
    local amount = tp * (0.05 + (0.15 * (meritLevel - 1)) + (0.0015 * mnd))

    target:setTP(0)
    return target:addMP(amount)
end

xi.job_utils.paladin.useCover = function(player, target, ability)
    local baseDuration = 15
    local bonusTime    = utils.clamp(math.floor((player:getStat(xi.mod.VIT) + player:getStat(xi.mod.MND) - target:getStat(xi.mod.VIT) * 2) / 4), 0, 15)
    local jpValue      = player:getJobPointLevel(xi.jp.COVER_DURATION)
    local duration     = baseDuration + bonusTime + player:getMerit(xi.merit.COVER_EFFECT_LENGTH) + player:getMod(xi.mod.COVER_DURATION) + jpValue

    player:addStatusEffect(xi.effect.COVER, { power = player:getMod(xi.mod.COVER_TO_MP), duration = duration, origin = player })
    player:setLocalVar('COVER_ABILITY_TARGET', target:getID())
    ability:setMsg(xi.msg.basic.COVER_SUCCESS)
end

xi.job_utils.paladin.useDivineEmblem = function(player, target, ability)
    -- Divine Magic bonus damage handled in globals/magic.lua
    local power = 50 + player:getMod(xi.mod.ENHANCES_DIVINE_EMBLEM) -- 50% increase to enmity

    player:addStatusEffect(xi.effect.DIVINE_EMBLEM, { power = power, duration = 60, origin = player })

    return xi.effect.DIVINE_EMBLEM
end

xi.job_utils.paladin.useFealty = function(player, target, ability)
    local merits    = player:getMerit(xi.merit.FEALTY) 
    --local enhFealty = (player:getMerit(xi.merit.FEALTY) / 5) * player:getMod(xi.mod.ENHANCES_FEALTY)
    --local duration  = 60 + merits + enhFealty

    player:addStatusEffect(xi.effect.FEALTY, { power = 1, duration = 10, origin = player })

    return xi.effect.FEALTY
end

xi.job_utils.paladin.useHolyCircle = function(player, target, ability)
    -- TODO:
    -- Create Bonus vs Ecosystem handling
    -- https://www.bg-wiki.com/ffxi/Holy_Circle
    -- Main (PLD) job gives a unique 15% damage bonus against undead, 15% damage resistance from undead, and likely +15% Undead Killer.
    -- When subbed, gives 5% of these bonuses.
    local duration = 180 + player:getMod(xi.mod.HOLY_CIRCLE_DURATION)
    local power    = 15

    if player:getMainJob() ~= xi.job.PLD then
        power = 5
    end

    power = power + player:getMod(xi.mod.HOLY_CIRCLE_POTENCY)

    target:addStatusEffect(xi.effect.HOLY_CIRCLE, { power = power, duration = duration, origin = player })

    return xi.effect.HOLY_CIRCLE
end

xi.job_utils.paladin.useIntervene = function(player, target, ability)
    -- TODO: Retail testing to determine damage
    local shieldSize = player:getShieldSize()
    local jpValue    = 1 + (player:getJobPointLevel(xi.jp.INTERVENE_EFFECT) / 100)
    local damage     = math.floor(player:getMainLvl() * 3.36)

    if shieldSize == 2 then
        damage = 13 + damage
    elseif shieldSize == 3 then
        damage = 40 + damage
    elseif shieldSize == 4 then
        damage = 67 + damage
    end

    damage = damage * jpValue

    target:addStatusEffect(xi.effect.INTERVENE, { power = 1, duration = 30, origin = player })

    return damage
end

xi.job_utils.paladin.useInvincible = function(player, target, ability)
    player:addStatusEffect(xi.effect.INVINCIBLE, { power = 1, duration = 30, origin = player })

    return xi.effect.INVINCIBLE
end

xi.job_utils.paladin.useMajesty = function(player, target, ability)
    player:addStatusEffect(xi.effect.MAJESTY, { power = 25, duration = 30, origin = player })

    return xi.effect.MAJESTY
end

xi.job_utils.paladin.usePalisade = function(player, target, ability)
    local jpValue = player:getJobPointLevel(xi.jp.PALISADE_EFFECT)
    local power   = 10 + jpValue

    player:addStatusEffect(xi.effect.PALISADE, { power = power, duration = 180, origin = player })

    return xi.effect.PALISADE
end

xi.job_utils.paladin.useRampart = function(player, target, ability)
    local duration = 30 + player:getMod(xi.mod.RAMPART_DURATION)

    target:addStatusEffect(xi.effect.RAMPART, { power = 2500, duration = duration, origin = player })

    return xi.effect.RAMPART
end

xi.job_utils.paladin.useSentinel = function(player, target, ability)
    -- Whether feet have to be equipped before using ability, or if they can be swapped in
    -- is disputed.  Source used: http://wiki.bluegartr.com/bg/Sentinel
    local power       = (90 + player:getMod(xi.mod.SENTINEL_EFFECT)) * 100
    local guardian    = player:getMerit(xi.merit.GUARDIAN)
    local enhGuardian = player:getMod(xi.mod.ENHANCES_GUARDIAN) * (guardian / 19)
    local jpValue     = player:getJobPointLevel(xi.jp.SENTINEL_EFFECT)
    local duration    = 30 + enhGuardian

    -- Sent as positive power because UINTs, man.
    player:addStatusEffect(xi.effect.SENTINEL, { power = power, duration = duration, origin = player, tick = 3, subPower = guardian + jpValue })

    return xi.effect.SENTINEL
end

xi.job_utils.paladin.useSepulcher = function(player, target, ability)
    local power    = 20
    local jpValue  = player:getJobPointLevel(xi.jp.SEPULCHER_DURATION)
    local duration = 180 + jpValue

    target:addStatusEffect(xi.effect.SEPULCHER, { power = power, duration = duration, origin = player })
end

xi.job_utils.paladin.useShieldBash = function(player, target, ability)
    local shieldSize = player:getShieldSize()
    local jpValue    = player:getJobPointLevel(xi.jp.SHIELD_BASH_EFFECT)
    local damage     = math.floor(player:getMainLvl() * 0.273)
    local chance     = 90

    if shieldSize == 2 then
        damage = 13 + damage
    elseif shieldSize == 3 then
        damage = 40 + damage
    elseif shieldSize == 4 then
        damage = 67 + damage
    end

    -- Main job factors
    if player:getMainJob() ~= xi.job.PLD then
        damage = math.floor(damage / 2.5)
        chance = 60
    else
        damage = math.floor(damage)
    end

    damage = damage + player:getMod(xi.mod.SHIELD_BASH) + (jpValue * 10)

    if xi.wsEffect.has(player, xi.wsEffect.BLACK_HALO_BASH) then
        local _, power = xi.wsEffect.consume(player)
        local mpRestored = player:addMP(math.floor(player:getMaxMP() * 0.10))

        damage = math.floor(damage * (1 + power / 100))

        xi.wsEffect.message(player, string.format('Black Halo empowered Shield Bash and restored %i MP!', mpRestored))
    end

    -- Calculate stun proc chance
    chance = chance + (player:getMainLvl() - target:getMainLvl()) * 5

    if math.randomInt(1, 100) <= chance then
        target:addStatusEffect(xi.effect.STUN, { power = 1, duration = 6, origin = player })
    end

    -- Randomize damage
    local randomizer = 1 + (math.randomInt(1, 5) / 100)

    damage = damage * randomizer
    damage = utils.handleStoneskin(target, damage)

    target:takeDamage(damage, player, xi.attackType.PHYSICAL, xi.damageType.BLUNT)
    target:updateEnmityFromDamage(player, damage)
    ability:setMsg(xi.msg.basic.JA_DAMAGE)

    return damage
end


local sanctumCapturedFunctions =
{
    ['xi.job_utils.paladin.restoreShieldMasteryMP'] = xi.job_utils.paladin.restoreShieldMasteryMP,
    ['xi.job_utils.paladin.getResolveStacks'] = xi.job_utils.paladin.getResolveStacks,
    ['xi.job_utils.paladin.addResolveStack'] = xi.job_utils.paladin.addResolveStack,
    ['xi.job_utils.paladin.consumeResolve'] = xi.job_utils.paladin.consumeResolve,
    ['xi.job_utils.paladin.applyResolveDamageBonus'] = xi.job_utils.paladin.applyResolveDamageBonus,
    ['xi.job_utils.paladin.usePalisade'] = xi.job_utils.paladin.usePalisade,
    ['xi.job_utils.paladin.useShieldBash'] = xi.job_utils.paladin.useShieldBash,
}

local sanctumModule = Module:new('sanctum_ws_paladin')

for functionName, implementation in pairs(sanctumCapturedFunctions) do
    sanctumModule:addOverride(functionName, implementation)
end

return sanctumModule
