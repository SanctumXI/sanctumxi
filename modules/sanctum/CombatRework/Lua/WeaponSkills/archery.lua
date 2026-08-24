-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: archery
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_archery')

-----------------------------------
-- Source: scripts/actions/weaponskills/arching_arrow.lua
-----------------------------------
do
    -----------------------------------
    -- Arching Arrow
    -- Archery weapon skill
    -- Skill level: 225
    -- Delivers a single-hit attack. Chance of params.critical varies with TP.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:16%  AGI:25%
    -- 100%TP    200%TP    300%TP
    -- 3.50      3.50      3.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.arching_arrow.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 3.5, 3.5, 3.5 }
        params.str_wsc = 0.25 params.agi_wsc = 0.25
        params.rangedAccuracyBonus = 100

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.20 params.agi_wsc = 0.50
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blast_arrow.lua
-----------------------------------
do
    -----------------------------------
    -- Blast Arrow
    -- Archery weapon skill
    -- Skill level: 200
    -- Delivers a melee-distance ranged attack. params.accuracy varies with TP.
    -- Aligned with the Snow Gorget & Light Gorget.
    -- Aligned with the Snow Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:16%  AGI:25%
    -- 100%TP    200%TP    300%TP
    -- 2.00      2.00      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blast_arrow.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 2.0, 2.0, 2.0 }
        params.str_wsc = 0.25 params.agi_wsc = 0.25
        params.accVaries = { 15, 30, 60 } -- TODO: verify exact number

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.2 params.agi_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if xi.wsEffect.set(player, xi.wsEffect.BLAST_ARROW_ACC, 1, 60) then
            xi.wsEffect.message(player, 'Your next ranged weaponskill cannot miss.')
        else
            xi.wsEffect.message(player, 'You are already empowered.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/dulling_arrow.lua
-----------------------------------
do
    -----------------------------------
    -- Dulling Arrow
    -- Archery weapon skill
    -- Skill level: 80
    -- Lowers enemy's INT. Chance of params.critical varies with TP.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:16%  AGI:25%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.dulling_arrow.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}

        params.numHits = 1
        params.ftpMod = { 1.25, 1.25, 1.25 }
        params.str_wsc = 0.25 params.agi_wsc = 0.25
        params.critVaries = { 0.25, 0.5, 0.75 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.2 params.agi_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            local archerySkill = player:getSkillLevel(xi.skill.ARCHERY)
            local intDownPower = math.min(25, 5 + math.floor(archerySkill / 15))

            target:addStatusEffect(xi.effect.INT_DOWN, { power = intDownPower, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/empyreal_arrow.lua
-----------------------------------
do
    -----------------------------------
    -- Empyreal Arrow
    -- Archery weapon skill
    -- Skill level: 250
    -- In order to obtain Empyreal Arrow, the quest From Saplings Grow must be completed.
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:16%  AGI:25%
    -- 100%TP    200%TP    300%TP
    -- 2.00      2.75      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.empyreal_arrow.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params               = {}
        params.numHits             = 1
        params.ftpMod              = { 2.5, 2.75, 3.0 }
        params.atkVaries           = { 2.0, 2.0, 2.0 } -- https://w.atwiki.jp/studiogobli/pages/93.html
        params.str_wsc             = 0.25
        params.agi_wsc             = 0.25
        params.rangedAccuracyBonus = 100 -- https://www.ffxiah.com/forum/topic/52018/luck-of-the-draw-a-corsairs-guide-new/127/#3726841 (Empyreal Arrow is a bow copy of Detonator)

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod  = { 1.5, 2.5, 5.0 }
            params.str_wsc = 0.20
            params.agi_wsc = 0.50
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        local duration = 45 + math.floor((tp - 1000) / 100) * 3
        if not xi.wsEffect.applyMod(player, xi.mod.CRITHITRATE, 10, duration, 'Empyreal Arrow increased your critical hit rate!') then
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/flaming_arrow.lua
-----------------------------------
do
    -----------------------------------
    -- Flaming Arrow
    -- Archery weapon skill
    -- Skill level: 5
    -- Deals fire elemental damage. Damage varies with TP.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: Fire
    -- Modifiers: STR:16%  AGI:25%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.flaming_arrow.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.25 params.agi_wsc = 0.25
        params.hybridWS = true
        params.ele = xi.element.FIRE
        params.skill = xi.skill.ARCHERY
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 0.5, 0.75, 1.0 }
            params.str_wsc = 0.2 params.agi_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            local archerySkill = player:getSkillLevel(xi.skill.ARCHERY)
            local burnPower    = math.min(15, 3 + math.floor(archerySkill / 20))

            target:addStatusEffect(xi.effect.BURN, { power = burnPower, duration = 30, origin = player })

            player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/piercing_arrow.lua
-----------------------------------
do
    -----------------------------------
    -- Piercing Arrow
    -- Archery weapon skill
    -- Skill level: 40
    -- Ignores enemy's defense. Amount ignored varies with TP.
    -- The amount of defense ignored is 0% with 100TP, 35% with 200TP and 50% with 300TP.
    -- Typically does less damage than Flaming Arrow.
    -- Aligned with the Snow Gorget & Light Gorget.
    -- Aligned with the Snow Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:20%  AGI:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.piercing_arrow.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params               = {}
        params.numHits             = 1
        params.ftpMod              = { 1.1, 1.1, 1.1 }
        params.str_wsc             = 0.25 params.agi_wsc = 0.25
        params.rangedAccuracyBonus = 30 -- https://www.ffxiah.com/forum/topic/52018/luck-of-the-draw-a-corsairs-guide-new/127/#3726841 (split shot is a clone of piercing arrow)

        -- Defense ignored is 0%, 35%, 50% as per wiki.bluegartr.com
        params.ignoredDefense = { 0.1, 0.35, 0.5 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.2 params.agi_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.DEFENSE_DOWN, { power = 5, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/sidewinder.lua
-----------------------------------
do
    -----------------------------------
    -- Sidewinder
    -- Archery weapon skill
    -- Skill level: 175
    -- Delivers an inparams.accurate attack that deals quintuple damage. params.accuracy varies with TP.
    -- Aligned with the Aqua Gorget, Light Gorget & Breeze Gorget.
    -- Aligned with the Aqua Belt, Light Belt & Breeze Belt.
    -- Element: None
    -- Modifiers: STR:20%  AGI:50%
    -- 100%TP    200%TP    300%TP
    -- 5.00      5.00      5.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.sidewinder.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 5.0, 5.0, 5.0 }
        params.str_wsc = 0.25 params.agi_wsc = 0.25
        params.accVaries = { -50, -40, -30 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.2 params.agi_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)
        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
