-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: dagger
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_dagger')

-----------------------------------
-- Source: scripts/actions/weaponskills/dancing_edge.lua
-----------------------------------
do
    -----------------------------------
    -- Dancing Edge
    -- Dagger weapon skill
    -- Skill level: 200
    -- Delivers a fivefold attack. params.accuracy varies with TP.
    -- Will stack with Sneak Attack.
    -- Will stack with Trick Attack.
    -- Aligned with the Breeze Gorget & Soil Gorget.
    -- Aligned with the Breeze Belt & Soil Belt.
    -- Element: None
    -- Modifiers: DEX:30%  CHR:40%
    -- 100%TP    200%TP    300%TP
    -- 1.19      1.19      1.19
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.dancing_edge.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 5
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.dex_wsc = 0.50
        params.accVaries = { 0, 30, 60 } -- TODO: verify exact number

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.dex_wsc = 0.4
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/688.html
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.DANCING_EDGE_SA, 10, 60) then
            xi.wsEffect.message(player, 'Your next Sneak Attack is empowered.')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/energy_drain.lua
-----------------------------------
do
    -----------------------------------
    -- Energy Drain
    -----------------------------------
    -- https://www.bg-wiki.com/ffxi/Energy_Drain
    m:addOverride('xi.actions.weaponskills.energy_drain.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local fTPAnchors = { 1.5, 2.5, 4.0 }

        local startingAnchor = math.floor(tp / 1000)

        local multiplier = 0

        if tp >= 3000 then
            multiplier = fTPAnchors[3]
        else
            local basefTP   = fTPAnchors[startingAnchor]
            local nextfTP   = fTPAnchors[startingAnchor + 1]
            local multPerTP = (nextfTP - basefTP) / 1000 * (tp - 1000 * startingAnchor)
            -- TP = 1250; multiplier = 1.25 + ( (2.5 - 1.25) / 1000 * (1250 - (1000 * 1))
            --            multiplier = 1.25 + (1.25 / 1000) * 250)
            --            multiplier = 1.25 + 0.3125 = 1.5625
            multiplier = basefTP + multPerTP
        end

        local skill = player:getSkillLevel(xi.skill.DAGGER)
        local wsc   = player:getStat(xi.mod.MND) * 1.1

        local mpRestored = math.floor((math.floor(skill * 0.11) + wsc) * multiplier)

        if target:isUndead() then
            mpRestored = 0
        else
            -- Absorb MP from target
            mpRestored = target:delMP(mpRestored)

            -- Add stolen MP to player
            mpRestored = player:addMP(mpRestored)
        end

        -- Display MP actually given to player
        action:messageID(target:getID(), xi.msg.basic.SKILL_DRAIN_MP)
        action:param(target:getID(), mpRestored)

        return 1, 0, false, mpRestored
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/energy_steal.lua
-----------------------------------
do
    -----------------------------------
    -- Energy Steal
    -----------------------------------
    -- https://www.bg-wiki.com/ffxi/Energy_Steal
    m:addOverride('xi.actions.weaponskills.energy_steal.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local fTPAnchors = { 1.5, 2.5, 3.5 }

        local startingAnchor = math.floor(tp / 1000)

        local multiplier = 0

        if tp >= 3000 then
            multiplier = fTPAnchors[3]
        else
            local basefTP   = fTPAnchors[startingAnchor]
            local nextfTP   = fTPAnchors[startingAnchor + 1]
            local multPerTP = (nextfTP - basefTP) / 1000 * (tp - 1000 * startingAnchor)
            -- TP = 1250; multiplier = 1.0 + ( (2.1 - 1.0) / 1000 * (1250 - (1000 * 1))
            --            multiplier = 1.0 + (1.0 / 1000) * 250)
            --            multiplier = 1.0 + 0.275 = 1.275
            multiplier = basefTP + multPerTP
        end

        local skill = player:getSkillLevel(xi.skill.DAGGER)
        local wsc   = player:getStat(xi.mod.MND) * 1.0

        local hpStolen = math.floor((math.floor(skill * 0.11) + wsc) * multiplier)

        if target:isUndead() then
            hpStolen = 0
        else
            hpStolen = math.min(hpStolen, target:getHP())

            target:takeDamage(hpStolen, player, xi.attackType.PHYSICAL, xi.damageType.PIERCING)
            player:addHP(hpStolen)
        end

        action:messageID(target:getID(), xi.msg.basic.SKILL_DRAIN_HP)
        action:param(target:getID(), hpStolen)

        return 1, 0, false, hpStolen
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/evisceration.lua
-----------------------------------
do
    -----------------------------------
    -- Evisceration
    -- Dagger weapon skill
    -- Skill level: 230
    -- In order to obtain Evisceration, the quest Cloak and Dagger must be completed.
    -- Delivers a fivefold attack. Chance of params.critical hit varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget, Soil Gorget & Light Gorget.
    -- Aligned with the Shadow Belt, Soil Belt & Light Belt.
    -- Element: None
    -- Modifiers: DEX:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.evisceration.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 5
        params.ftpMod = { 1.15, 1.15, 1.15 }
        params.dex_wsc = 0.5
        params.critVaries = { 0.20, 0.35, 0.55 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true
            params.ftpMod = { 1.25, 1.25, 1.25 }
            params.crit200 = 0.25
            params.dex_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        local critBonus = utils.clamp(10 + math.floor((tp - 1000) * 15 / 2000), 10, 25)
        if xi.wsEffect.set(player, xi.wsEffect.EVISCERATION_CRIT, critBonus, 60) then
            xi.wsEffect.message(player, string.format('Your next Dagger weaponskill gains +%i%% critical hit rate.', critBonus))
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/gust_slash.lua
-----------------------------------
do
    -----------------------------------
    -- Gust Slash
    -- Dagger weapon skill
    -- Skill level: 40
    -- Deals wind elemental damage. Damage varies with TP.
    -- Will not stack with Sneak Attack.
    -- Aligned with the Breeze Gorget.
    -- Aligned with the Breeze Belt.
    -- Element: Wind
    -- Modifiers: DEX:20%  INT:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.00      2.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.gust_slash.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.0, 2.5 }
        params.dex_wsc = 0.2 params.int_wsc = 0.2
        params.ele = xi.element.WIND
        params.skill = xi.skill.DAGGER
        params.includemab = true
        params.dStat = xi.mod.INT

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            -- http://wiki.ffo.jp/html/682.html
            params.dex_wsc = 0.4 params.int_wsc = 0.4
            params.ftpMod = { 1.0, 2.0, 3.0 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.WIND })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/mercy_stroke.lua
-----------------------------------
do
    -----------------------------------
    -- Mercy Stroke
    -- Dagger weapon skill
    -- Skill level: N/A
    -- Batardeau/Mandau: Temporarily improves params.critical hit rate.
    -- Aftermath gives +5% params.critical hit rate.
    -- Must have Batardeau, Mandau, or Clement Skean equipped.
    -- Aligned with the Shadow Gorget & Soil Gorget.
    -- Aligned with the Shadow Belt & Soil Belt.
    -- Element: None
    -- Modifiers: DEX:60%
    -- 100%TP    200%TP    300%TP
    -- 3.00      3.00      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.mercy_stroke.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 3.5, 3.5, 3.5 }
        params.str_wsc = .8

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 5.0, 5.0, 5.0 }
            params.str_wsc = 0.8
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.RELIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/pyrrhic_kleos.lua
-----------------------------------
do
    -----------------------------------
    -- Pyrrhic Kleos
    -- Dagger weapon skill
    -- Skill level: N/A
    -- Description: Delivers a fourfold attack that lowers target's evasion. Duration of effect varies with TP. Terpsichore: Aftermath effect varies with TP.
    -- Available only after completing the Unlocking a Myth (Dancer) quest.
    -- Aligned with the Soil Gorget, Aqua Gorget & Snow Gorget.
    -- Aligned with the Soil Belt, Aqua Belt & Snow Belt.
    -- Element: Unknown
    -- Skillchain Properties: Distortion/Scission
    -- Modifiers: STR:40%  DEX:40%
    -- Damage Multipliers by TP:
    -- 100%TP    200%TP    300%TP
    -- 1.5        1.5        1.5
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.pyrrhic_kleos.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 4
        params.ftpMod  = { 1.75, 1.75, 1.75 }
        params.str_wsc = 0.4
        params.dex_wsc = 0.4

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/15896.html
            params.ftpMod      = { 1.75, 1.75, 1.75 }
            params.str_wsc     = 0.4
            params.dex_wsc     = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Apply Aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.MYTHIC)

        -- Handle status effect
        local effectId      = xi.effect.EVASION_DOWN
        local actionElement = xi.element.ICE
        local power         = 10
        local duration      = math.floor(6 * tp / 100 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shadowstitch.lua
-----------------------------------
do
    -----------------------------------
    -- Shadowstitch
    -- Dagger weapon skill
    -- Skill level: 70
    -- Binds target. Chance of binding varies with TP.
    -- Does stack with Sneak Attack.
    -- Aligned with the Aqua Gorget.
    -- Aligned with the Aqua Belt.
    -- Element: None
    -- Modifiers: CHR:100%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shadowstitch.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.chr_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.chr_wsc = 1
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local procChance = 25 + tp / 40

        if math.randomInt(1, 100) <= procChance then
            local effectId      = xi.effect.BIND
            local actionElement = xi.element.ICE
            local power         = 1
            local resistance    = applyResistanceAddEffect(player, target, actionElement, 0)
            local duration      = math.floor((15 + 15 * tp / 1000) * resistance)
            xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shark_bite.lua
-----------------------------------
do
    -----------------------------------
    -- Shark Bite
    -- Dagger weapon skill
    -- Skill level: 225
    -- Delivers a twofold attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Will stack with Trick Attack.
    -- Aligned with the Breeze Gorget & Thunder Gorget.
    -- Aligned with the Breeze Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: DEX:40% AGI:40%
    -- 100%TP    200%TP    300%TP
    --  2.00       4        5.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shark_bite.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 2.0, 2.5, 3.0 }
        params.dex_wsc = 0.5

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 4.5, 6.8, 8.5 }
            params.dex_wsc = 0.4 params.agi_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.CRIT_HIT_EVASION_DOWN, { power = 5, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/viper_bite.lua
-----------------------------------
do
    -----------------------------------
    -- Viper Bite
    -- Dagger weapon skill
    -- Skill level: 100
    -- Deals double damage and Poisons target. Duration of poison varies with TP.
    -- Doubles attack and not damage.
    -- Despite the animation showing two swings, this is a single-hit weapon skill.
    -- Will stack with Sneak Attack.
    -- Aligned with the Soil Gorget.
    -- Aligned with the Soil Belt.
    -- Element: None
    -- Modifiers: :
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.viper_bite.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params     = {}
        params.numHits   = 1
        params.ftpMod    = { 1, 1, 1 }
        params.atkVaries = { 2, 2, 2 }
        params.dex_wsc = .75

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.dex_wsc = 1
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.POISON
        local actionElement = xi.element.WATER
        local daggerSkill   = player:getSkillLevel(xi.skill.DAGGER)
        local power         = math.min(15, 3 + math.floor(daggerSkill / 20))
        local duration      = math.floor((30 + 6 * tp / 100) * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/wasp_sting.lua
-----------------------------------
do
    -----------------------------------
    -- Wasp Sting
    -- Dagger weapon skill
    -- Skill level: 5
    -- Poisons target. Duration of effect varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Soil Gorget.
    -- Aligned with the Soil Belt.
    -- Element: None
    -- Modifiers: :    DEX:100%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.wasp_sting.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.dex_wsc = .75

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.dex_wsc = 1
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.POISON
        local actionElement = xi.element.WATER
        local power         = 1
        local duration      = math.floor((75 + 15 * tp / 1000) * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
