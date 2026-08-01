-----------------------------------
-- Raging Fists
-- Hand-to-Hand weapon skill
-- Skill Level: 125
-- Delivers a fivefold attack. Damage varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Thunder Gorget.
-- Aligned with the Thunder Belt.
-- Element: None
-- Modifiers: STR:20%  DEX:20%
-- 100%TP    200%TP    300%TP
-- 1.00       1.5        2
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 5
    params.ftpMod = { 1.1, 1.5, 2.0 }
    params.str_wsc = 0.3 params.dex_wsc = 0.2

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.multiHitfTP = true -- http://wiki.ffo.jp/html/2420.html
        params.ftpMod = { 1.0, 2.1875, 3.75 }
        params.str_wsc = 0.3 params.dex_wsc = 0.3
    end

    local asuranHitCount = 0

    if xi.wsEffect.has(player, xi.wsEffect.ASURAN_FISTS_COMBO) then
        local _, hitCount = xi.wsEffect.peek(player)
        asuranHitCount = hitCount

        local critBonus = asuranHitCount * 0.03
        params.critVaries = { critBonus, critBonus, critBonus }
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if asuranHitCount > 0 then
        xi.wsEffect.consume(player)
        xi.wsEffect.message(player, string.format('Asuran Fists granted +%i%% critical hit rate!', asuranHitCount * 3))
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
