-----------------------------------
-- Sanctum jug pet: Mandragora
-- Homunculus (23-75) / Flowerpot Bill (28-40) / Flowerpot Ben (51-75)
--
-- Role: crowd control. Dream Flower drops to a single charge, which makes this
-- the cheapest area sleep anyone can bring. The rest of the kit pays for it.
--
-- Charge costs, family INT, resistances, skillchain properties and Leaf
-- Dagger's range live in modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_mandragora')

-----------------------------------
-- Dream Flower
-- Sleep is overwrite-higher, a strict greater-than, so at power 1 the move
-- could never land on anything it had already slept. Clearing the old effect
-- first lets the pet refresh its own sleep.
--
-- Sleep II and Sleepga II are power 2, so those are left alone and the move
-- reports no effect against them rather than trading a 90 second sleep for a
-- shorter one. Power and duration are otherwise untouched.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.dream_flower.onPetAbility', function(target, pet, petskill, owner, action)
    local existing = target:getStatusEffect(xi.effect.SLEEP_I)

    if existing and existing:getPower() <= 1 then
        target:delStatusEffect(xi.effect.SLEEP_I)
    end

    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.SLEEP_I, 1, 0, math.randomInt(15, 45)))

    return xi.effect.SLEEP_I
end)

-----------------------------------
-- Head Butt
-- A real TP curve rather than a flat rate. A Ready move spends whatever TP the
-- pet has banked, so a Mandragora left to swing hits half again as hard as one
-- whose charges go out on sight.
--
-- Detonation is dropped. Leaf Dagger's Scission is the family's only skillchain
-- property now, so the Mandragora no longer chains with itself.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.head_butt.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.5, 3.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Wild Oats
-- Two charges, and a damage curve that earns the second one.
--
-- Vitality Down sheds a point every other tick, so 15 power on a 6 second tick
-- runs itself out exactly as the 90 seconds expire. It was 10 power on a 9
-- second tick against a 120 second duration, which emptied out at 90 and
-- deleted itself early.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.wild_oats.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 1.5, 2.0, 2.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.VIT_DOWN, 15, 6, 90)
    end

    return info.damage
end)

-----------------------------------
-- Leaf Dagger
-- Reports as ranged damage, which is what the hit routine has always been:
-- upstream ran it through mobRangedMove while tagging it physical, so ranged
-- damage taken never applied. Same shape as the Eft's Toxic Spit.
--
-- Poison power is floored. Upstream handed addStatusEffect level over ten,
-- which is a fraction at every level that does not divide by ten.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.leaf_dagger.onPetAbility', function(target, pet, petskill, owner, action)
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

        local power = math.max(1, math.floor(pet:getMainLvl() / 10))

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, power, 3, 90)
    end

    return info.damage
end)

-----------------------------------
-- Scream
-- Mind Down on the same decay as Wild Oats: 15 power on a 6 second tick over
-- 90 seconds. It was 15 power on a 3 second tick against a 180 second
-- duration, so it ran dry in 45 seconds and the rest of the timer did nothing.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.scream.onPetAbility', function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.MND_DOWN, 15, 6, 90))

    return xi.effect.MND_DOWN
end)

return m
