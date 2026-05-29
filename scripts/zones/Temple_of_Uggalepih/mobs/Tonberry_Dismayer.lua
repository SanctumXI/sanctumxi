-----------------------------------
-- Area: Temple of Uggalepih
--  Mob: Tonberry Dismayer
-- Note: PH for Tonberry Kinq
-----------------------------------
local ID = zones[xi.zone.TEMPLE_OF_UGGALEPIH]
mixins = { require('scripts/mixins/families/tonberry') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Tonberrys_Elemental')
end

entity.onMobDeath = function(mob, player, optParams)
    xi.regime.checkRegime(player, mob, 790, 1, xi.regime.type.GROUNDS)
    xi.regime.checkRegime(player, mob, 791, 1, xi.regime.type.GROUNDS)
    xi.regime.checkRegime(player, mob, 792, 1, xi.regime.type.GROUNDS)
    xi.regime.checkRegime(player, mob, 793, 1, xi.regime.type.GROUNDS)
    xi.regime.checkRegime(player, mob, 794, 1, xi.regime.type.GROUNDS)
    xi.regime.checkRegime(player, mob, 795, 1, xi.regime.type.GROUNDS)
end

entity.onMobDespawn = function(mob)
    xi.mob.phOnDespawn(mob, ID.mob.TONBERRY_KINQ, 5, 1) -- True Lottery, 5% Pop Chance
end

return entity
