-----------------------------------
-- Area: Reisenjima Henge (292)
--  Mob: Hard Mode Simurgh Aspect
-----------------------------------
local simurghMechanics = require('scripts/globals/sanctum/simurgh')

---@type TMobEntity
local entity = {}

local aspectModelSize  = 1 -- Simurgh's smallest model-specific size variant.
local aspectHitboxSize = 1.5

local function configureMob(mob)
    local aspectIndex = simurghMechanics.getAspectIndex(mob)
    local aspect      = aspectIndex and simurghMechanics.aspectData[aspectIndex] or nil

    if aspect then
        mob:renameEntity(aspect.name, true)
    end

    mob:setModelSize(aspectModelSize)
    mob:setHitboxSize(aspectHitboxSize)
    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.TERROR)
end

entity.onMobInitialize = function(mob)
    configureMob(mob)
end

entity.onMobSpawn = function(mob)
    configureMob(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)
    mob:setMod(xi.mod.ACC, 475)
    mob:setMod(xi.mod.EVA, 350)

    local aspectIndex = simurghMechanics.getAspectIndex(mob)
    if aspectIndex then
        simurghMechanics.setAspectActive(simurghMechanics.getBoss(mob), aspectIndex, true)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    local aspectIndex = simurghMechanics.getAspectIndex(mob)
    if aspectIndex then
        simurghMechanics.setAspectActive(simurghMechanics.getBoss(mob), aspectIndex, false)
    end
end

entity.onMobDespawn = function(mob)
    local aspectIndex = simurghMechanics.getAspectIndex(mob)
    if aspectIndex then
        simurghMechanics.setAspectActive(simurghMechanics.getBoss(mob), aspectIndex, false)
    end
end

return entity
