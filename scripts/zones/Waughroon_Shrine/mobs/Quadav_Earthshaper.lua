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

return entity
