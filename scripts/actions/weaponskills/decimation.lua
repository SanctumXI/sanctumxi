-----------------------------------
-- Decimation
-- Axe weapon skill
-- Skill level: 240
-- In order to obtain Decimation, the quest Axe the Competition must be completed.
-- Delivers a three-hit attack. params.accuracy varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Flame Gorget, Light Gorget & Aqua Gorget.
-- Aligned with the Flame Belt, Light Belt & Aqua Belt.
-- Element: None
-- Modifiers: STR:50%
-- 100%TP    200%TP    300%TP
-- 1.25      1.25      1.25
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 3
    params.ftpMod = { 1.25, 1.25, 1.25 }
    params.str_wsc = 0.5
    params.accVaries = { 0, 30, 60 } -- TODO: verify exact number

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 1.75, 1.75, 1.75 }
        params.multiHitfTP = true
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    local duration = 45 + math.floor((tp - 1000) / 100) * 3
    if not xi.wsEffect.applyMod(player, xi.mod.DOUBLE_ATTACK, 5, duration, 'Decimation increased your double attack rate!') then
        xi.wsEffect.message(player, 'An empowered effect is already active.')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
