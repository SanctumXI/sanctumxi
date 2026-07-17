-----------------------------------
-- Area: Reisenjima Henge (292)
--  HNM: Hard Mode Roc
-----------------------------------
mixins =
{
    require('scripts/mixins/rage'),
    require('scripts/mixins/job_special'),
}

---@type TMobEntity
local entity = {}

local function configureMob(mob)
    mob:renameEntity('Roc', true)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.TERROR)
    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
end

entity.onMobInitialize = function(mob)
    configureMob(mob)
end

entity.onMobSpawn = function(mob)
    configureMob(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 250)
    mob:setMod(xi.mod.EVA, 400)
    mob:setMod(xi.mod.ATT, 325)
    mob:setMod(xi.mod.ACC, 525)
end

entity.onMobFight = function(mob, target)
    local drawInTable =
    {
        conditions =
        {
            target:checkDistance(mob) > mob:getMeleeRange(target),
        },
        position = mob:getPos(),
        offset   = 5,
        degrees  = 180,
        wait     = 10,
    }

    utils.drawIn(target, drawInTable)
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
