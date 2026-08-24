-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: marksmanship
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_marksmanship')

-----------------------------------
-- Source: scripts/actions/weaponskills/blast_shot.lua
-----------------------------------
do
    -----------------------------------
    -- Blast Shot
    -- Marksmanship weapon skill
    -- Skill Level: 200
    -- Delivers a melee-distance ranged attack. params.accuracy varies with TP.
    -- Aligned with the Snow Gorget & Light Gorget.
    -- Aligned with the Snow Belt & Light Belt.
    -- Element: None
    -- Modifiers: AGI:30%
    -- 100%TP    200%TP    300%TP
    -- 2.00      2.00      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blast_shot.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.0, 2.0, 2.0 }
        params.agi_wsc = 0.3
        params.accVaries = { 0, 30, 60 } -- TODO: verify exact number

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.agi_wsc = 0.7
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if xi.wsEffect.set(player, xi.wsEffect.BLAST_SHOT_ACC, 1, 60) then
            xi.wsEffect.message(player, 'Your next Marksmanship weaponskill cannot miss!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/detonator.lua
-----------------------------------
do
    -----------------------------------
    -- Detonator
    -- Marksmanship weapon skill
    -- Skill Level: 250
    -- Delivers a single-hit attack. Damage varies with TP.
    -- In order to obtain Detonator, the quest Shoot First, Ask Questions Later must be completed.
    -- Despite the lack of a STR weaponskill mod, STR is still the most potent stat for increasing this weaponskill's damage to the point at which fSTR2 is capped.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: AGI:30%
    -- Corsair main job: Magic Attack Bonus increases damage by 1% per point.
    -- 100%TP    200%TP    300%TP
    -- 1.50      2.00      2.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.detonator.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params               = {}
        params.numHits             = 1
        params.ftpMod              = { 1.5, 2.0, 2.5 }
        params.atkVaries           = { 2.0, 2.0, 2.0 } -- https://w.atwiki.jp/studiogobli/pages/93.html
        params.agi_wsc             = 0.3
        params.rangedAccuracyBonus = 100 -- https://www.ffxiah.com/forum/topic/52018/luck-of-the-draw-a-corsairs-guide-new/127/#3726841

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod  = { 1.5, 2.5, 5.0 }
            params.agi_wsc = 0.7
        end

        if player:getMainJob() == xi.job.COR then
            params.damageMultiplier = math.max(0, 1 + player:getMod(xi.mod.MATT) / 100)
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if player:getMainJob() == xi.job.COR then
            if xi.wsEffect.set(player, xi.wsEffect.DETONATOR_QUICK_DRAW, 50, 60) then
                xi.wsEffect.message(player, 'Your next Quick Draw will deal 50% more damage!')
            end
        elseif xi.wsEffect.set(player, xi.wsEffect.DETONATOR_BARRAGE, 1, 60) then
            player:addMod(xi.mod.BARRAGE_COUNT, 1)
            xi.wsEffect.message(player, 'Your next Barrage will fire one additional shot!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/hot_shot.lua
-----------------------------------
do
    -----------------------------------
    -- Hot Shot
    -- Marksmanship weapon skill
    -- Skill Level: 5
    -- Deals fire elemental damage to enemy.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: Fire
    -- Modifiers: AGI:30%
    -- 100%TP    200%TP    300%TP
    -- 0.50      0.75      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.hot_shot.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 0.5, 0.75, 1.0 }
        params.agi_wsc = 0.3
        params.hybridWS = true
        params.ele = xi.element.FIRE
        params.skill = xi.skill.MARKSMANSHIP
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 0.5, 1.55, 2.1 }
            params.agi_wsc = 0.7
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            local marksmanshipSkill = player:getSkillLevel(xi.skill.MARKSMANSHIP)
            local burnPower         = math.min(15, 3 + math.floor(marksmanshipSkill / 20))

            target:addStatusEffect(xi.effect.BURN, { power = burnPower, duration = 30, origin = player })
            player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/sniper_shot.lua
-----------------------------------
do
    -----------------------------------
    -- Sniper Shot
    -- Marksmanship weapon skill
    -- Skill Level: 80
    -- Lowers enemy's INT. Chance of params.critical varies with TP.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: AGI:70%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.sniper_shot.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.agi_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.agi_wsc = 0.7
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.EVASION_DOWN, { power = 10, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/split_shot.lua
-----------------------------------
do
    -----------------------------------
    -- Split Shot
    -- Marksmanship weapon skill
    -- Skill Level: 40
    -- Ignores enemy's defense. Amount ignored varies with TP.
    -- The amount of defense ignored is 0% @ 100TP, 35% @ 200TP and 50% @ 300TP.
    -- Aligned with the Aqua Gorget & Light Gorget.
    -- Aligned with the Aqua Belt & Light Belt.
    -- Element: None
    -- Modifiers: AGI:70%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.split_shot.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params               = {}
        params.numHits             = 1
        params.ftpMod              = { 1.0, 1.0, 1.0 }
        params.str_wsc             = 0.4
        params.rangedAccuracyBonus = 100 -- https://www.ffxiah.com/forum/topic/52018/luck-of-the-draw-a-corsairs-guide-new/127/#3726841

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.agi_wsc = 0.7
        end

        -- Defense ignored is 0%, 35%, 50% as per wiki.bluegartr.com
        params.ignoredDefense = { 0.0, 0.35, 0.5 }

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.DEFENSE_DOWN, { power = 5, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
