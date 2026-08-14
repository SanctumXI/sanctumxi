-----------------------------------
-- Sanctum jug pet: Coeurl
-- Crafty Clyvonne (75-90), the only pet in its family
--
-- Role: single target damage carried by attack speed rather than by ready
-- moves. Every coeurl in the game gains 25% haste from the family modifier;
-- Clyvonne carries 40%, which takes her 4000ms swing down to 2400.
--
-- Family ranks, the family haste modifier, Blaster's charge cost and the model
-- sizes live in modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_coeurl')

-----------------------------------
-- Haste, applied on spawn.
--
-- mob_family_mods never reaches a pet: AddSqlModifiers is called for mobs and
-- trusts only, so the family's 25% covers every wild coeurl and misses this
-- one. Clyvonne takes 40% here instead.
--
-- Split across the ability and gear buckets on purpose. Magic haste is a third
-- bucket with its own 43.75% cap, so leaving it empty means a white mage's
-- Haste still stacks on top rather than being wasted.
--
-- setMod rather than addMod so a respawn cannot stack it.
-----------------------------------

m:addOverride('xi.pets.jug.onMobSpawn', function(pet)
    super(pet)

    if pet:getPetID() == xi.petId.CRAFTY_CLYVONNE then
        pet:setMod(xi.mod.HASTE_ABILITY, 2500)
        pet:setMod(xi.mod.HASTE_GEAR, 1500)
    end
end)

-----------------------------------
-- Blaster
-- Three charges now, and 45 seconds rather than 60. Power 70 is untouched and
-- is the strongest paralyse of any jug pet by a wide margin.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.blaster.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.PARALYSIS, 70, 0, 45))

    return xi.effect.PARALYSIS
end)

return m
