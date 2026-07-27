-----------------------------------
-- Savage Blade
-- Sword weapon skill
-- Skill Level: 240
-- Delivers an aerial attack comprised of two hits. Damage varies with TP.
-- In order to obtain Savage Blade, the quest Old Wounds must be completed.
-- Will stack with Sneak Attack.
-- Aligned with the Breeze Gorget, Thunder Gorget & Soil Gorget
-- Aligned with the Breeze Belt, Thunder Belt & Soil Belt.
-- Element: None
-- Modifiers: STR:50%  MND:50%
-- 100%TP    200%TP    300%TP
-- 4.00      10.25      13.75
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
       local params = {}
    params.numHits = 2
    params.ftpMod = { 1.75, 2.25, 3.0 }
    params.str_wsc = 0.4
    params.mnd_wsc = 0.4

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 4.0, 10.25, 13.75 }
        params.str_wsc = 0.5
    end

    if player:getMainJob() == xi.job.PLD then
        params.vit_wsc = 0.6
        params.str_wsc = 0.3
        params.mnd_wsc = 0.0
        params.bonusWSmods = math.floor(player:getStat(xi.mod.DEF) / 10)
    end

    local damage, criticalHit, tpHits, extraHits =
        xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        local duration = 45 + math.floor((tp - 1000) / 100) * 3

        if xi.wsEffect.set(player, xi.wsEffect.SAVAGE_BLADE_DAMAGE, 15, duration) then
            xi.wsEffect.message(player, 'Damage increased by 15%, and enmity generation is increased by 25%!')
        end
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
