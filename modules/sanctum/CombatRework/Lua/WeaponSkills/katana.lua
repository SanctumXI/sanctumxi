-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: katana
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_katana')

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_chi.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Chi
    -- Katana weapon skill
    -- Skill Level: 150
    -- Delivers a two-hit earth elemental attack. Damage varies with TP.
    -- Aligned with the Thunder Gorget & Light Gorget.
    -- Aligned with the Thunder Belt & Light Belt.
    -- Element: Earth
    -- Modifiers: STR:30%  INT:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_chi.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 0.75, 1.0, 1.25 }
        params.str_wsc = 0.30 params.int_wsc = 0.30
        params.hybridWS = true
        params.ele = xi.element.EARTH
        params.skill = xi.skill.KATANA
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            -- http://wiki.ffo.jp/html/720.html
            params.ftpMod = { 0.5, 1.375, 2.25 }
            params.str_wsc = 0.3 params.int_wsc = 0.3
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.EARTH })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_ei.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Ei
    -- Katana weapon skill
    -- Skill Level: 175
    -- Delivers a dark elemental attack. Damage varies with TP.
    -- Aligned with the Shadow Gorget.
    -- Aligned with the Shadow Belt.
    -- Element: Dark
    -- Modifiers: STR:30%  INT:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_ei.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.5, 2.0, 2.5 }
        params.str_wsc = 0.35 params.int_wsc = 0.35
        params.ele = xi.element.DARK
        params.skill = xi.skill.KATANA
        params.includemab = true

        -- to do ignore shadow and blink https://www.bg-wiki.com/ffxi/Blade:_Ei
        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.int_wsc = 0.4
            params.ftpMod = { 1.0, 3.0, 5.0 }
        end

        local damage, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.DARK })
        end

        return tpHits, extraHits, false, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_jin.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Jin
    -- Katana weapon skill
    -- Skill Level: 200
    -- Delivers a three-hit attack. Chance of params.critical varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Breeze Gorget & Thunder Gorget.
    -- Aligned with the Breeze Belt & Thunder Belt.
    -- Element: Wind
    -- Modifiers: STR:30%  DEX:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_jin.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 3
        params.ftpMod = { 1.1, 1.1, 1.1 }
        params.str_wsc = 0.45 params.dex_wsc = 0.3
        params.critVaries = { 0.20, 0.35, 0.55 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.375, 1.375, 1.375 }
            params.multiHitfTP = true -- https://www.bg-wiki.com/ffxi/Blade:_Jin
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_kamu.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Kamu
    -- Katana weapon skill
    -- Skill Level: N/A
    -- Lowers target's params.accuracy. Duration of effect varies with TP. Nagi: Aftermath effect varies with TP.
    -- Effect lasts 60 seconds @ 100 TP, 90 seconds @ 200 TP, and 120 seconds @ 300 TP
    -- Available only after completing the Unlocking a Myth (Ninja) quest.
    -- Aligned with the Shadow Gorget, Thunder Gorget & Breeze Gorget.
    -- Aligned with the Shadow Belt, Thunder Belt & Breeze Belt.
    -- Element: None
    -- Modifiers: STR:50%  INT:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_kamu.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params     = {}
        params.numHits   = 1
        params.ftpMod    = { 1.5, 1.5, 1.5 }
        params.str_wsc   = 0.45
        params.dex_wsc   = 0.45
        params.ignoredDefense = { 0.25, 0.30, 0.35 }
        params.atkVaries      = { 2.25, 2.25, 2.25 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc        = 0.6
            params.int_wsc        = 0.6
            params.ignoredDefense = { 0.25, 0.25, 0.25 }
            params.atkVaries      = { 2.25, 2.25, 2.25 } -- http://wiki.ffo.jp/html/15893.html
        end

        -- Apply Aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.MYTHIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.ACCURACY_DOWN
        local actionElement = xi.element.EARTH
        local power         = 10
        local duration      = math.floor(6 * tp / 100 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_ku.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Ku
    -- Katana weapon skill
    -- Skill level: N/A
    -- Description: Delivers a five-hit attack. params.accuracy varies with TP.
    -- In order to obtain Blade: Ku, the quest Bugi Soden must be completed.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget, Soil Gorget & Light Gorget.
    -- Aligned with the Shadow Belt, Soil Belt & Light Belt.
    -- Skillchain Properties: Gravitation/Transfixion
    -- Modifiers: STR:10%  DEX:10%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    --         params.acc
    -- 100%TP    200%TP    300%TP
    -- ??        ??        ??
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_ku.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 5
        params.ftpMod = { 1.1, 1.25, 1.35 }
        params.str_wsc = 0.35 params.dex_wsc = 0.4
        -- Sufficient data for ACC bonus/penalty does not exist; assuming no penalty and 10% increase per 1000 TP
        -- http://wiki.ffo.jp/html/732.html does not list ACC Bonus
        -- https://www.bg-wiki.com/ffxi/Blade:_Ku does not list ACC Bonus
        params.accVaries = { 35, 50, 80 } -- TODO: verify exact number

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.25, 1.25, 1.25 }
            params.str_wsc = 0.3 params.dex_wsc = 0.3
            params.multiHitfTP = true
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
        local duration = 45 + math.floor((tp - 1000) / 100) * 3

        xi.wsEffect.applyMod(
            player,
            xi.mod.THROWING_DAMAGEP,
            10,
            duration,
            'Your throwing attacks will deal 10% more damage!'
        )

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_metsu.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Metsu
    -- Katana weapon skill
    -- Skill Level: N/A
    -- Additional effect: Paralysis
    -- Hidden effect: temporarily enhances Subtle Blow xi.effect.
    -- One hit weapon skill, despite non single-hit animation.
    -- This weapon skill is only available with the stage 5 relic Katana Kikoku or within Dynamis with the stage 4 Yoshimitsu.
    -- Weaponskill is also available with the Sekirei Katana obtained from Abyssea NM Sedna.
    -- Aligned with the Shadow Gorget, Breeze Gorget & Thunder Gorget.
    -- Aligned with the Shadow Belt, Breeze Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: DEX:60%
    -- 100%TP    200%TP    300%TP
    -- 3.00      3.00      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_metsu.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 4
        params.ftpMod  = { 1.25, 1.5, 1.75 }
        params.str_wsc = 0.3 params.dex_wsc = 0.65

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod  = { 5, 5, 5 }
            params.dex_wsc = 0.8
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.RELIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.PARALYSIS
        local actionElement = xi.element.ICE
        local power         = 10
        local duration      = math.floor(60 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_rin.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Rin
    -- Katana weapon skill
    -- Skill Level: 5
    -- Delivers a single-hit attack. Chance of params.critical varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Light Gorget.
    -- Aligned with the Light Belt.
    -- Element: None
    -- Modifiers: STR:20%  DEX:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_rin.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.2 params.dex_wsc = 0.2
        -- TODO: critical hit rate of this ws is base on amount of tp alone, does not consider Critical Hit Rate from dDEX, equipment, or likely merits/base
        -- https://www.bg-wiki.com/ffxi/Blade:_Rin
        params.critVaries = { 0.3, 0.6, 0.9 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6 params.dex_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_teki.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Teki
    -- Katana weapon skill
    -- Skill Level: 70
    -- Decription: Deals water elemental damage. Damage varies with TP.
    -- Aligned with the Aqua Gorget.
    -- Aligned with the Aqua Belt.
    -- Element: Water
    -- Modifiers: STR:20%  INT:20%
    -- 100%TP    200%TP    300%TP
    -- 0.50      0.75      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_teki.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 0.5, 0.75, 1.0 }
        params.str_wsc = 0.3 params.int_wsc = 0.3
        params.hybridWS = true
        params.ele = xi.element.WATER
        params.skill = xi.skill.KATANA
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            -- http://wiki.ffo.jp/html/718.html
            params.str_wsc = 0.3 params.int_wsc = 0.3
            params.ftpMod = { 0.5, 1.375, 2.25 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.WATER })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_ten.lua
-----------------------------------
do
    -----------------------------------
    -- Blade Ten
    -- Katana weapon skill
    -- Skill Level: 225
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget & Soil Gorget.
    -- Aligned with the Shadow Belt & Soil Belt.
    -- Element: None
    -- Modifiers: STR:30%  DEX:30%
    -- 100%TP    200%TP    300%TP
    -- 2.50      2.75      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_ten.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.5, 2.75, 3.5 }
        params.str_wsc = 0.5 params.dex_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 4.5, 11.5, 15.5 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.BLADE_TEN_NINJUTSU, 10, 60) then
            player:addMod(xi.mod.BLADE_TEN_NINJUTSU, 1)
            xi.wsEffect.message(player, 'Your next elemental ninjutsu will deal 10% more damage and cast instantly!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/blade_to.lua
-----------------------------------
do
    -----------------------------------
    -- Blade To
    -- Katana weapon skill
    -- Skill Level: 100
    -- Deals ice elemental damage. Damage varies with TP.
    -- Aligned with the Snow Gorget & Breeze Gorget.
    -- Aligned with the Snow Belt & Breeze Belt.
    -- Element: Ice
    -- Modifiers: STR:30%  INT:30%
    -- 100%TP    200%TP    300%TP
    -- 0.50      0.75      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.blade_to.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 0.75, 1.0, 1.25 }
        params.str_wsc = 0.3 params.int_wsc = 0.3
        params.hybridWS = true
        params.ele = xi.element.ICE
        params.skill = xi.skill.KATANA
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            -- http://wiki.ffo.jp/html/719.html
            params.str_wsc = 0.4 params.int_wsc = 0.4
            params.ftpMod = { 0.5, 1.5, 2.5 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.ICE })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
