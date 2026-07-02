-----------------------------------
-- Spell: Blitzstrahl
-- Deals lightning damage to an enemy.
-- Spell cost: 52 MP
-- Monster Type: Arcana
-- Spell Type: Magical (Lightning)
-- Blue Magic Points: 4
-- Stat Bonus: DEX+3
-- Level: 44
-- Casting Time: 1.5 seconds
-- Recast Time: 6 seconds
-- Magic Bursts on: Impaction, Fragmentation, Light
-- Combos: None
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local params = {}
    params.ecosystem   = xi.ecosystem.ARCANA
    params.attackType  = xi.damageType.ELEMENTAL
    params.damageType  = xi.damageType.THUNDER
    params.attribute   = xi.mod.INT
    params.multiplier  = 1.5625
    params.tMultiplier = 1.0
    params.duppercap   = 61
    params.str_wsc     = 0.0
    params.dex_wsc     = 0.15
    params.vit_wsc     = 0.0
    params.agi_wsc     = 0.0
    params.int_wsc     = 0.4
    params.mnd_wsc     = 0.0
    params.chr_wsc     = 0.0

    -- Handle damage.
    local damage = xi.spells.blue.useMagicalSpell(caster, target, spell, params)

    return damage
end

return spellObject
