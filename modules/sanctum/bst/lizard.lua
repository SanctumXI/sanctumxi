-----------------------------------
-- Sanctum jug pet: Hill Lizard
-- Lizard Familiar (33-45) / Coldblood Como (53-75) / Audacious Anna (85-95)
--
-- Role: disruptor. Silence and stun, and the best skillchain kit on the jug
-- roster: Brain Crush opens Liquefaction, Tail Blow closes it for Fusion.
--
-- Secretion's party reach and radius live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_lizard')

-----------------------------------
-- Secretion
-- Evasion for the pet and the party around it.
--
-- Was 40 evasion on the pet and master alone for 30 seconds. Dropped to 25
-- now that it covers the whole party, and stretched to 90 seconds.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.secretion.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 90)

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.EVASION_BOOST, 25, 0, duration))

    return xi.effect.EVASION_BOOST
end)

return m
