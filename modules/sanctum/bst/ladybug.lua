-----------------------------------
-- Sanctum jug pet: Ladybug
-- Lucky Lyra (75-80), the only pet in its family
--
-- Role: the pet is deliberately feeble. Its value is that it is a THF, so its
-- Treasure Hunter II and Gilfinder land on the mob's hate list, and it hands
-- the party a critical hit rate buff.
--
-- Skillchain properties, charge costs, Lucky Charm's targeting and the family
-- data live in modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_ladybug')

-----------------------------------
-- Sudden Lunge
-- Physical damage that costs the pet a bite of its own health, and tears
-- agility out of the target.
--
-- AGI Down sheds a point of power every tick, so 30 power on a 3 second tick
-- runs itself out exactly as the 90 seconds expire.
--
-- The recoil is upstream behaviour that jug pets have never paid: it lives in
-- onMobSkillFinalize, which petskill_state does not call. Applied here, and
-- like the original it lands whether or not the attack connects.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.sudden_lunge.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 1.7, 1.7, 1.7 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.AGI_DOWN, 30, 3, 90)
    end

    local currentHP = pet:getHP()

    pet:setHP(currentHP - math.floor(currentHP * math.randomInt(10, 20) / 100))

    return info.damage
end)

-----------------------------------
-- Spiral Spin
-- Conal physical damage. The accuracy down rider is dropped; the move pays for
-- its second charge in damage and in opening Detonation.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.spiral_spin.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.0, 2.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3
    params.canCrit        = true
    params.criticalChance = { 0.10, 0.20, 0.25 }

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Lucky Charm
-- Critical hit rate for the pet and the party around it.
--
-- Replaces Noisome Powder, which was an enemy attack-down gated to Vanadiel
-- daylight. The gate never reached the pet: the wrapper's onAbilityCheck
-- returns 0 without consulting the mobskill's check.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.noisome_powder.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 90)

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.LUCKY_CHARM, 5, 0, duration))

    return xi.effect.LUCKY_CHARM
end)

return m
