-----------------------------------
-- Spell: Eyes On Me
-- Deals dark damage to an enemy
-- Spell cost: 112 MP
-- Monster Type: Demons
-- Spell Type: Magical (Dark)
-- Blue Magic Points: 4
-- Stat Bonus: CHR+2
-- Level: 61
-- Casting Time: 4.5 seconds
-- Recast Time: 29.25 seconds
-- Magic Bursts on: Compression, Gravitation, Darkness
-- Combos: Magic Attack Bonus
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local params = {}
    params.ecosystem = xi.ecosystem.DEMON
    params.attackType = xi.attackType.MAGICAL
    params.damageType = xi.damageType.DARK
    params.attribute = xi.mod.CHR
    params.multiplier = 2.625
    params.azureBonus = 2
    params.tMultiplier = 1.5
    params.duppercap = 69
    params.str_wsc = 0.0
    params.dex_wsc = 0.0
    params.vit_wsc = 0.0
    params.agi_wsc = 0.0
    params.int_wsc = 0.0
    params.mnd_wsc = 0.0
    params.chr_wsc = 0.4

    local damage = xi.spells.blue.useMagicalSpell(caster, target, spell, params)
    if target:isAlive() then
        target:addEnmity(caster, 1, 1800)
        target:updateTarget()
    end

    return damage
end

return spellObject
