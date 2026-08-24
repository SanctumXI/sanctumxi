-----------------------------------
-- Sanctum jug pet: Sheep
-- Sheep Familiar (19-35) / Lullaby Melodia (43-65) / Nursery Nazuna (75-80)
--
-- Charge costs, Sheep Song's radius and Nursery Nazuna's model live in
-- modules/sanctum/jobs/beastmaster/sql/jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_beastmaster_sheep')

-----------------------------------
-- Rage
-- Berserk for the pet and its master.
--
-- Power drops from 45 to 25 and the duration goes from 2 to 3 minutes. The
-- effect stays Berserk on purpose so it cannot stack with a warrior's own,
-- and the -25% defense the effect carries is part of the deal.
--
-- Note the Berserk job ability is only power 21 at level 75, so Rage still
-- overwrites it and cannot be replaced by it until the recast is up.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.rage.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 180)

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.BERSERK, 25, 0, duration))

    return xi.effect.BERSERK
end)

return m
