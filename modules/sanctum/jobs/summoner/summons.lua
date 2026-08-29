-----------------------------------
-- Sanctum summon availability and Light Spirit levels
-----------------------------------
require('modules/module_utils')
require('scripts/globals/pets')
require('scripts/globals/pets/avatar')
-----------------------------------

local m = Module:new('sanctum_summoner_summons')

m:addOverride('xi.pets.avatar.onMobSpawn', function(pet)
    super(pet)

    local master = pet:getMaster()
    if master and master:isPC() and pet:getPetID() <= xi.petId.DARK_SPIRIT then
        master:setMod(xi.mod.AVATAR_PERPETUATION, math.min(master:getMod(xi.mod.AVATAR_PERPETUATION), 2))
    end
end)

local blockedSpells =
{
    [xi.magic.spell.ALEXANDER] = true,
    [xi.magic.spell.ATOMOS] = true,
}

m:addOverride('xi.pet.onCastingCheck', function(caster, target, spell)
    if caster:isPC() and blockedSpells[spell:getID()] then
        return xi.msg.basic.MAGIC_CANNOT_CAST
    end

    return super(caster, target, spell)
end)

m:addOverride('xi.pet.spawnPet', function(caster, petID, state, target)
    if
        caster:isPC() and
        (petID == xi.petId.ALEXANDER or petID == xi.petId.ATOMOS)
    then
        return
    end

    return super(caster, petID, state, target)
end)

for _, name in ipairs({ 'perfect_defense', 'deconstruction', 'chronoshift' }) do
    m:addOverride('xi.actions.abilities.pets.' .. name .. '.onAbilityCheck', function(player, target, ability)
        return xi.msg.basic.UNABLE_TO_USE_JA2, 0
    end)

    m:addOverride('xi.actions.abilities.pets.' .. name .. '.onPetAbility', function(target, pet, skill, master, action)
        if master and master:isPC() then
            skill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
            return 0
        end

        return super(target, pet, skill, master, action)
    end)
end

local lightSpiritLevels =
{
    [xi.magic.spell.HASTE] = 48,
    [xi.magic.spell.PROTECT_IV] = 63,
    [xi.magic.spell.SHELL] = 10,
}

for _, spells in pairs(xi.pets.avatar.lightSpiritBuffs) do
    for _, entry in ipairs(spells) do
        if lightSpiritLevels[entry.spell] then
            entry.level = lightSpiritLevels[entry.spell]
        end
    end
end

return m
