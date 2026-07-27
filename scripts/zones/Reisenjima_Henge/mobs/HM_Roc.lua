-----------------------------------
-- Area: Reisenjima Henge (292)
--  HNM: Hard Mode Roc
-----------------------------------
mixins =
{
    require('scripts/globals/magicburst'),
    require('scripts/mixins/job_special'),
}



---@type TMobEntity
local entity = {}

-----------------------------------
-- Configuration
-----------------------------------

local dreadDiveMinimumDelay = 50
local dreadDiveMaximumDelay = 70

local rageInterval = 180
local rageDuration = 30

local magicBurstInterval = 90

local desperationMinimumDelay = 18
local desperationMaximumDelay = 28

local maximumPowerTier = 4

-----------------------------------
-- Mob skills
--
-- Replace these IDs with the actual IDs
-- from scripts/enum/mob_skill.lua.
-----------------------------------

local dreadDiveSkill = 924

local desperationSkills =
{
    2425, -- Bloody Claw
    2434, -- Reaving Wind Knockback
    2728, -- Wings of Agony
}

-----------------------------------
-- Permanent missed-MB bonuses
--
-- These values represent the TOTAL bonus
-- at each tier, not the increase per tier.
-----------------------------------

local powerTiers =
{
    [0] =
    {
        att    = 0,
        def    = 0,
        acc    = 0,
        eva    = 0,
        matt   = 0,
        mdef   = 0,
        haste  = 0,
        regain = 0,
    },

    [1] =
    {
        att    = 35,
        def    = 25,
        acc    = 20,
        eva    = 10,
        matt   = 20,
        mdef   = 15,
        haste  = 250,
        regain = 10,
    },

    [2] =
    {
        att    = 75,
        def    = 55,
        acc    = 40,
        eva    = 20,
        matt   = 40,
        mdef   = 30,
        haste  = 500,
        regain = 20,
    },

    [3] =
    {
        att    = 125,
        def    = 90,
        acc    = 65,
        eva    = 35,
        matt   = 65,
        mdef   = 50,
        haste  = 750,
        regain = 35,
    },

    [4] =
    {
        att    = 190,
        def    = 140,
        acc    = 100,
        eva    = 50,
        matt   = 100,
        mdef   = 75,
        haste  = 1000,
        regain = 50,
    },
}

-----------------------------------
-- Temporary Rage bonuses
-----------------------------------

local rageBonuses =
{
    att          = 250,
    def          = 150,
    acc          = 100,
    eva          = 50,
    matt         = 100,
    mdef         = 75,
    haste        = 1500,
    regain       = 100,
    doubleAttack = 25,
}

-----------------------------------
-- Utility functions
-----------------------------------

local function configureMob(mob)
    mob:renameEntity('Roc', true)

    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.TERROR)

    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
end

local function applyPowerTierMods(mob, tier, multiplier)
    local tierData = powerTiers[tier]

    if not tierData then
        return
    end

    mob:addMod(xi.mod.ATT, tierData.att * multiplier)
    mob:addMod(xi.mod.DEF, tierData.def * multiplier)
    mob:addMod(xi.mod.ACC, tierData.acc * multiplier)
    mob:addMod(xi.mod.EVA, tierData.eva * multiplier)
    mob:addMod(xi.mod.MATT, tierData.matt * multiplier)
    mob:addMod(xi.mod.MDEF, tierData.mdef * multiplier)
    mob:addMod(xi.mod.HASTE_ABILITY, tierData.haste * multiplier)
    mob:addMod(xi.mod.REGAIN, tierData.regain * multiplier)
end

local function sendEncounterMessage(mob, message)
    local instance = mob:getInstance()

    if not instance then
        return
    end

    for _, player in ipairs(instance:getChars()) do
        player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
    end
end

local function setPowerTier(mob, newTier)
    local oldTier = mob:getLocalVar('PowerTier')

    newTier = math.min(newTier, maximumPowerTier)

    if newTier == oldTier then
        return
    end

    applyPowerTierMods(mob, oldTier, -1)
    applyPowerTierMods(mob, newTier, 1)

    mob:setLocalVar('PowerTier', newTier)
    sendEncounterMessage(mob, 'The Roc gathers more power.')
    mob:useMobAbility()
end

local function startRage(mob)
    if mob:getLocalVar('RageActive') == 1 then
        return
    end

    mob:setLocalVar('RageActive', 1)

    mob:addMod(xi.mod.ATT, rageBonuses.att)
    mob:addMod(xi.mod.DEF, rageBonuses.def)
    mob:addMod(xi.mod.ACC, rageBonuses.acc)
    mob:addMod(xi.mod.EVA, rageBonuses.eva)
    mob:addMod(xi.mod.MATT, rageBonuses.matt)
    mob:addMod(xi.mod.MDEF, rageBonuses.mdef)
    mob:addMod(xi.mod.HASTE_ABILITY, rageBonuses.haste)
    mob:addMod(xi.mod.REGAIN, rageBonuses.regain)
    mob:addMod(xi.mod.DOUBLE_ATTACK, rageBonuses.doubleAttack)

    sendEncounterMessage(mob, 'Roc flies into a violent rage!')

    mob:timer(rageDuration * 1000, function(roc)
        if not roc:isAlive() then
            return
        end

        roc:delMod(xi.mod.ATT, rageBonuses.att)
        roc:delMod(xi.mod.DEF, rageBonuses.def)
        roc:delMod(xi.mod.ACC, rageBonuses.acc)
        roc:delMod(xi.mod.EVA, rageBonuses.eva)
        roc:delMod(xi.mod.MATT, rageBonuses.matt)
        roc:delMod(xi.mod.MDEF, rageBonuses.mdef)
        roc:delMod(xi.mod.HASTE_ABILITY, rageBonuses.haste)
        roc:delMod(xi.mod.REGAIN, rageBonuses.regain)
        roc:delMod(xi.mod.DOUBLE_ATTACK, rageBonuses.doubleAttack)

        roc:setLocalVar('RageActive', 0)

        sendEncounterMessage(roc, 'Roc\'s rage subsides.')
    end)
end

local function getValidInstancePlayers(mob)
    local validPlayers = {}
    local instance = mob:getInstance()

    if not instance then
        return validPlayers
    end

    for _, player in ipairs(instance:getChars()) do
        if
            player and
            player:isAlive() and
            player:getZoneID() == mob:getZoneID() and
            mob:checkDistance(player) <= 50
        then
            table.insert(validPlayers, player)
        end
    end

    return validPlayers
end

local function useDreadDive(mob)
    local players = getValidInstancePlayers(mob)

    if #players == 0 then
        return
    end

    local dreadTarget = players[math.random(1, #players)]

    mob:useMobAbility(dreadDiveSkill, dreadTarget)
end

local function useDesperationSkill(mob)
    if #desperationSkills == 0 then
        return
    end

    local skillId = desperationSkills[math.random(1, #desperationSkills)]

    if skillId == 0 then
        return
    end

    mob:useMobAbility(skillId)
end

local function registerMagicBurst(mob)
    local now = GetSystemTime()

    mob:setLocalVar('LastMagicBurst', now)
    sendEncounterMessage(mob, 'The monster loses some of its power.')
end

-----------------------------------
-- Initialization
-----------------------------------

entity.onMobInitialize = function(mob)
    configureMob(mob)
end

-----------------------------------
-- Spawn
-----------------------------------

entity.onMobSpawn = function(mob)
    configureMob(mob)

    -----------------------------------
    -- Base combat statistics
    -----------------------------------

    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 250)

    mob:setMod(xi.mod.EVA, 400)
    mob:setMod(xi.mod.ATT, 325)
    mob:setMod(xi.mod.ACC, 525)

    mob:addMod(xi.mod.REGEN, 10)

    -----------------------------------
    -- Encounter state
    -----------------------------------

    mob:setLocalVar('HardModeRoc', 1)

    mob:setLocalVar('PowerTier', 0)
    mob:setLocalVar('RageActive', 0)
    mob:setLocalVar('DesperationActive', 0)

    mob:setLocalVar('LastMagicBurst', 0)
    mob:setLocalVar('NextRage', 0)
    mob:setLocalVar('NextDreadDive', 0)
    mob:setLocalVar('NextDesperationSkill', 0)
end

-----------------------------------
-- Engage
-----------------------------------

entity.onMobEngage = function(mob, target)
    local now = GetSystemTime()

    mob:setLocalVar('LastMagicBurst', now)
    mob:setLocalVar('NextRage', now + rageInterval)

    mob:setLocalVar(
        'NextDreadDive',
        now + math.random(dreadDiveMinimumDelay, dreadDiveMaximumDelay)
    )

    mob:setLocalVar('NextDesperationSkill', 0)
end

-----------------------------------
-- Fight
-----------------------------------

entity.onMobFight = function(mob, target)
    local now = GetSystemTime()

    -----------------------------------
    -- Existing draw-in behavior
    -----------------------------------

    local drawInTable =
    {
        conditions =
        {
            target:checkDistance(mob) > mob:getMeleeRange(target),
        },

        position = mob:getPos(),
        offset   = 5,
        degrees  = 180,
        wait     = 10,
    }

    utils.drawIn(target, drawInTable)

    -----------------------------------
    -- Random-target Dread Dive
    -----------------------------------

    if
        now >= mob:getLocalVar('NextDreadDive') and
        mob:getLocalVar('RageActive') == 0 and
        mob:getLocalVar('ForcedAbilityActive') == 0 and
        not mob:hasPreventActionEffect()
    then
        mob:setLocalVar('ForcedAbilityActive', 1)

        useDreadDive(mob)

        mob:setLocalVar(
            'NextDreadDive',
            now + math.random(dreadDiveMinimumDelay, dreadDiveMaximumDelay)
        )

        mob:timer(5000, function(roc)
            if roc:isAlive() then
                roc:setLocalVar('ForcedAbilityActive', 0)
            end
        end)
    end

    -----------------------------------
    -- Rage every three minutes
    -----------------------------------

    if
        now >= mob:getLocalVar('NextRage') and
        mob:getLocalVar('RageActive') == 0
    then
        startRage(mob)

        mob:setLocalVar('NextRage', now + rageInterval)
    end

    -----------------------------------
    -- Magic-burst escalation
    -----------------------------------

    local lastMagicBurst = mob:getLocalVar('LastMagicBurst')

    if lastMagicBurst > 0 then
        local timeSinceBurst = now - lastMagicBurst

        if timeSinceBurst >= magicBurstInterval then
            local currentTier = mob:getLocalVar('PowerTier')

            if currentTier < maximumPowerTier then
                setPowerTier(mob, currentTier + 1)
            else
                sendEncounterMessage(mob, 'Roc remains at maximum power!')
            end

            -- Begin another 90-second requirement window.
            mob:setLocalVar('LastMagicBurst', now)
        end
    end

    -----------------------------------
    -- Deadly phase below 25%
    -----------------------------------

    if mob:getHPP() <= 25 then
        if mob:getLocalVar('DesperationActive') == 0 then
            mob:setLocalVar('DesperationActive', 1)

            mob:setLocalVar(
                'NextDesperationSkill',
                now + desperationMinimumDelay
            )

            sendEncounterMessage(mob, 'Roc unleashes its full predatory fury!')

            -- Permanent final-phase bonuses.
            mob:addMod(xi.mod.REGAIN, 50)
            mob:addMod(xi.mod.DOUBLE_ATTACK, 15)
            mob:addMod(xi.mod.CRITHITRATE, 15)
        end

        if
            now >= mob:getLocalVar('NextDesperationSkill') and
            mob:getLocalVar('ForcedAbilityActive') == 0 and
            not mob:hasPreventActionEffect()
        then
            mob:setLocalVar('ForcedAbilityActive', 1)

            useDesperationSkill(mob)

            mob:setLocalVar(
                'NextDesperationSkill',
                now + math.random(
                    desperationMinimumDelay,
                    desperationMaximumDelay
                )
            )

            mob:timer(5000, function(roc)
                if roc:isAlive() then
                    roc:setLocalVar('ForcedAbilityActive', 0)
                end
            end)
        end
    end
end

-----------------------------------
-- Magic burst registration
-----------------------------------

entity.onMagicHit = function(caster, target, spell)
    local _, skillchainCount = xi.magicburst.formMagicBurst(target, spell:getElement())

    if spell:tookEffect() and skillchainCount > 0 then
        registerMagicBurst(target)
    end
end

-----------------------------------
-- Death
-----------------------------------

entity.onMobDeath = function(mob, player, optParams)
end

return entity
