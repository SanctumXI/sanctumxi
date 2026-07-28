-----------------------------------
-- Area: Waughroon Shrine
--  Mob: Quadav Earthshaper
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
    mob:setMod(xi.mod.EARTH_SDT, 1500)
    mob:setMod(xi.mod.WIND_SDT, -500)
    mob:setMod(xi.mod.POISON_RES_RANK, 4)
end

return entity
