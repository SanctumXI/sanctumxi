-----------------------------------
-- Sanctum jug pet: Beetle
-- Beetle Familiar (38-45) / Panzer Galahad (63-80)
--
-- Role: solo tank. Family VIT rank 2 and PLD's VIT grade 1 are the best pairing
-- on the roster, and Defense Bonus V lands at level 76.
--
-- The two damage moves were near identical, both fTP 1.0 with a doubled attack
-- multiplier. Power Attack keeps the critical scaling, Rhino Attack becomes the
-- hate button.
--
-- Resistances and Hi-Freq Field's charge cost live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_beetle')

-----------------------------------
-- Power Attack
-- Physical damage. Critical rate raised from nothing to 15/25/50 across TP.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.power_attack.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage       = pet:getWeaponDmg()
    params.numHits          = 1
    params.fTP              = { 1.0, 1.0, 1.0 }
    params.attackType       = xi.attackType.PHYSICAL
    params.damageType       = xi.damageType.HAND_TO_HAND
    params.shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.attackMultiplier = { 2.0, 2.0, 2.0 }
    params.canCrit          = true
    params.criticalChance   = { 0.15, 0.25, 0.50 }

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Rhino Attack
-- Physical damage carrying Provoke's enmity. Critical scaling moved to Power
-- Attack so the two are no longer the same move twice.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.rhino_attack.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage       = pet:getWeaponDmg()
    params.numHits          = 1
    params.fTP              = { 1.0, 1.0, 1.0 }
    params.attackType       = xi.attackType.PHYSICAL
    params.damageType       = xi.damageType.BLUNT
    params.shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.attackMultiplier = { 2.0, 2.0, 2.0 }

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        pet:addEnmity(target, 600, 2000)
    end

    return info.damage
end)

-----------------------------------
-- Rhino Guard
-- Counter for the pet. Was 35 flat evasion on a TP scaled 60 to 180 seconds,
-- the only jug move whose duration genuinely varied with TP.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.rhino_guard.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 90)

    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.COUNTER_BOOST, 20, 0, duration))

    return xi.effect.COUNTER_BOOST
end)

-----------------------------------
-- Hi-Freq Field
-- Conal evasion down, dropped from 60 to 40 to pay for the cheaper charge cost.
-- Evasion Down is a flat reduction capped at the target's own evasion.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.hi-freq_field.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.EVASION_DOWN, 40, 0, 90))

    return xi.effect.EVASION_DOWN
end)

return m
