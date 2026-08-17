-----------------------------------
-- Sanctum jug pet: Frog
-- Slippery Silas (23-99), the only pet in its family
--
-- Role: the only jug pet that casts. Family INT is rank A, the best on the
-- roster, and BLM carries it.
--
-- Silas was completely inert: no skill list, no spell list, and SMN as a main
-- job, which grants no MP at all in LoadJugStats. He now runs BLM on a short
-- water and drain list, with Frog Cheer as his one ready move.
--
-- The job, the lists, the charge cost and Frog Cheer's targeting live in
-- modules/sanctum/sql/bst_jug_pets.sql.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_frog')
local frogCheerIcon = 634

-----------------------------------
-- Spell list, applied on spawn.
--
-- CPetEntity::Spawn only compiles mob_pools.spellList into the container the
-- caster actually reads when the pet is Elemental ecosystem, which is spirits
-- and avatars. Every jug pet is left with an empty container and never casts.
-- setSpellList runs the compile step the ecosystem gate skips.
--
-- Gated on the pet id so this stays the only casting jug pet. The Flytrap,
-- Antlion and Diremite pets keep their dormant lists.
-----------------------------------

m:addOverride('xi.pets.jug.onMobSpawn', function(pet)
    super(pet)

    if pet:getPetID() == xi.petId.SLIPPERY_SILAS then
        pet:setSpellList(900)
    end
end)

-----------------------------------
-- Frog Cheer
-- Magic accuracy for the pet and the party around it.
--
-- The wild Poroggo version is a self-buff and keeps its magic attack; only the
-- pet's copy reads as a party buff. Elemental Seal moves off it either way,
-- onto Providence.
-----------------------------------

m:addOverride('xi.actions.abilities.pets.frog_cheer.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 60)
    local effectApplied = target:addStatusEffect(xi.effect.FROG_CHEER, {
        power    = 22,
        duration = duration,
        origin   = target,
        icon     = frogCheerIcon,
    })

    petskill:setMsg(effectApplied and xi.msg.basic.SKILL_GAIN_EFFECT or xi.msg.basic.SKILL_NO_EFFECT)

    return frogCheerIcon
end)

-----------------------------------
-- Frog Cheer, wild Poroggo copy
-- Keeps the magic attack self-buff and gives up Elemental Seal, which was
-- handing every Poroggo 256 magic accuracy on a move they open with.
-----------------------------------

m:addOverride('xi.actions.mobskills.frog_cheer.onMobWeaponSkill', function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.MAGIC_ATK_BOOST, 40, 0, 60))

    return xi.effect.MAGIC_ATK_BOOST
end)

-----------------------------------
-- Providence
-- Picks up the Elemental Seal that Frog Cheer gave up. It already swaps the
-- Poroggo onto a one-shot spell list with no cooldown, so the seal lands on
-- the move that was always the setup for a single big cast.
-----------------------------------

m:addOverride('xi.actions.mobskills.providence.onMobWeaponSkill', function(mob, target, skill, action)
    local result = super(mob, target, skill, action)

    mob:addStatusEffect(xi.effect.ELEMENTAL_SEAL, { power = 1, duration = 60, origin = mob })

    return result
end)

return m
