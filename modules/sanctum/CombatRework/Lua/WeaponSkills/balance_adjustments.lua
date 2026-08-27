-----------------------------------
-- Sanctum weapon skill balance adjustments
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskill_balance_adjustments')

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

local physicalAdjustments =
{
    [xi.weaponskill.SHOULDER_TACKLE] = function(params)
        replaceWsc(params, { vit_wsc = 0.4 })
    end,

    [xi.weaponskill.ONE_INCH_PUNCH] = function(params)
        replaceWsc(params, { str_wsc = 0.2 })
        params.ignoredDefense = { 0.25, 0.5, 0.75 }
    end,

    [xi.weaponskill.EXPLODING_PALM] = function(params)
        replaceWsc(params, { str_wsc = 0.5, dex_wsc = 0.3 })
    end,

    [xi.weaponskill.DRAGON_KICK] = function(params)
        params.ftpMod = { 1.5, 2.0, 2.5 }
    end,

    [xi.weaponskill.FINAL_HEAVEN] = function(params)
        replaceWsc(params, { str_wsc = 0.6, mnd_wsc = 0.6 })
        params.ftpMod = { 2.5, 3.0, 3.5 }
    end,

    [xi.weaponskill.STRINGING_PUMMEL] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.3 })
    end,

    [xi.weaponskill.VICTORY_SMITE] = function(params)
        replaceWsc(params, { str_wsc = 0.6 })
        params.ftpMod     = { 2.0, 2.5, 3.0 }
        params.critVaries = { 0.2, 0.4, 0.6 }
    end,

    [xi.weaponskill.FLAT_BLADE] = function(params)
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.CIRCLE_BLADE] = function(params)
        params.ftpMod = { 1.0, 1.5, 2.0 }
    end,

    [xi.weaponskill.SAVAGE_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.4, agi_wsc = 0.4 })
    end,

    [xi.weaponskill.SWIFT_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.5, dex_wsc = 0.5 })
    end,

    [xi.weaponskill.REQUIESCAT] = function(params)
        replaceWsc(params, { str_wsc = 0.2, mnd_wsc = 0.7 })
        params.ftpMod = { 0.9, 1.1, 1.3 }
    end,

    [xi.weaponskill.KNIGHTS_OF_ROUND] = function(params)
        params.atkVaries = { 1.5, 1.5, 1.5 }
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

local magicAdjustments =
{
    [xi.weaponskill.BURNING_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.2, int_wsc = 0.3 })
    end,

    [xi.weaponskill.SHINING_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.2, mnd_wsc = 0.3 })
    end,

    [xi.weaponskill.SERAPH_BLADE] = function(params)
        replaceWsc(params, { str_wsc = 0.3, mnd_wsc = 0.4 })
    end,
}

m:addOverride('xi.weaponskills.doPhysicalWeaponskill', function(player, target, wsID, params, tp, action, primary, taChar)
    local adjustment = physicalAdjustments[wsID]

    if adjustment then
        adjustment(params)
    end

    return super(player, target, wsID, params, tp, action, primary, taChar)
end)

m:addOverride('xi.weaponskills.doMagicWeaponskill', function(player, target, wsID, params, tp, action, primary)
    local adjustment = magicAdjustments[wsID]

    if adjustment then
        adjustment(params)
    end

    return super(player, target, wsID, params, tp, action, primary)
end)

return m
