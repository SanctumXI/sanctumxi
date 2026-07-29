-----------------------------------
-- Area: Waughroon Shrine
--  Mob: Quadav Liturgist
-- KSNM: Heavy Is the Shell
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
}
-----------------------------------

local tuning =
{
    level                = 75,
    accuracyBonus        = 15,
    rangedAccuracyBonus  = 15,
    baseDamageMultiplier = 125,
    curePotency          = 25,
}

---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.SILENCE)
end

entity.onMobSpawn = function(mob)
    if mob:getMainLvl() ~= tuning.level then
        mob:setMobLevel(tuning.level)
    end

    mob:setMod(xi.mod.EARTH_SDT, -1500)
    mob:setMod(xi.mod.WIND_SDT, 500)
    mob:setMod(xi.mod.POISON_RES_RANK, 4)

    mob:addMod(xi.mod.ACC, tuning.accuracyBonus)
    mob:addMod(xi.mod.RACC, tuning.rangedAccuracyBonus)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, tuning.baseDamageMultiplier)
    mob:setMod(xi.mod.CURE_POTENCY, tuning.curePotency)
end

return entity
