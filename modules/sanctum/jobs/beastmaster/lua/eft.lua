-----------------------------------
-- Sanctum jug pet: Eft
-- Eft Familiar (33-45) / Ambusher Allie (58-75) / Bugeyed Broncha (90-99)
--
-- Role: Geist Wall as a real AoE dispel, plus a ranged opener. RNG's AGI grade
-- and Accuracy Bonus IV carry the ranged half.
--
-- Charge costs, the main job, family ranks, resistances and Toxic Spit's range
-- live in modules/sanctum/jobs/beastmaster/sql/jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_beastmaster_eft')

-----------------------------------
-- Toxic Spit
-- The opener. Was a melee-range poison with no damage at all; now a ranged
-- attack out to 20 yalms that poisons for 6 a tick over 3 minutes.
--
-- Also picks up the message the upstream skill never set, so it reports the
-- enfeeble line instead of the generic one.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.toxic_spit.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.0, 2.0 }
    params.attackType     = xi.attackType.RANGED
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.skipParry      = false
    params.skipGuard      = false
    params.skipBlock      = false

    local info = xi.mobskills.mobRangedMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, 6, 3, 180)
    end

    return info.damage
end)

-----------------------------------
-- Nimble Snap
-- Threefold attack, now scaling off DEX and hitting at fTP 2.0.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.nimble_snap.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 3
    params.fTP            = { 2.0, 2.0, 2.0 }
    params.dex_wSC        = 0.5
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
-- Geist Wall
-- Strips two beneficial effects per target instead of one.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.geist_wall.onPetAbility', function(target, pet, petskill, owner, action)
    local dispelled = xi.effect.NONE

    for _ = 1, 2 do
        local effect = target:dispelStatusEffect()

        if effect == xi.effect.NONE then
            break
        end

        dispelled = effect
    end

    if dispelled == xi.effect.NONE then
        petskill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)
    else
        petskill:setMsg(xi.msg.basic.SKILL_ERASE)
    end

    return dispelled
end)

-----------------------------------
-- Numbing Noise
-- Stun cut to 2 seconds, with paralysis riding alongside it.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.numbing_noise.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STUN, 1, 0, 2))

    xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.PARALYSIS, 30, 0, 90)

    return xi.effect.STUN
end)

return m
