-----------------------------------
-- Retribution
-- Staff weapon skill
-- Skill Level: 230
-- Delivers a single-hit attack. Damage varies with TP.
-- In order to obtain Retribution, the quest Blood and Glory must be completed.
-- Despite the appearance of throwing the staff, this is not a long-range Weapon Skill like Mistral Axe.
-- The range only extends the usual 1 yalm beyond meleeing range.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget, Soil Gorget & Aqua Gorget.
-- Aligned with the Shadow Belt, Soil Belt & Aqua Belt.
-- Element: None
-- Modifiers: STR:30%  MND:50%
-- 100%TP    200%TP    300%TP
-- 2.00      2.50      3.00
-- Sanctum custom: Gains up to 20 base damage from current enmity and prevents
-- enmity loss from taking damage for 45/75/105 seconds based on TP.
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params     = {}
    params.numHits   = 1
    params.ftpMod    = { 2.0, 2.5, 3.0 }
    params.atkVaries = { 1.5, 1.5, 1.5 } -- https://w.atwiki.jp/studiogobli/pages/93.html
    params.str_wsc   = 0.3
    params.mnd_wsc   = 0.5

    if target:getObjType() == xi.objType.MOB then
        local totalEnmity = target:getCE(player) + target:getVE(player)

        params.bonusWSmods = math.min(20, math.floor(totalEnmity / 1000))
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
    local duration = 45 + math.floor((tp - 1000) / 100) * 3

    local empowered = xi.wsEffect.applyMod(
        player,
        xi.mod.ENMITY_LOSS_REDUCTION,
        1000,
        duration,
        'Retribution prevents enmity loss when taking damage!'
    )

    if not empowered then
        xi.wsEffect.message(player, 'An empowered effect is already active.')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
