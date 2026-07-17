-----------------------------------
-- Spell: Screwdriver
-- Deals piercing physical damage. With Chain Affinity, critical hit chance varies with TP.
-- Monster Type: Aquan
-- Spell Type: Physical (Piercing)
-- Skillchain property: Transfixion / Scission
-- Spell cost: 21 MP
-- Blue Magic Points: 3
-- Level: 26
-- Casting Time: 0.5 seconds
-- Recast Time: 14 seconds
-- Stat Bonus: HP+10, VIT+1, AGI+2
-- Combos: Evasion Bonus
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local params = {}

    params.ecosystem = xi.ecosystem.AQUAN
    params.tpmod     = xi.spells.blue.tpMod.CRITICAL

    params.attackType = xi.attackType.PHYSICAL
    params.damageType = xi.damageType.PIERCING
    params.scattr     = xi.skillchainType.TRANSFIXION
    params.scattr2    = xi.skillchainType.SCISSION

    params.numhits    = 1
    params.multiplier = 1.375
    params.tp150      = 1.375
    params.tp300      = 1.375
    params.azuretp    = 1.375
    params.duppercap  = 27

    params.str_wsc = 0.2
    params.dex_wsc = 0.0
    params.vit_wsc = 0.0
    params.agi_wsc = 0.2
    params.int_wsc = 0.0
    params.mnd_wsc = 0.0
    params.chr_wsc = 0.0

    return xi.spells.blue.usePhysicalSpell(caster, target, spell, params)
end

return spellObject
