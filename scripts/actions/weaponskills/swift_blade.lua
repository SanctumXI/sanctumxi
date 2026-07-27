-----------------------------------
-- Swift Blade
-- Sword weapon skill
-- Skill Level: 225
-- Delivers a three-hit attack. params.accuracy varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget & Soil Gorget.
-- Aligned with the Shadow Belt & Soil Belt.
-- Element: None
-- Modifiers: STR:50%  MND:50%
-- 100%TP    200%TP    300%TP
-- 1.50      1.50      1.50
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 3
    params.ftpMod = { 1.5, 1.7, 1.9 }
    params.vit_wsc = 0.5
    params.mnd_wsc = 0.4
    -- Sufficient data for ACC bonus/penalty does not exist; assuming no penalty and 10% increase per 1000 TP
    -- http://wiki.ffo.jp/html/382.html does not list ACC Bonus
    -- https://www.bg-wiki.com/ffxi/Swift_Blade does not list ACC Bonus
    params.accVaries = { 15, 30, 60 } -- TODO: verify exact number

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 0.5 params.mnd_wsc = 0.5
        params.multiHitfTP = true
    end

        -- Sanctum Custom: PLD-enhanced Swift Blade
    -- if player:getMainJob() == xi.job.PLD then
    --    params.vit_wsc = 0.7
    --    params.str_wsc = 0.3
    -- end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 and xi.wsEffect.set(player, xi.wsEffect.SWIFT_BLADE_CRIT, 15, 60) then
        xi.wsEffect.message(player, 'Your next Sword weaponskill gains +15% critical hit rate!')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
