-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: great katana
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_great_katana')

-----------------------------------
-- Source: scripts/actions/weaponskills/tachi_enpi.lua
-----------------------------------
do
    -----------------------------------
    -- Tachi Enpi
    -- Great Katana weapon skill
    -- Skill Level: 5
    -- Delivers a two-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Light Gorget & Soil Gorget.
    -- Aligned with the Light Belt & Soil Belt.
    -- Element: None
    -- Modifiers: STR:60%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.tachi_enpi.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.0, 1.5, 2.0 }
        params.str_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/tachi_gekko.lua
-----------------------------------
do
    -----------------------------------
    -- Tachi Gekko
    -- Great Katana weapon skill
    -- Skill Level: 225
    -- Silences target. Damage varies with TP.
    -- Silence effect duration is 60 seconds when unresisted.
    -- Will stack with Sneak Attack.
    -- Tachi: Gekko has a high attack bonus of +100%. [1]
    -- Aligned with the Aqua Gorget & Snow Gorget.
    -- Aligned with the Aqua Belt & Snow Belt.
    -- Element: None
    -- Modifiers: STR:75%
    -- 100%TP    200%TP    300%TP
    -- 1.5625      2.6875      4.125
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.tachi_gekko.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params     = {}
        params.numHits   = 1
        params.ftpMod    = { 1.5, 2.0, 2.5 }
        params.str_wsc   = 0.75
        params.atkVaries = { 2, 2, 2 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.5625, 2.6875, 4.125 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.SILENCE
        local actionElement = xi.element.WIND
        local power         = 1
        local duration      = math.floor(45 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        if xi.wsEffect.set(player, xi.wsEffect.TACHI_GEKKO_DAMAGE, 1, 60) then
            xi.wsEffect.message(player, 'Your next weaponskill of lower skill will be transformed!')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/tachi_kaiten.lua
-----------------------------------
do
    -----------------------------------
    -- Tachi Kaiten
    -- Great Katana weapon skill
    -- Skill level: N/A
    -- Additional effect: temporarily increases amount of TP stored with each hit.
    -- Grants Store TP+7 for the duration of time that it is active. Length of time depends on TP.
    -- 100 TP = 20s
    -- 200 TP = 40s
    -- 300 TP = 60s
    -- This weapon skill is only available with the stage 5 relic Great Katana Amanomurakumo or within Dynamis with the stage 4 Totsukanotsurugi.
    -- Also available as a Latent effect on Ame-no-ohabari
    -- Aligned with the Breeze Gorget, Thunder Gorget & Light Gorget.
    -- Aligned with the Breeze Belt, Thunder Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:75%
    -- 100%TP    200%TP    300%TP
    -- 3.00      3.00      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.tachi_kaiten.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.75, 2.75, 2.75 }
        params.str_wsc = 0.6

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.8
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.RELIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/tachi_kasha.lua
-----------------------------------
do
    -----------------------------------
    -- Tachi Kasha
    -- Great Katana weapon skill
    -- Skill Level: 250
    -- Paralyzes target. Damage varies with TP.
    -- Paralyze effect duration is 60 seconds when unresisted.
    -- In order to obtain Tachi: Kasha, the quest The Potential Within must be completed.
    -- Will stack with Sneak Attack.
    -- Tachi: Kasha appears to have a moderate attack bonus of +50%. [1]
    -- Aligned with the Flame Gorget, Light Gorget & Shadow Gorget.
    -- Aligned with the Flame Belt, Light Belt & Shadow Belt.
    -- Element: None
    -- Modifiers: STR:75%
    -- 100%TP    200%TP    300%TP
    -- 1.5625    2.6875    4.125
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.tachi_kasha.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params     = {}
        params.numHits   = 1
        params.ftpMod    = { 1.5, 2.0, 2.5 }
        params.str_wsc   = 0.75
        params.atkVaries = { 1.5, 1.5, 1.5 }
        params.critVaries = { .15, .25, .35 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod    = { 1.5625, 2.6875, 4.125 }
            params.str_wsc   = 0.75
            params.atkVaries = { 1.65, 1.65, 1.65 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.PARALYSIS
        local actionElement = xi.element.ICE
        local power         = 25
        local duration      = math.floor(60 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        if xi.wsEffect.set(player, xi.wsEffect.TACHI_KASHA_TP, 10, 60) then
            xi.wsEffect.message(player, 'Your next weaponskill has a chance to consume 0 TP!')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/tachi_koki.lua
-----------------------------------
do
    -----------------------------------
    -- Tachi Koki
    -- Great Katana weapon skill
    -- Skill level: 175
    -- Deals light elemental damage to enemy. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Aqua Gorget & Thunder Gorget.
    -- Aligned with the Aqua Belt & Thunder Belt.
    -- Element: Light
    -- Modifiers: STR:30%  MND:50%
    -- 100%TP    200%TP    300%TP
    -- .5        .75        1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.tachi_koki.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 0.5, 0.75, 1.0 }
        params.str_wsc = 0.5 params.mnd_wsc = 0.3
        params.hybridWS = true
        params.ele = xi.element.LIGHT
        params.skill = xi.skill.GREAT_KATANA
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 0.5, 1.5, 2.5 }
            params.str_wsc = 0.3 params.mnd_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.MAGIC_ATK_DOWN, { power = 15, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
