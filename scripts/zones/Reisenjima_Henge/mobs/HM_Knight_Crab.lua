-----------------------------------
-- Area: Reisenjima Henge (292)
--  Mob: Hard Mode Knight Crab
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:renameEntity('Knight Crab', true)
end

entity.onMobSpawn = function(mob)
    mob:renameEntity('Knight Crab', true)
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
