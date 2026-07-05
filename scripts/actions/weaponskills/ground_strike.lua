-----------------------------------
-- Ground Strike
-- Great Sword weapon skill
-- Skill level: 250 QUESTED
-- Delivers a single-hit attack. Damage varies with TP.
-- Modifiers: STR:50% INT:50%
-- 100%TP     200%TP     300%TP
-- 1.5         1.75    3.0
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 1
    params.ftpMod = { 1.75, 2.25, 2.50 }
    params.str_wsc = 0.5
    params.int_wsc = 0.2
    params.atkVaries = { 1.75, 1.75, 1.75 }

    if player:getMainJob() == xi.job.DRK then
        params.str_wsc = 1.0
        params.atkVaries = { 2.0, 2.0, 2.0 }
    end

    if player:getMainJob() == xi.job.PLD then
        params.str_wsc = 0.6
        params.vit_wsc = 0.6
        params.atkVaries = { 1.75, 1.75, 1.75 }
    end
    
    if player:getMainJob() == xi.job.WAR then
        params.str_wsc = 0.8
        params.atkVaries = { 2.00, 2.00, 2.00 }
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)


    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
