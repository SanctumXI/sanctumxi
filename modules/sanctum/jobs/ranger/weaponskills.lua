-----------------------------------
-- Sanctum ranged weapon skills
-----------------------------------
require('modules/module_utils')
require('scripts/globals/weaponskills')
-----------------------------------

local m = Module:new('sanctum_ranger_weaponskills')
local blastArrowUsers = {}

local function replaceStrengthModifier(params)
    if params.str_wsc then
        params.dex_wsc = (params.dex_wsc or 0) + params.str_wsc
        params.str_wsc = nil
    end
end

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
    replaceStrengthModifier(params)

    if wsID == xi.weaponskill.ARCHING_ARROW then
        params.critVaries = { 0.1, 0.3, 0.5 }
    elseif wsID == xi.weaponskill.SNIPER_SHOT then
        params.critVaries = { 0.25, 0.5, 0.75 }
    end

    if wsID ~= xi.weaponskill.BLAST_ARROW then
        return super(attacker, target, wsID, params, tp, action, primary)
    end

    params.ftpMod = { 2.3, 2.3, 2.3 }

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
    if
        params.skill == xi.skill.ARCHERY or
        params.skill == xi.skill.MARKSMANSHIP
    then
        replaceStrengthModifier(params)
    end

    return super(attacker, target, wsID, params, tp, action, primary)
end)

return m
