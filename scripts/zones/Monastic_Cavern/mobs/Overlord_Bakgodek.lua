-----------------------------------
-- Area: Monastic Cavern
--  Mob: Overlord Bakgodek
-- TODO: messages should be zone-wide
-----------------------------------
local ID = zones[xi.zone.MONASTIC_CAVERN]
mixins = { require('scripts/mixins/job_special') }
-----------------------------------

-- Mirrors Frostscar Hrozdag (KSNM: King of The North). See scripts/zones/Horlais_Peak/mobs/Frostscar_Hrozdag.lua
local auraReturnTime = 600

---@type TMobEntity
local entity = {}

local function enableAura(mob)
    if mob:getLocalVar('auraActive') == 0 then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.FLASH, subPower = 100, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
        mob:addMod(xi.mod.DEF, 200)
        mob:addMod(xi.mod.MDEF, 100)
        mob:setLocalVar('auraActive', 1)
    end
end

local function disableAura(mob)
    if mob:getLocalVar('auraActive') == 1 then
        mob:delStatusEffectSilent(xi.effect.COLURE_ACTIVE)
        mob:delMod(xi.mod.DEF, 200)
        mob:delMod(xi.mod.MDEF, 100)
        mob:setLocalVar('auraActive', 0)
    end
end

local function breakAura(mob)
    if mob:getLocalVar('auraPhase') == 0 then
        disableAura(mob)
        mob:setLocalVar('auraPhase', 1)
        mob:setLocalVar('auraReturn', GetSystemTime() + auraReturnTime)
    end
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:setMod(xi.mod.AURA_SIZE, -125)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)
    mob:setMod(xi.mod.SLOW_RES_RANK, 8)
    mob:setMod(xi.mod.SILENCE_RES_RANK, 11)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)

    mob:addMod(xi.mod.ACC, 30)
    mob:setMod(xi.mod.REGAIN, 20)

    -- Frost-forged warlord: strongly resists Ice, slightly weak to its opposite (Fire).
    mob:setMod(xi.mod.ICE_SDT, 4000)
    mob:setMod(xi.mod.ICE_RES_RANK, 10)
    mob:setMod(xi.mod.FIRE_SDT, -1000)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 2101)
    mob:setLocalVar('auraActive', 0)
    mob:setLocalVar('auraPhase', 0)
    mob:setLocalVar('auraReturn', 0)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            {
                id       = xi.mobSkill.MIGHTY_STRIKES_1,
                cooldown = 180,
                hpp      = 80,
                begCode  = breakAura,
            },
        },
    })

    enableAura(mob)
end

entity.onMobFight = function(mob, target)
    if mob:getLocalVar('auraPhase') == 0 and mob:getHPP() <= 75 then
        breakAura(mob)
    elseif
        mob:getLocalVar('auraPhase') == 1 and
        GetSystemTime() >= mob:getLocalVar('auraReturn')
    then
        enableAura(mob)
        mob:setLocalVar('auraPhase', 2)
    end
end

entity.onMobEngage = function(mob, target)
    mob:showText(mob, ID.text.ORC_KING_ENGAGE)
end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.TP_DRAIN, { chance = 35, power = math.randomInt(95, 135) })
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.OVERLORD_OVERTHROWER)
    end

    if optParams.isKiller or optParams.noKiller then
        mob:showText(mob, ID.text.ORC_KING_DEATH)
    end
end

entity.onMobDespawn = function(mob)
    -- reset hqnm system back to the nm placeholder
    local nqId = mob:getID() - 1
    SetServerVariable('[POP]Overlord_Bakgodek', GetSystemTime() + 259200) -- 3 days
    SetServerVariable('[PH]Overlord_Bakgodek', 0)
    DisallowRespawn(mob:getID(), true)
    DisallowRespawn(nqId, false)
    xi.mob.updateNMSpawnPoint(nqId)
    GetMobByID(nqId):setRespawnTime(math.randomInt(75600, 86400))
end

return entity
