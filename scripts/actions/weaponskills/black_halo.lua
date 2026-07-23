-----------------------------------
-- Black Halo
-- Club weapon skill
-- Skill level: 230
-- In order to obtain Black Halo, the quest Orastery Woes must be completed.
-- Delivers a two-hit attack. Damage varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget, Thunder Gorget & Breeze Gorget.
-- Aligned with the Shadow Belt, Thunder Belt & Breeze Belt.
-- Element: None
-- Modifiers: STR:30%  MND:50%
-- 100%TP    200%TP    300%TP
-- 1.50      2.50      3.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 2
    params.ftpMod = { 1.5, 2.5, 3 }
    params.str_wsc = 0.4
    params.mnd_wsc = 0.5

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 3.0, 7.25, 9.75 }
        params.mnd_wsc = 0.7
    end

    if player:getMainJob() == xi.job.PLD then
        params.vit_wsc = 0.5
        params.str_wsc = 0.0
        params.mnd_wsc = 0.5
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        target:addStatusEffect(xi.effect.MAGIC_EVASION_DOWN, { power = 10, duration = 45, origin = player })
    end

    if player:getMainJob() == xi.job.PLD then
        if xi.wsEffect.set(player, xi.wsEffect.BLACK_HALO_BASH, 25, 60) then
            xi.wsEffect.message(player, 'Your next Shield Bash is empowered.')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
