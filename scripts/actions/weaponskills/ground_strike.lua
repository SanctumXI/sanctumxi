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
        params.int_wsc = 0.0
        params.atkVaries = { 1.85, 1.85, 1.85 }
    end

    if player:getMainJob() == xi.job.PLD then
        params.str_wsc = 0.6
        params.vit_wsc = 0.6
        params.atkVaries = { 1.25, 1.25, 1.25 }
    end

    if player:getMainJob() == xi.job.WAR then
        params.str_wsc = 0.7
        params.vit_wsc = 0.3
        params.atkVaries = { 1.75, 1.75, 1.75 }
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    local effect
    local power
    local message

    if player:getMainJob() == xi.job.DRK then
        effect  = xi.wsEffect.GROUND_STRIKE_BASH
        power   = 25
        message = 'Your next Weapon Bash is empowered.'
    elseif player:getMainJob() == xi.job.WAR then
        effect  = xi.wsEffect.GROUND_STRIKE_DA
        power   = 100
        message = 'Your next attack will strike twice.'
    elseif player:getMainJob() == xi.job.PLD then
        effect  = xi.wsEffect.GROUND_STRIKE_HOLY
        power   = 50
        message = 'Your next Holy spell will cost half MP.'
    end

    if effect then
        if xi.wsEffect.set(player, effect, power, 60) then
            xi.wsEffect.message(player, message)
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
