-----------------------------------
-- Sanctum jug pet: Crab
-- Crab Familiar (15-55) / Courier Carrie (23-75)
--
-- Role: party support tank. Scissor Guard and Bubble Curtain cover the party's
-- physical and magical mitigation, Metallic Body keeps the crab itself alive.
--
-- The upstream wrappers all forward to scripts/actions/mobskills, which every
-- wild crab in the game also runs. Overriding onPetAbility here keeps these
-- changes on jug pets only.
--
-- Charge costs and AoE shape live in modules/sanctum/jobs/beastmaster/sql/jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_beastmaster_crab')

-----------------------------------
-- Magic Evasion Boost
--
-- Effect 611 has no upstream script; modules/sanctum/data/status_effects.yaml
-- points it back at scripts/effects/magic_evasion_boost.lua. Decay only happens
-- when the applier passes a tick rate, so Clarsach Call is unaffected.
-----------------------------------

m:addOverride('xi.effects.magic_evasion_boost.onEffectTick', function(target, effect)
    local power = effect:getPower()
    if power > 0 then
        effect:setPower(power - 1)
        target:delMod(xi.mod.MEVA, 1)
    end
end)

-----------------------------------
-- Bubble Shower
-- Water damage in an area of effect. Additional effect: STR Down.
-- STR Down raised from 10 to 12.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.bubble_shower.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.percentMultipier = 0.0625
    params.damageCap        = 200
    params.bonusDamage      = 0
    params.mAccuracyBonus   = { 0, 0, 0 }
    params.resistStat       = xi.mod.INT
    params.element          = xi.element.WATER
    params.attackType       = xi.attackType.BREATH
    params.damageType       = xi.damageType.WATER
    params.shadowBehavior   = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobBreathMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STR_DOWN, 12, 9, 180)
    end

    return info.damage
end)

-----------------------------------
-- Bubble Curtain
-- Magic evasion for the pet and the party around it.
--
-- Was Shell at power 5000, a 50% magic damage cut that overwrote a white mage's
-- Shell V and did not give it back on wearing off. Magic evasion is a separate
-- mechanism, so the two now stack.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.bubble_curtain.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 75)

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.MAGIC_EVASION_BOOST, 25, 3, duration))

    return xi.effect.MAGIC_EVASION_BOOST
end)

-----------------------------------
-- Big Scissors
-- Physical damage plus a small amount of enmity.
--
-- 200/600 is worth roughly 130 extra damage of hate at level 75. Beetle keeps
-- the heavy enmity role.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.big_scissors.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.0, 2.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        pet:addEnmity(target, 200, 600)
    end

    return info.damage
end)

-----------------------------------
-- Scissor Guard
-- Defense for the pet and the party around it.
--
-- Was +100% on the pet alone. The upstream wrapper passed the pet as the target
-- on every pass, so the master got the animation and the log line but never the
-- buff. Defense Boost is a percentage on top of Protect's flat defense, so the
-- two stack.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.scissor_guard.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 60)

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 20, 0, duration))

    return xi.effect.DEFENSE_BOOST
end)

-----------------------------------
-- Metallic Body
-- Stoneskin for the pet and its master, scaled off the crab.
--
-- Stoneskin will not overwrite itself while either side sits at tier 0, so the
-- old one has to be cleared or the move can only ever land once.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.metallic_body.onPetAbility', function(target, pet, petskill, owner, action)
    local power = math.floor(pet:getMaxHP() * 0.2)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 300)

    target:delStatusEffect(xi.effect.STONESKIN)

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.STONESKIN, power, 0, duration))

    return xi.effect.STONESKIN
end)

return m
