-----------------------------------
-- Sanctum jug pet: Ladybug
-- Dipper Yuly (75-80), the only pet in its family
--
-- Role: the pet is deliberately feeble. Its value is that it is a THF, so its
-- Treasure Hunter II and Gilfinder land on the mob's hate list, and it hands
-- the party a critical hit rate buff.
--
-- Skillchain properties, Lucky Spots' targeting and the family data live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_ladybug')

-----------------------------------
-- Sudden Lunge
-- Physical damage, stun, and agility torn out of the target.
--
-- AGI Down sheds a point of power every tick, so 30 power on a 3 second tick
-- runs itself out exactly as the 90 seconds expire.
--
-- The upstream skill also strips 10 to 20% of the user's own HP, but that
-- lives in onMobSkillFinalize, which petskill_state does not call. Wild
-- ladybugs pay it; the pet never has.
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

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STUN, 1, 0, 6)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.AGI_DOWN, 30, 3, 90)
    end

    return info.damage
end)

-----------------------------------
-- Lucky Spots
-- Critical hit rate for the pet and the party around it.
--
-- Replaces Noisome Powder, which was an enemy attack-down gated to Vanadiel
-- daylight. The gate never reached the pet: the wrapper's onAbilityCheck
-- returns 0 without consulting the mobskill's check.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.noisome_powder.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.LUCKY_SPOTS, 5, 0, 90))

    return xi.effect.LUCKY_SPOTS
end)

return m
