-----------------------------------
-- Spell: Hydro Shot
-- Additional effect: Enmity Down.
-- Spell cost: 60 MP
-- Monster Type: Beastmen
-- Spell Type: Physical (Blunt)
-- Blue Magic Points: 3
-- Stat Bonus: MND+2
-- Level: 63
-- Casting Time: 2 seconds
-- Recast Time: 26 seconds
-- Skillchain Element(s): Reverberation
-- Combos: Rapid Shot
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local params = {}
    params.ecosystem = xi.ecosystem.BEASTMEN
    params.tpmod = xi.spells.blue.tpMod.EFFECT_CHANCE
    params.attackType = xi.attackType.MAGICAL
    params.damageType = xi.damageType.WATER
    params.scattr = xi.skillchainType.REVERBERATION
    params.numhits = 1
    params.multiplier = 1.25
    params.tp150 = 1.25
    params.tp300 = 1.25
    params.azuretp = 1.25
    params.duppercap = 75
    params.str_wsc = 0.0
    params.dex_wsc = 0.0
    params.vit_wsc = 0.0
    params.agi_wsc = 0.3
    params.int_wsc = 0.0
    params.mnd_wsc = 0.0
    params.chr_wsc = 0.0

    local damage = xi.spells.blue.usePhysicalSpell(caster, target, spell, params)

    -- Lowers the user's current hate on this target by 25%.
    if damage > 0 and target:isAlive() then
        target:lowerEnmity(caster, 25)
        target:updateTarget()
    end

    return damage
end

return spellObject
