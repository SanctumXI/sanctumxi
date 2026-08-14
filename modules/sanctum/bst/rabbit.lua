-----------------------------------
-- Sanctum jug pet: Rabbit
-- Hare Familiar (12-35) / Keeneared Steffi (43-75) / Lucky Lulush (75-80)
--
-- Role: back-up emergency healing. Wild Carrot is the reason to bring one.
-- Lucky Lulush trades Dust Cloud for Snow Cloud, an ice nuke that upgrades
-- Whirl Claws rather than sitting beside it.
--
-- Main job, Keeneared Steffi's model and Snow Cloud's charge cost and shape
-- live in modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_rabbit')

-----------------------------------
-- Whirl Claws
-- Area damage around the pet, now scaling off AGI.
--
-- fSTR is fixed as STR against the target's VIT and cannot be retargeted, but
-- the weapon skill stat contribution can, so half the pet's AGI is added to
-- base damage before fTP.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.whirl_claws.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.0, 2.0 }
    params.agi_wSC        = 0.5
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
-- Wild Carrot
-- Party heal centred on the pet.
--
-- Was 104/1024 of the pet's max HP, roughly 350 at level 78. Raised to a fifth
-- so it lands near a Cure IV per target, which is what makes it worth two
-- charges as an emergency button.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.wild_carrot.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.msg.basic.SELF_HEAL)

    return xi.mobskills.mobHealMove(target, math.floor(pet:getMaxHP() * 0.2))
end)

-----------------------------------
-- Snow Cloud
-- Lucky Lulush only. Ice damage around the pet. Additional effect: Paralysis.
--
-- fTP raised from 2.0 to 3.5 so that at two charges it reads as an upgrade to
-- Whirl Claws rather than a sidegrade.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.snow_cloud.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getMainLvl() + 2
    params.fTP            = { 3.5, 3.5, 3.5 }
    params.element        = xi.element.ICE
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.ICE
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.PARALYSIS, 40, 0, 60)
    end

    return info.damage
end)

return m
