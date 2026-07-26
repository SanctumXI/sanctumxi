-----------------------------------
-- Area: Balga's Dais
--  Mob: Divine Reproach
-- KSNM: Wing and a Prayer
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
}
-----------------------------------

---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
end

return entity
