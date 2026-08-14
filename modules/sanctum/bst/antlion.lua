-----------------------------------
-- Sanctum jug pet: Antlion
-- Antlion Familiar (38-50) / Chopsuey Chucky (63-80)
--
-- Role: the widest area coverage on the roster, on the hardest hitting chassis.
-- DRK's Attack Bonus V is the largest flat attack trait in the game, so at 80
-- Chucky swings with 363 attack against the next best pet's 303.
--
-- Sandpit and Venom Spray are left to the upstream scripts; only their shape
-- changes. Family ranks, the earth resistance and the area shapes live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_antlion')

-----------------------------------
-- Mandibular Bite
-- The single target bite becomes a cone, and the flat rate becomes a curve.
--
-- The 50% attack bonus on the move is upstream and kept: it stacks on top of
-- the DRK attack trait rather than replacing it. Detonation is dropped, so the
-- family carries no skillchain property at all.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.mandibular_bite.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage       = pet:getWeaponDmg()
    params.numHits          = 1
    params.fTP              = { 2.0, 2.5, 3.0 }
    params.attackType       = xi.attackType.PHYSICAL
    params.damageType       = xi.damageType.PIERCING
    params.shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.attackMultiplier = { 1.5, 1.5, 1.5 }

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Sandblast
-- Earth damage in a radius around the pet, which the move never had: upstream
-- applies a blind and nothing else, despite its own header describing earth
-- damage in an area.
--
-- Blindness comes down from 40 over 180 seconds to 30 over 90, since the move
-- is now paying for itself in damage.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.sandblast.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getMainLvl() + 2
    params.fTP            = { 2.0, 2.5, 3.0 }
    params.element        = xi.element.EARTH
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.EARTH
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.BLINDNESS, 30, 0, 90)
    end

    return info.damage
end)

return m
