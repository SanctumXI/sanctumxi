-----------------------------------
-- Area: Waughroon Shrine
--  Mob: Ro'Hyu Blackanvil
-- KSNM: Heavy Is the Shell
-----------------------------------
local adamantking = require('scripts/globals/adamantking')
-----------------------------------

local tuning =
{
    level                 = 85,
    hpBonus               = 0,
    attackBonus           = 0,
    defenseBonus          = 0,
    accuracyBonus         = 30,
    evasionBonus          = 0,
    magicAttackBonus      = 0,
    baseDamageMultiplier  = 175,
    curePotency           = 25,
    regain                = 20,
    physicalDamageTaken   = 0,
    rangedDamageTaken     = 0,
    breathDamageTaken     = 0,
    magicDamageTaken      = 0,
    auraSize              = -125,
    auraSlowPower         = 5000,
}

---@type TMobEntity
local entity = {}

local function applySlowAura(mob)
    if not mob:hasStatusEffect(xi.effect.COLURE_ACTIVE) then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.SLOW, subPower = tuning.auraSlowPower, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
    end
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:setMod(xi.mod.AURA_SIZE, tuning.auraSize)
end

entity.onMobSpawn = function(mob)
    if mob:getMainLvl() ~= tuning.level then
        mob:setMobLevel(tuning.level)
    end

    mob:addMod(xi.mod.HP, tuning.hpBonus)
    mob:addMod(xi.mod.ATT, tuning.attackBonus)
    mob:addMod(xi.mod.DEF, tuning.defenseBonus)
    mob:addMod(xi.mod.ACC, tuning.accuracyBonus)
    mob:addMod(xi.mod.EVA, tuning.evasionBonus)
    mob:addMod(xi.mod.MATT, tuning.magicAttackBonus)
    mob:setMod(xi.mod.REGAIN, tuning.regain)
    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken)
    mob:setMod(xi.mod.UDMGRANGE, tuning.rangedDamageTaken)
    mob:setMod(xi.mod.UDMGBREATH, tuning.breathDamageTaken)
    mob:setMod(xi.mod.UDMGMAGIC, tuning.magicDamageTaken)

    mob:setMod(xi.mod.EARTH_SDT, -4000)
    mob:setMod(xi.mod.EARTH_RES_RANK, 10)
    mob:setMod(xi.mod.WIND_SDT, 1000)

    mob:setMod(xi.mod.STUN_RES_RANK, 8)
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)

    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, tuning.baseDamageMultiplier)
    mob:setMod(xi.mod.CURE_POTENCY, tuning.curePotency)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 2098)
    mob:setHP(mob:getMaxHP())

    adamantking.reset(mob)
    applySlowAura(mob)
end

entity.onMobFight = function(mob, target)
    applySlowAura(mob)
    adamantking.tryTorment(mob, target)
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.DISPERSER_OF_DARKNESS)
    end
end

return entity
