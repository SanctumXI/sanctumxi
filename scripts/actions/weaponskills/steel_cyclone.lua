-----------------------------------
-- Steel Cyclone
-- Great Axe weapon skill
-- Skill level: 240
-- Delivers a single-hit attack. Damage varies with TP.
-- In order to obtain Steel Cyclone, the quest The Weight of Your Limits must be completed.
-- Will stack with Sneak Attack.
-- Aligned with the Breeze Gorget, Aqua Gorget & Snow Gorget.
-- Aligned with the Breeze Belt, Aqua Belt & Snow Belt.
-- Element: None
-- Modifiers: STR:60%  VIT:60%
-- 100%TP    200%TP    300%TP
-- 1.50       2.5       4.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 1
    params.ftpMod = { 1.75, 2.0, 2.5 }
    params.str_wsc = 0.6 params.vit_wsc = 0.6
    params.atkVaries = { 1.66, 1.66, 1.66 }

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 1.5, 2.5, 4.0 }
        params.str_wsc = 0.6 params.vit_wsc = 0.6
        params.atkVaries = { 1.5, 1.5, 1.5 }
    end

    if player:getMainJob() == xi.job.WAR then
        params.vit_wsc = 0.7
        params.str_wsc = 0.7
        params.atkVaries = { 1.75, 1.75, 1.75 }
        params.bonusWSmods = math.floor(player:getStat(xi.mod.DEF) / 15)
    end

    if player:getMainJob() == xi.job.DRK then
        params.vit_wsc = 0.3
        params.int_wsc = 0.8
        params.str_wsc = 0.0
        params.bonusWSmods = math.floor(player:getStat(xi.mod.ATT) / 15)
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if player:getMainJob() == xi.job.WAR then
    player:addStatusEffect(xi.effect.DEFENSE_BOOST, { power = 30, duration = 45, origin = player })
    if player:getMainJob() == xi.job.DRK then
    player:addStatusEffect(xi.effect.ATTACK_BOOST, { power = 20, duration = 45, origin = player })
    end

    return tpHits, extraHits, criticalHit, damage

end

return weaponskillObject
