-----------------------------------
-- Sanctum jug pet: Apkallu
-- Dapper Mac (75-99), the only pet in its family
--
-- Role: weak pet, strong reliable stun, and the Light half of the skillchain
-- pair with the Diremite's Darkness.
--
-- Both moves route through xi.apkallu.canUseAbility, which refuses in Arrapago
-- Reef and Mount Zhayolm whenever the server-wide Apkallu hate variable sits
-- under its threshold. That is a wild mob mechanic and has no business gating a
-- pet, so the checks are dropped here.
--
-- Resistances and skillchain properties live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_apkallu')

m:addOverride('xi.actions.abilities.pets.wing_slap.onAbilityCheck', function(player, target, ability)
    return 0
end)

m:addOverride('xi.actions.abilities.pets.beak_lunge.onAbilityCheck', function(player, target, ability)
    return 0
end)

-----------------------------------
-- Wing Slap
-- Four hits at an upstream rate of 0.3 came to roughly a fifth of what any
-- other two charge move does, the worst rate on the roster by a wide margin.
-- 0.8 leaves it the weakest damage in the game, which suits a pet that is here
-- for the stun, without making the button a waste of the bar.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.wing_slap.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 4
    params.fTP            = { 0.8, 0.8, 0.8 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_4

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STUN, 1, 0, 4)
    end

    return info.damage
end)

return m
