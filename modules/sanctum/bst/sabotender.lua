-----------------------------------
-- Sanctum jug pet: Sabotender
-- Amigo Sabotender (75-80), the only pet in its family
--
-- Role: hyper-evasive, fast, true damage. Family DEX, AGI and EVA are all rank
-- 1 and PUP brings Evasion Bonus IV on top.
--
-- Family stats, resistances and the radius live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_sabotender')

-----------------------------------
-- 1,000 Needles
--
-- Was the Abyssea NM's ??? Needles: 1000 to 10000 random base, which on a level
-- 78 pet ran between seven and thirty five times anything else in the game.
-- Now exactly 1000, split evenly across everything in range.
--
-- skipPDIF bypasses the damage multiplier and skipFSTR keeps the strength
-- contribution out, so the total lands on 1000 rather than near it.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.random_needles.onPetAbility', function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage         = 1000 / petskill:getTotalTargets()
    params.numHits            = 1
    params.fTP                = { 1.0, 1.0, 1.0 }
    params.attackType         = xi.attackType.PHYSICAL
    params.damageType         = xi.damageType.PIERCING
    params.shadowBehavior     = xi.mobskills.shadowBehavior.WIPE_SHADOWS
    params.guaranteedFirstHit = true
    params.skipPDIF           = true
    params.skipFSTR           = true

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end)

-----------------------------------
-- Movement speed
--
-- Call Beast and Bestial Loyalty both flatten every jug pet to base speed 55
-- after spawning, which overwrites the family speed the pet loaded with. Run
-- the original first, then put the Sabotender back where it belongs.
-----------------------------------

local function restoreSabotenderSpeed(player)
    local pet = player:getPet()

    if pet and pet:getPetID() == xi.petId.AMIGO_SABOTENDER then
        pet:setBaseSpeed(90)
    end
end

m:addOverride('xi.job_utils.beastmaster.useCallBeast', function(player, target, ability)
    super(player, target, ability)

    restoreSabotenderSpeed(player)
end)

m:addOverride('xi.job_utils.beastmaster.useBestialLoyalty', function(player, target, ability)
    super(player, target, ability)

    restoreSabotenderSpeed(player)
end)

return m
