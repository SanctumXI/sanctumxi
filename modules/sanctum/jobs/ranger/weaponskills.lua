-----------------------------------
-- Sanctum ranged weapon skills
-----------------------------------
require('modules/module_utils')
require('scripts/globals/weaponskills')
-----------------------------------

local m = Module:new('sanctum_ranger_weaponskills')
local blastArrowUsers = {}

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

local rangedAdjustments =
{
    [xi.weaponskill.FLAMING_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.3, dex_wsc = 0.25 })
        params.ftpMod = { 1.0, 1.25, 1.5 }
    end,

    [xi.weaponskill.PIERCING_ARROW] = function(params)
        replaceWsc(params, { str_wsc = 0.2 })
        params.ftpMod          = { 0.75, 1.0, 1.25 }
        params.ignoredDefense = { 0.25, 0.5, 0.75 }
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
        params.ftpMod    = { 2.3, 2.5, 2.7 }
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
    [xi.weaponskill.TRUEFLIGHT] = function(params)
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,

    [xi.weaponskill.LEADEN_SALUTE] = function(params)
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end,
}

m:addOverride('xi.combat.physical.calculateRangedStatFactor', function(actor, target)
    if actor:isMob() or actor:isPet() then
        return super(actor, target)
    end

    local weaponRank = actor:getRangedDmgRank()
    local statDiff   = actor:getStat(xi.mod.DEX) - target:getStat(xi.mod.VIT)

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

m:addOverride('xi.weaponskills.doRangedWeaponskill', function(attacker, target, wsID, params, tp, action, primary)
    local adjustment = rangedAdjustments[wsID]

    if adjustment then
        adjustment(params)
    end

    if attacker:getWeaponSkillType(xi.slot.RANGED) == xi.skill.MARKSMANSHIP then
        replaceStrengthModifier(params)
    end

    if wsID ~= xi.weaponskill.BLAST_ARROW then
        return super(attacker, target, wsID, params, tp, action, primary)
    end

    -- Exempt only this actor's active Blast Arrow, including error unwinding.
    local actorId  = attacker:getID()
    local previous = blastArrowUsers[actorId]
    blastArrowUsers[actorId] = true

    local ok, damage, critical, tpHits, extraHits, shadows = pcall(super, attacker, target, wsID, params, tp, action, primary)
    blastArrowUsers[actorId] = previous

    if not ok then
        error(damage, 0)
    end

    return damage, critical, tpHits, extraHits, shadows
end)

m:addOverride('xi.weaponskills.doMagicWeaponskill', function(attacker, target, wsID, params, tp, action, primary)
    local adjustment = magicAdjustments[wsID]

    if adjustment then
        adjustment(params)
    end

    if params.skill == xi.skill.MARKSMANSHIP then
        replaceStrengthModifier(params)
    end

    return super(attacker, target, wsID, params, tp, action, primary)
end)

return m
