-----------------------------------
-- Avalanche Axe
-- Axe weapon skill
-- Skill level: 100
-- Delivers a single-hit attack. Damage varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Soil Gorget & Thunder Gorget.
-- Aligned with the Soil Belt & Thunder Belt.
-- Element: None
-- Modifiers: STR:30%
-- 100%TP    200%TP    300%TP
-- 1.50      2.00      2.50
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

local effectPowerVar = 'Sanctum_AvalancheAxeCritPower'
local effectTokenVar = 'Sanctum_AvalancheAxeCritToken'

local function applyCritRateDown(target)
    local power    = 5
    local oldPower = target:getLocalVar(effectPowerVar)
    local token    = target:getLocalVar(effectTokenVar) + 1

    if oldPower ~= 0 then
        target:delMod(xi.mod.CRITHITRATE, -oldPower)
    end

    target:addMod(xi.mod.CRITHITRATE, -power)
    target:setLocalVar(effectPowerVar, power)
    target:setLocalVar(effectTokenVar, token)

    target:timer(45000, function(targetArg)
        if targetArg and targetArg:getLocalVar(effectTokenVar) == token then
            targetArg:delMod(xi.mod.CRITHITRATE, -power)
            targetArg:setLocalVar(effectPowerVar, 0)
            targetArg:setLocalVar(effectTokenVar, 0)
        end
    end)
end

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 1
    params.ftpMod = { 1.5, 2, 2.5 }
    params.str_wsc = 0.35

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 0.6
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        applyCritRateDown(target)
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
