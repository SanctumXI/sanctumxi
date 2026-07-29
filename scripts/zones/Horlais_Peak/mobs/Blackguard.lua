-----------------------------------
-- Area: Horlais Peak
--  Mob: Blackguard
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
    mob:setMod(xi.mod.ICE_SDT, -1500)
    mob:setMod(xi.mod.SLOW_RES_RANK, 4)

    mob:setMod(xi.mod.ACC, 15)
    mob:setMod(xi.mod.RACC, 15)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.INVINCIBLE_1 },
        },
    })
end

return entity
