-----------------------------------
-- Sanctum jug pet: Diremite
-- Mite Familiar (43-55) / Lifedrinker Lars (63-80)
--
-- Role: sustain. Grapple is the only self healing the family has, and it is
-- the reason to bring one.
--
-- DRK is the strongest offensive package available to a pet: Attack Bonus V is
-- +60 and Damage Limit+ V is 50, both the best of any job. Its Smite is inert
-- though, gated behind objtype & TYPE_PC.
--
-- Charge costs, skillchain properties and family stats live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_diremite')

-----------------------------------
-- Double Claw
-- Two hits instead of one. fTP stays flat, so the second hit lands at the
-- standard subsequent-hit multiplier rather than scaling with TP.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.double_claw.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 2
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Grapple
-- Conal damage drained back as HP.
--
-- mobDrainMove deals the damage itself and heals the pet for the same amount,
-- so it replaces takeDamage rather than following it. Against undead it deals
-- damage and heals nothing, which is the correct behaviour.
--
-- Note this runs once per target, so a full cone drains from each of them.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.grapple.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_4

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        petskill:setMsg(xi.mobskills.mobDrainMove(pet, target, xi.mobskills.drainType.HP, info.damage, info.attackType, info.damageType))
    end

    return info.damage
end)

-----------------------------------
-- Spinning Top
-- A twofold attack. At one hit it was the worst rate on the roster by some
-- way: three charges, the whole bar, for less damage per charge than any
-- single charge move in the game. The second hit is what the family's premium
-- closer should have been paying out all along.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.spinning_top.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 2
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Filamented Hold
-- Conal slow, cut from 120 to 60 seconds now that it costs a single charge.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.filamented_hold.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.SLOW, 2500, 0, 60))

    return xi.effect.SLOW
end)

return m
