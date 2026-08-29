-----------------------------------
-- Sanctum general weapon skill adjustments
-----------------------------------
-- The tables here run inside doPhysicalWeaponskill and rewrite params by ID, so they
-- win over the per-weapon files. Change weapon skills here, not in polearm.lua etc.
--
-- ignoredDefense is capped at 0.5. Higher and the weapon skill stops caring what it
-- is hitting, which lets one weapon skill carry a job on high defense targets.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/weaponskills')
-----------------------------------

local m = Module:new('sanctum_general_weaponskills')
local blastArrowUsers = {}
local rangedWeaponskillStats = {}

local wscFields =
{
    'str_wsc',
    'dex_wsc',
    'vit_wsc',
    'agi_wsc',
    'int_wsc',
    'mnd_wsc',
    'chr_wsc',
}

local function replaceWsc(params, modifiers)
    for _, field in ipairs(wscFields) do
        params[field] = nil
    end

    for field, value in pairs(modifiers) do
        params[field] = value
    end
end

local function replaceStrengthModifier(params)
    if params.str_wsc then
        params.dex_wsc = (params.dex_wsc or 0) + params.str_wsc
        params.str_wsc = nil
    end
end

local physicalAdjustments =
{
    [xi.weaponskill.SHOULDER_TACKLE] = function(params)
        replaceWsc(params, { vit_wsc = 0.4 })
    end,

    [xi.weaponskill.ONE_INCH_PUNCH] = function(params)
        replaceWsc(params, { str_wsc = 0.2 })
        params.ignoredDefense = { 0.2, 0.35, 0.5 } -- capped, see header
    end,

    [xi.weaponskill.EXPLODING_PALM] = function(params)
        replaceWsc(params, { str_wsc = 0.5, dex_wsc = 0.3 })
    end,

    [xi.weaponskill.DRAGON_KICK] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.5 })
        params.ftpMod    = { 1.5, 2.0, 2.5 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.FINAL_HEAVEN] = function(params)
        replaceWsc(params, { str_wsc = 0.6, mnd_wsc = 0.6 })
        params.ftpMod    = { 2.45, 3.0, 3.45 }
        params.atkVaries = { 1.3, 1.425, 1.55 }
    end,

    [xi.weaponskill.STRINGING_PUMMEL] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.3 })
    end,

    [xi.weaponskill.VICTORY_SMITE] = function(params)
        replaceWsc(params, { str_wsc = 0.4 })
        params.ftpMod     = { 2.0, 2.5, 3.0 }
        params.critVaries = { 0.2, 0.4, 0.6 }
    end,

    [xi.weaponskill.VIPER_BITE] = function(params)
        replaceWsc(params, { dex_wsc = 0.5 })
        params.ftpMod    = { 1.0, 1.25, 1.5 }
        params.atkVaries = { 1.75, 1.75, 1.75 }
    end,

    [xi.weaponskill.SHADOWSTITCH] = function(params)
        replaceWsc(params, { chr_wsc = 0.5 })
        params.ftpMod = { 1.5, 1.75, 2.0 }
    end,

    [xi.weaponskill.DANCING_EDGE] = function(params)
        params.ftpMod = { 1.0, 1.2, 1.4 }
    end,

    [xi.weaponskill.SHARK_BITE] = function(params)
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.MERCY_STROKE] = function(params)
        params.ftpMod    = { 3.5, 3.75, 4.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.MANDALIC_STAB] = function(params)
        params.ftpMod    = { 3.0, 3.5, 4.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.HARD_SLASH] = function(params)
        params.ftpMod = { 2.0, 2.25, 2.5 }
    end,

    [xi.weaponskill.POWER_SLASH] = function(params)
        params.critVaries = { 0.25, 0.5, 0.75 }
    end,

    [xi.weaponskill.SHOCKWAVE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, mnd_wsc = 0.5 })
        params.ftpMod = { 1.5, 2.0, 2.5 }
    end,

    [xi.weaponskill.CRESCENT_MOON] = function(params)
        params.ftpMod    = { 1.5, 2.0, 2.5 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.SICKLE_MOON] = function(params)
        replaceWsc(params, { str_wsc = 0.2, agi_wsc = 0.4 })
        params.ftpMod = { 2.0, 2.5, 3.0 }
    end,

    [xi.weaponskill.SPINNING_SLASH] = function(params)
        replaceWsc(params, { str_wsc = 0.5 })
        params.ftpMod    = { 2.0, 2.5, 3.0 }
        params.atkVaries = nil
    end,

    [xi.weaponskill.GROUND_STRIKE] = function(params)
        params.atkVaries = { 1.75, 1.75, 1.75 }
    end,

    [xi.weaponskill.SCOURGE] = function(params)
        params.ftpMod    = { 3.0, 3.5, 4.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.TORCLEAVER] = function(params)
        replaceWsc(params, { str_wsc = 0.3, vit_wsc = 0.4 })
        params.ftpMod = { 4.0, 4.5, 5.5 }
    end,

    [xi.weaponskill.SMASH_AXE] = function(params)
        params.ftpMod = { 1.25, 1.5, 1.75 }
    end,

    [xi.weaponskill.GALE_AXE] = function(params)
        replaceWsc(params, { str_wsc = 0.4, int_wsc = 0.2 })
    end,

    [xi.weaponskill.AVALANCHE_AXE] = function(params)
        replaceWsc(params, { str_wsc = 0.4, int_wsc = 0.2 })
    end,

    [xi.weaponskill.SPINNING_AXE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.5 })
    end,

    [xi.weaponskill.CALAMITY] = function(params)
        replaceWsc(params, { str_wsc = 0.4, vit_wsc = 0.4 })
        params.ftpMod    = { 2.0, 2.5, 3.0 }
        params.atkVaries = { 1.25, 1.25, 1.25 }
    end,

    [xi.weaponskill.DECIMATION] = function(params)
        params.ftpMod    = { 1.75, 2.0, 2.5 }
        params.accVaries = { 20, 40, 80 }
    end,

    [xi.weaponskill.ONSLAUGHT] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.3 })
        params.ftpMod    = { 2.75, 3.25, 4.0 }
        params.atkVaries = { 1.25, 1.25, 1.25 }
    end,

    [xi.weaponskill.SHIELD_BREAK] = function(params)
        params.ftpMod = { 1.0, 1.25, 1.5 }
    end,

    [xi.weaponskill.STURMWIND] = function(params)
        params.ftpMod    = { 0.75, 1.0, 1.25 }
        params.atkVaries = nil
    end,

    [xi.weaponskill.ARMOR_BREAK] = function(params)
        params.ftpMod = { 1.0, 1.25, 1.5 }
    end,

    [xi.weaponskill.KEEN_EDGE] = function(params)
        replaceWsc(params, { str_wsc = 0.5 })
    end,

    [xi.weaponskill.WEAPON_BREAK] = function(params)
        params.ftpMod = { 1.0, 1.25, 1.5 }
    end,

    [xi.weaponskill.FULL_BREAK] = function(params)
        params.ftpMod = { 1.5, 1.75, 2.1 }
    end,

    [xi.weaponskill.STEEL_CYCLONE] = function(params)
        replaceWsc(params, { str_wsc = 0.4, vit_wsc = 0.4 })
        params.ftpMod    = { 1.5, 1.75, 2.0 }
        params.atkVaries = { 1.25, 1.5, 1.75 }
    end,

    [xi.weaponskill.METATRON_TORMENT] = function(params)
        params.ftpMod = { 3.5, 4.0, 4.5 }
    end,

    [xi.weaponskill.NIGHTMARE_SCYTHE] = function(params)
        replaceWsc(params, { str_wsc = 0.25, int_wsc = 0.5 })
        params.ftpMod = { 1.25, 1.5, 1.75 }
    end,

    [xi.weaponskill.SPINNING_SCYTHE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, int_wsc = 0.2 })
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.VORPAL_SCYTHE] = function(params)
        replaceWsc(params, { str_wsc = 0.5, int_wsc = 0.2 })
        params.critVaries = { 0.33, 0.66, 1.0 }
    end,

    [xi.weaponskill.GUILLOTINE] = function(params)
        replaceWsc(params, { str_wsc = 0.25, int_wsc = 0.25 })
        params.numHits = 4
        params.ftpMod  = { 1.0, 1.0, 1.0 }
    end,

    [xi.weaponskill.CROSS_REAPER] = function(params)
        replaceWsc(params, { str_wsc = 0.5, int_wsc = 0.3 })
        params.ftpMod = { 2.25, 2.5, 3.0 }
    end,

    [xi.weaponskill.INSURGENCY] = function(params)
        replaceWsc(params, { str_wsc = 0.2, int_wsc = 0.5 })
        params.numHits = 4
        params.ftpMod  = { 1.0, 1.25, 1.5 }
    end,

    [xi.weaponskill.VORPAL_THRUST] = function(params)
        params.ftpMod     = { 1.0, 1.25, 1.5 }
        params.critVaries = { 0.33, 0.66, 1.0 }
    end,

    [xi.weaponskill.WHEELING_THRUST] = function(params)
        params.ftpMod          = { 1.5, 1.75, 2.0 }
        params.ignoredDefense = { 0.2, 0.35, 0.5 } -- capped, see header
    end,

    [xi.weaponskill.IMPULSE_DRIVE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.3 })
        params.ftpMod          = { 2.0, 2.5, 3.0 }
        params.ignoredDefense = nil
    end,

    [xi.weaponskill.GEIRSKOGUL] = function(params)
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.DRAKESBANE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.3 })
        params.atkVaries = nil
    end,

    [xi.weaponskill.STARDIVER] = function(params)
        replaceWsc(params, { str_wsc = 0.8 })
        params.ftpMod = { 0.75, 1.25, 1.5 }
    end,

    [xi.weaponskill.BRAINSHAKER] = function(params)
        params.ftpMod = { 1.0, 1.25, 1.5 }
    end,

    [xi.weaponskill.SKULLBREAKER] = function(params)
        replaceWsc(params, { str_wsc = 0.6 })
    end,

    [xi.weaponskill.TRUE_STRIKE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, mnd_wsc = 0.3 })
        params.ftpMod     = { 1.25, 1.5, 1.75 }
        params.critVaries = { 1.0, 1.0, 1.0 }
        params.atkVaries  = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.JUDGMENT] = function(params)
        replaceWsc(params, { str_wsc = 0.4, mnd_wsc = 0.4 })
        params.ftpMod = { 2.5, 3.0, 3.5 }
    end,

    [xi.weaponskill.HEXA_STRIKE] = function(params)
        replaceWsc(params, { str_wsc = 0.2 })
        params.ftpMod     = { 1.0, 1.0, 1.0 }
        params.critVaries = { 0.1, 0.3, 0.5 }
    end,

    [xi.weaponskill.BLACK_HALO] = function(params)
        replaceWsc(params, { str_wsc = 0.4, int_wsc = 0.5 })
        params.ftpMod = { 1.5, 2.5, 3.0 }
    end,

    [xi.weaponskill.RANDGRITH] = function(params)
        replaceWsc(params, { str_wsc = 0.4, mnd_wsc = 0.4 })
        params.ftpMod    = { 2.75, 3.0, 3.25 }
        params.atkVaries = { 2.0, 2.0, 2.0 }
    end,

    [xi.weaponskill.GATE_OF_TARTARUS] = function(params)
        replaceWsc(params, { int_wsc = 0.6 })
        params.ftpMod = { 3.0, 3.5, 4.0 }
    end,

    [xi.weaponskill.FLAT_BLADE] = function(params)
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.CIRCLE_BLADE] = function(params)
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.SAVAGE_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.4, agi_wsc = 0.4 })
        params.atkVaries = { 1.2, 1.2, 1.2 }
    end,

    [xi.weaponskill.SWIFT_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.5, dex_wsc = 0.5 })
        params.ftpMod = { 1.25, 1.5, 1.75 }
    end,

    [xi.weaponskill.REQUIESCAT] = function(params)
        replaceWsc(params, { str_wsc = 0.2, mnd_wsc = 0.7 })
        params.ftpMod = { 0.9, 1.1, 1.3 }
    end,

    [xi.weaponskill.KNIGHTS_OF_ROUND] = function(params)
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.BLADE_TEKI] = function(params)
        replaceWsc(params, { dex_wsc = 0.3, int_wsc = 0.3 })
    end,

    [xi.weaponskill.BLADE_TO] = function(params)
        replaceWsc(params, { dex_wsc = 0.3, int_wsc = 0.3 })
    end,

    [xi.weaponskill.BLADE_CHI] = function(params)
        replaceWsc(params, { dex_wsc = 0.3, int_wsc = 0.3 })
    end,

    [xi.weaponskill.BLADE_JIN] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.3 })
    end,

    [xi.weaponskill.BLADE_METSU] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.5 })
        params.atkVaries = { 1.25, 1.25, 1.25 }
    end,

    [xi.weaponskill.BLADE_KAMU] = function(params)
        params.ftpMod          = { 1.5, 1.7, 1.8 }
        params.ignoredDefense = { 0.2, 0.3, 0.4 }
    end,

    [xi.weaponskill.TACHI_HOBAKU] = function(params)
        params.ftpMod    = { 1.0, 1.5, 2.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.TACHI_GOTEN] = function(params)
        replaceWsc(params, { str_wsc = 0.3, int_wsc = 0.3 })
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.TACHI_KAGERO] = function(params)
        replaceWsc(params, { str_wsc = 0.5, int_wsc = 0.3 })
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.TACHI_JINPU] = function(params)
        replaceWsc(params, { str_wsc = 0.3, int_wsc = 0.3 })
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.TACHI_KOKI] = function(params)
        replaceWsc(params, { str_wsc = 0.3, mnd_wsc = 0.3 })
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.TACHI_KAITEN] = function(params)
        replaceWsc(params, { str_wsc = 0.6 })
        params.ftpMod    = { 2.5, 3.0, 3.5 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.TACHI_FUDO] = function(params)
        replaceWsc(params, { str_wsc = 0.6 })
        params.ftpMod    = { 3.5, 4.0, 5.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,
}

local rangedAdjustments =
{
    [xi.weaponskill.FLAMING_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.25 })
        params.ftpMod = { 1.0, 1.25, 1.5 }
    end,

    [xi.weaponskill.PIERCING_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.2 })
        params.ftpMod          = { 0.75, 1.0, 1.25 }
        params.ignoredDefense = { 0.2, 0.35, 0.5 } -- capped, see header
    end,

    [xi.weaponskill.DULLING_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.25 })
        params.ftpMod     = { 1.0, 1.25, 1.5 }
        params.critVaries = { 0.1, 0.3, 0.5 }
    end,

    [xi.weaponskill.SIDEWINDER] = function(params)
        replaceWsc(params, { str_wsc = 0.4, dex_wsc = 0.2 })
        params.ftpMod = { 4.0, 4.5, 5.0 }
    end,

    [xi.weaponskill.BLAST_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.3, int_wsc = 0.3 })
        params.numHits   = 1
        params.ftpMod    = { 2.9, 3.45, 4.05 }
        params.accVaries = { 20, 50, 100 }
    end,

    [xi.weaponskill.ARCHING_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.25, agi_wsc = 0.25 })
        params.ftpMod              = { 3.0, 3.5, 4.0 }
        params.critVaries          = { 0.1, 0.3, 0.5 }
        params.rangedAccuracyBonus = 100
    end,

    [xi.weaponskill.EMPYREAL_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.3, agi_wsc = 0.2 })
        params.ftpMod    = { 2.5, 2.75, 3.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.NAMAS_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.4, dex_wsc = 0.4 })
        params.ftpMod    = { 2.0, 2.5, 3.5 }
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.REFULGENT_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.2 })
        params.numHits = 2
        params.ftpMod  = { 3.0, 4.25, 5.0 }
    end,

    [xi.weaponskill.JISHNUS_RADIANCE] = function(params)
        replaceWsc(params, { str_wsc = 0.6 })
        params.ftpMod     = { 1.5, 1.75, 2.0 }
        params.critVaries = { 0.15, 0.3, 0.45 }
    end,

    [xi.weaponskill.HOT_SHOT] = function(params)
        replaceWsc(params, { agi_wsc = 0.2, int_wsc = 0.2 })
    end,

    [xi.weaponskill.SNIPER_SHOT] = function(params)
        params.critVaries     = { 0.25, 0.5, 1.0 }
        params.ignoredDefense = { 0.1, 0.2, 0.3 }
    end,

    [xi.weaponskill.SLUG_SHOT] = function(params)
        params.ftpMod = { 4.5, 5.0, 5.5 }
    end,

    [xi.weaponskill.BLAST_SHOT] = function(params)
        params.ftpMod = { 2.0, 2.5, 3.0 }
    end,

    [xi.weaponskill.HEAVY_SHOT] = function(params)
        params.ftpMod = { 3.0, 3.5, 4.0 }
    end,

    [xi.weaponskill.DETONATOR] = function(params)
        params.rangedAccuracyBonus = nil
    end,

    [xi.weaponskill.CORONACH] = function(params)
        params.ftpMod = { 3.0, 3.5, 4.0 }
    end,
}

local magicAdjustments =
{
    [xi.weaponskill.GUST_SLASH] = function(params)
        replaceWsc(params, { dex_wsc = 0.2, int_wsc = 0.3 })
    end,

    [xi.weaponskill.CYCLONE] = function(params)
        replaceWsc(params, { dex_wsc = 0.3, int_wsc = 0.4 })
    end,

    [xi.weaponskill.AEOLIAN_EDGE] = function(params)
        replaceWsc(params, { dex_wsc = 0.3, int_wsc = 0.3 })
    end,

    [xi.weaponskill.FROSTBITE] = function(params)
        params.ftpMod = { 1.5, 2.0, 2.5 }
    end,

    [xi.weaponskill.FREEZEBITE] = function(params)
        replaceWsc(params, { int_wsc = 0.6 })
        params.ftpMod = { 1.5, 2.0, 2.5 }
    end,

    [xi.weaponskill.HERCULEAN_SLASH] = function(params)
        replaceWsc(params, { vit_wsc = 1.0 })
        params.ftpMod = { 3.0, 3.3, 3.6 }
    end,

    [xi.weaponskill.BLADE_EI] = function(params)
        replaceWsc(params, { str_wsc = 0.3, int_wsc = 0.6 })
    end,

    [xi.weaponskill.EARTH_CRUSHER] = function(params)
        params.ftpMod = { 1.95, 2.6, 3.25 }
    end,

    [xi.weaponskill.VIDOHUNIR] = function(params)
        replaceWsc(params, { int_wsc = 0.5 })
        params.ftpMod = { 2.0, 2.5, 3.0 }
    end,

    [xi.weaponskill.GARLAND_OF_BLISS] = function(params)
        replaceWsc(params, { int_wsc = 0.5, mnd_wsc = 0.5 })
        params.ftpMod = { 2.5, 3.0, 3.5 }
    end,

    [xi.weaponskill.OMNISCIENCE] = function(params)
        replaceWsc(params, { int_wsc = 0.5, mnd_wsc = 0.5 })
        params.ftpMod = { 2.5, 3.0, 3.5 }
    end,

    [xi.weaponskill.BURNING_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.2, int_wsc = 0.3 })
    end,

    [xi.weaponskill.SHINING_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.2, mnd_wsc = 0.3 })
    end,

    [xi.weaponskill.SERAPH_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, mnd_wsc = 0.4 })
    end,

    -- Magical WS do not use atkVaries, so their intended damage increase is
    -- expressed through their native fTP curves instead.
    [xi.weaponskill.TRUEFLIGHT] = function(params)
        replaceWsc(params, { agi_wsc = 0.3, mnd_wsc = 0.3 })
        params.ftpMod = { 4.6, 4.9, 5.5 }
    end,

    [xi.weaponskill.LEADEN_SALUTE] = function(params)
        replaceWsc(params, { agi_wsc = 0.3, int_wsc = 0.3 })
        params.ftpMod = { 4.6, 4.9, 5.5 }
    end,
}

m:addOverride('xi.combat.physical.calculateRangedStatFactor', function(actor, target)
    if actor:isMob() or actor:isPet() then
        return super(actor, target)
    end

    local weaponRank = actor:getRangedDmgRank()
    local stat       = rangedWeaponskillStats[actor:getID()] or xi.mod.DEX
    local statDiff   = actor:getStat(stat) - target:getStat(xi.mod.VIT)

    statDiff = utils.clamp(statDiff, (7 + weaponRank * 2) * -2, (14 + weaponRank * 2) * 2)

    local statFactor = 0
    if statDiff >= 12 then
        statFactor = statDiff + 4
    elseif statDiff >= 6 then
        statFactor = statDiff + 6
    elseif statDiff >= 1 then
        statFactor = statDiff + 7
    elseif statDiff >= -2 then
        statFactor = statDiff + 8
    elseif statDiff >= -7 then
        statFactor = statDiff + 9
    elseif statDiff >= -15 then
        statFactor = statDiff + 10
    elseif statDiff >= -21 then
        statFactor = statDiff + 12
    else
        statFactor = statDiff + 13
    end

    local lowerCap = weaponRank * -2
    if weaponRank == 0 then
        lowerCap = -2
    elseif weaponRank == 1 then
        lowerCap = -3
    end

    return utils.clamp(statFactor / 2, lowerCap, (weaponRank + 8) * 2)
end)

m:addOverride('xi.combat.ranged.attackDistancePenalty', function(attacker, defender)
    if blastArrowUsers[attacker:getID()] then
        return 0
    end

    return super(attacker, defender)
end)

m:addOverride('xi.combat.ranged.accuracyDistancePenalty', function(attacker, defender)
    if blastArrowUsers[attacker:getID()] then
        return 0
    end

    return super(attacker, defender)
end)

m:addOverride('xi.weaponskills.doPhysicalWeaponskill', function(player, target, wsID, params, tp, action, primary, taChar)
    local adjustment = physicalAdjustments[wsID]

    if adjustment then
        adjustment(params)
    end

    return super(player, target, wsID, params, tp, action, primary, taChar)
end)

m:addOverride('xi.weaponskills.doRangedWeaponskill', function(attacker, target, wsID, params, tp, action, primary)
    local adjustment = rangedAdjustments[wsID]

    if adjustment then
        adjustment(params)
    end

    local skill = attacker:getWeaponSkillType(xi.slot.RANGED)

    if skill == xi.skill.MARKSMANSHIP then
        replaceStrengthModifier(params)
    end

    -- Scope WS-only stat selection and Blast Arrow's range exemption to this
    -- actor, including nested calls and error unwinding.
    local actorId      = attacker:getID()
    local previousStat = rangedWeaponskillStats[actorId]
    local previousBlast = blastArrowUsers[actorId]
    rangedWeaponskillStats[actorId] = skill == xi.skill.ARCHERY and xi.mod.STR or xi.mod.DEX
    blastArrowUsers[actorId] = wsID == xi.weaponskill.BLAST_ARROW and true or nil

    local ok, damage, critical, tpHits, extraHits, shadows = pcall(super, attacker, target, wsID, params, tp, action, primary)
    rangedWeaponskillStats[actorId] = previousStat
    blastArrowUsers[actorId] = previousBlast

    if not ok then
        error(damage, 0)
    end

    return damage, critical, tpHits, extraHits, shadows
end)

m:addOverride('xi.weaponskills.doMagicWeaponskill', function(player, target, wsID, params, tp, action, primary)
    local adjustment = magicAdjustments[wsID]

    if adjustment then
        adjustment(params)
    end

    if params.skill == xi.skill.MARKSMANSHIP then
        replaceStrengthModifier(params)
    end

    return super(player, target, wsID, params, tp, action, primary)
end)

return m
