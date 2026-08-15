-----------------------------------
-- Sanctum jug pet: Funguar
-- Funguar Familiar (33-65)
--
-- Role: mid-game debuff specialist. Low damage, but the widest spread of
-- enfeebles on the jug roster.
--
-- Upstream gates the three shrooms behind the pet's animationsub, which is the
-- wild funguar's mushroom cap cycling 0 -> 1 -> 2 -> 3. On a pet that meant
-- Queasyshroom, then Numbshroom, then Shakeshroom, once each, in that order,
-- and never again for the life of the jug. The gate is dropped here and the
-- shrooms no longer advance the counter.
--
-- Charge costs and the RDM main job live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_funguar')

-- The three shrooms share a body apart from their rider.
local function shroomAttack(target, pet, petskill, action, applyEffect)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.canCrit        = true
    params.criticalChance = { 0.10, 0.20, 0.25 }

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        applyEffect(target, pet)
    end

    return info.damage
end

-----------------------------------
-- Queasyshroom
-- Physical damage. Additional effect: Poison.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.queasyshroom.onAbilityCheck', function(player, target, ability)
    return 0
end)

m:addOverride('xi.actions.abilities.pets.queasyshroom.onPetAbility', function(target, pet, petskill, owner, action)
    return shroomAttack(target, pet, petskill, action, function(effectTarget, effectPet)
        local power = math.floor(effectPet:getMainLvl() / 10) + 1

        xi.mobskills.mobStatusEffectMove(effectPet, effectTarget, xi.effect.POISON, power, 3, 60)
    end)
end)

-----------------------------------
-- Numbshroom
-- Physical damage. Additional effect: Paralysis.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.numbshroom.onAbilityCheck', function(player, target, ability)
    return 0
end)

m:addOverride('xi.actions.abilities.pets.numbshroom.onPetAbility', function(target, pet, petskill, owner, action)
    return shroomAttack(target, pet, petskill, action, function(effectTarget, effectPet)
        xi.mobskills.mobStatusEffectMove(effectPet, effectTarget, xi.effect.PARALYSIS, 30, 0, 120)
    end)
end)

-----------------------------------
-- Shakeshroom
-- Physical damage. Additional effects: Plague and Disease.
--
-- Disease is the flavour half and does nothing to a mob, since its only
-- consumer blocks resting. Plague is the half that bites: it drains the
-- target's TP and MP every tick, delaying its TP moves.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.shakeshroom.onAbilityCheck', function(player, target, ability)
    return 0
end)

m:addOverride('xi.actions.abilities.pets.shakeshroom.onPetAbility', function(target, pet, petskill, owner, action)
    return shroomAttack(target, pet, petskill, action, function(effectTarget, effectPet)
        xi.mobskills.mobStatusEffectMove(effectPet, effectTarget, xi.effect.PLAGUE, 5, 3, 30)
        xi.mobskills.mobStatusEffectMove(effectPet, effectTarget, xi.effect.DISEASE, 1, 0, 120)
    end)
end)

return m
