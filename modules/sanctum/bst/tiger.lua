-----------------------------------
-- Sanctum jug pet: Tiger
-- Tiger Familiar (28-40) / Saber Siravarde (51-69)
--
-- Role: the party's attack buff, carried by the best melee chassis on the
-- roster. A ranks in attack, accuracy and, through WAR, strength.
--
-- Charge costs, family ranks, Roar's targeting, Siravarde's level cap and the
-- skillchain properties live in modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_tiger')

-----------------------------------
-- Roar
-- Attack for the pet and the party around it, replacing an area paralyse.
--
-- Power is the attack percentage outright. Clarsach Call puts the same effect
-- on the pet at power 25 and the effect is overwrite-equal-or-higher, so while
-- that is up Roar passes the pet by and only the party takes it. Roar refreshes
-- itself either way.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.roar.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 90)

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.ATTACK_BOOST, 10, 0, duration))

    return xi.effect.ATTACK_BOOST
end)

-----------------------------------
-- Razor Fang
-- The family's hammer: one charge, one hit, the steepest curve in the kit.
-- Impaction is dropped so Crossthrash owns the family's skillchains.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.razor_fang.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 3.0, 3.5, 4.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Claw Cyclone
-- The cheap cone. Scission is dropped alongside Razor Fang's Impaction.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.claw_cyclone.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.25, 2.5 }
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
-- Crossthrash
-- The expensive cone, and the only move in the family that still carries a
-- skillchain. It pays for the second charge in damage now rather than in a
-- dispel, which is dropped.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.crossthrash.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.75, 3.25, 3.75 }
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
-- Predatory Glare
-- Implemented from nothing. The upstream wrapper carries no onPetAbility at
-- all and its onAbilityCheck returns PET_CANNOT_DO_ACTION, so the move sat in
-- the skill list unusable. Both halves are supplied here.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.predatory_glare.onAbilityCheck', function(player, target, ability)
    return 0
end)

m:addOverride('xi.actions.abilities.pets.predatory_glare.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STUN, 1, 0, 5))

    return xi.effect.STUN
end)

return m
