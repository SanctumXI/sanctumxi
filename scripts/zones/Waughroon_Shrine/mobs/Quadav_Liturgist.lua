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

---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.SILENCE)
end

entity.onMobSpawn = function(mob)
    -- Quadav: mild resistance to Earth, weak to its opposite (Wind).
    mob:setMod(xi.mod.EARTH_SDT, -1500)
    mob:setMod(xi.mod.WIND_SDT, 500)
    mob:setMod(xi.mod.POISON_RES_RANK, 4)

    mob:setMod(xi.mod.ACC, 15)
    mob:setMod(xi.mod.RACC, 15)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)
    mob:setMod(xi.mod.CURE_POTENCY, 25)
end

return entity
