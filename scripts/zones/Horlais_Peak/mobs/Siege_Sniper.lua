-----------------------------------
-- Area: Horlais Peak
--  Mob: Siege Sniper
-- KSNM: King of The North
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
}
-----------------------------------

local tuning =
{
    level                = 75,
    accuracyBonus        = 30,
    rangedAccuracyBonus  = 30,
    baseDamageMultiplier = 125,
}

---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
end

entity.onMobSpawn = function(mob)
    if mob:getMainLvl() ~= tuning.level then
        mob:setMobLevel(tuning.level)
    end

    mob:setMod(xi.mod.ICE_SDT, -1500)
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 4)

    mob:addMod(xi.mod.ACC, tuning.accuracyBonus)
    mob:addMod(xi.mod.RACC, tuning.rangedAccuracyBonus)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, tuning.baseDamageMultiplier)
end

return entity
