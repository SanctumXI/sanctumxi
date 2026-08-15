-----------------------------------
-- Sanctum jug pet: Fly
-- Mayfly Familiar (33-45) / Shellbuster Orob (53-70)
--
-- Role: magic damage out of ready moves, the counterpart to Slippery Silas,
-- who does his with spells. Both families run BLM for the same reason:
-- magical mobskill damage scales off intelligence and Magic Attack Bonus, and
-- nothing else on the roster supplies either.
--
-- The job, family ranks, Orob's level cap and Cursed Sphere's charge cost live
-- in modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_fly')

-----------------------------------
-- Cursed Sphere
-- The family's heavy hitter at two charges. Its radius is centred on the
-- target rather than the pet, which is rare and makes it the cleanest area
-- nuke on the roster. Curse is upstream and kept.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.cursed_sphere.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getMainLvl() + 2
    params.fTP            = { 3.5, 4.0, 4.5 }
    params.element        = xi.element.DARK
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.DARK
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.CURSE_I, 30, 0, 60)
    end

    return info.damage
end)

-----------------------------------
-- Venom
-- The cheap water cone. Poison goes from 2 a tick to 3, which is still modest
-- but no longer rounding error.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.venom.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getMainLvl() + 2
    params.fTP            = { 1.5, 2.0, 2.5 }
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, 3, 3, 60)
    end

    return info.damage
end)

-----------------------------------
-- Somersault
-- The family's only physical move and its only skillchain. It gives up the
-- 50% attack bonus it carried and pays for it with a curve instead, and it
-- shakes one enfeeble off the pet as it tumbles.
--
-- The erase lands on whoever used the move, never on the master.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.somersault.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.5, 3.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    pet:eraseStatusEffect()

    return info.damage
end)

-----------------------------------
-- Somersault, wild fly copy
-- Same self erase, upstream damage left alone.
-----------------------------------

m:addOverride('xi.actions.mobskills.somersault.onMobWeaponSkill', function(mob, target, skill, action)
    local damage = super(mob, target, skill, action)

    mob:eraseStatusEffect()

    return damage
end)

return m
