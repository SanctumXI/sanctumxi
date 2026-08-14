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

return m
