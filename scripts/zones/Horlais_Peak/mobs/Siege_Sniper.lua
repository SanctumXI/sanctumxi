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

---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
end

entity.onMobSpawn = function(mob)
    -- Frost-forged orc: mild resistance to Ice, its liege's element.
    mob:setMod(xi.mod.ICE_SDT, 1500)
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 4)
end

return entity
