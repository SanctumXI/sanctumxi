-----------------------------------
-- Asuran Fists
-- Hand-to-Hand weapon skill
-- Skill Level: 250
-- Delivers an eightfold attack. params.accuracy varies with TP.
-- In order to obtain Asuran Fists, the quest The Walls of Your Mind must be completed.
-- Due to the 95% params.accuracy cap there is only a 66% chance of all 8 hits landing, so approximately a one third chance of missing some of the hits at the cap.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget, Soil Gorget & Flame Gorget.
-- Aligned with the Shadow Belt, Soil Belt & Flame Belt.
-- Element: None
-- Modifiers: STR:10%  VIT:10%
-- 100%TP    200%TP    300%TP
-- 1.00      1.00      1.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 8
    params.ftpMod = { 1.15, 1.15, 1.15 }
    params.str_wsc = 0.3 params.vit_wsc = 0.2
    params.accVaries = { 30, 45, 60 } -- TODO: verify exact number

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.multiHitfTP = true -- http://wiki.ffo.jp/html/2424.html
        params.str_wsc = 0.15 params.vit_wsc = 0.15
        params.ftpMod = { 1.25, 1.25, 1.25 }
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
    local empoweredConsumed = player:getCharVar('Sanctum_AsuranFistsConsumed') == 1

    player:setCharVar('Sanctum_AsuranFistsConsumed', 0)

    if player:getMainJob() == xi.job.MNK then
        if empoweredConsumed then
            xi.wsEffect.message(player, 'Your empowered Asuran Fists landed all eight hits!')
        elseif xi.wsEffect.set(player, xi.wsEffect.ASURAN_FISTS_HITS, 1, 60) then
            xi.wsEffect.message(player, 'Your next Asuran Fists will land all eight hits!')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end
    elseif player:getMainJob() == xi.job.PUP then
        local duration = 45 + math.floor((tp - 1000) / 100) * 3
        local pet      = player:getPet()

        player:addStatusEffect(xi.effect.GEO_HASTE, { power = 500, duration = duration, origin = player })
        player:addStatusEffect(xi.effect.REGAIN, { power = 5, duration = duration, origin = player })

        if pet then
            pet:addStatusEffect(xi.effect.GEO_HASTE, { power = 500, duration = duration, origin = player })
            pet:addStatusEffect(xi.effect.REGAIN, { power = 5, duration = duration, origin = player })
        end

        xi.wsEffect.message(player, 'Asuran Fists granted Haste and Regain to master and automaton!')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
