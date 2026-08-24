-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: hand to hand
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_hand_to_hand')

-----------------------------------
-- Source: scripts/actions/weaponskills/ascetics_fury.lua
-----------------------------------
do
    -----------------------------------
    -- Ascetics Fury
    -- Hand-to-Hand weapon skill
    -- Skill Level: N/A
    -- Chance of params.critical hit varies with TP. Glanzfaust: Aftermath effect varies with TP.
    -- Available only after completing the Unlocking a Myth (Monk) quest.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:50%  VIT:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.ascetics_fury.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params      = {}
        params.numHits    = 2
        params.ftpMod     = { 1.5, 1.75, 2.0 }
        params.atkVaries  = { 1.5, 1.5, 1.5 } -- https://w.atwiki.jp/studiogobli/pages/93.html
        params.critVaries = { 0.2, 0.3, 0.4 }
        params.str_wsc    = 0.5
        params.vit_wsc    = 0.5

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/15880.html
            params.critVaries  = { 0.2, 0.3, 0.5 }
            params.atkVaries   = { 2.5, 2.5, 2.5 }
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.MYTHIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/asuran_fists.lua
-----------------------------------
do
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
    m:addOverride('xi.actions.weaponskills.asuran_fists.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
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
        local hitsLanded = tpHits + extraHits
        local duration   = 45 + math.floor((tp - 1000) / 100) * 3

        if damage > 0 and hitsLanded > 0 then
            target:addStatusEffect(xi.effect.BLUNT_TRAUMA, { power = 500, duration = 60, origin = player })
        end

        if player:getMainJob() == xi.job.MNK then
            if hitsLanded > 0 then
                xi.wsEffect.set(
                    player,
                    xi.wsEffect.ASURAN_FISTS_COMBO,
                    hitsLanded,
                    duration
                )

                xi.wsEffect.message(player, string.format('Asuran Fists landed %i hits and empowered Raging Fists and Exploding Palm!', hitsLanded))
            elseif xi.wsEffect.peek(player) ~= xi.wsEffect.NONE then
                xi.wsEffect.clear(player)
            end
        elseif player:getMainJob() == xi.job.PUP then
            local pet = player:getPet()

            player:addStatusEffect(xi.effect.GEO_HASTE, { power = 500, duration = duration, origin = player })
            player:addStatusEffect(xi.effect.REGAIN, { power = 5, duration = duration, origin = player })

            if pet then
                pet:addStatusEffect(xi.effect.GEO_HASTE, { power = 500, duration = duration, origin = player })
                pet:addStatusEffect(xi.effect.REGAIN, { power = 5, duration = duration, origin = player })
            end

            xi.wsEffect.message(player, 'Asuran Fists granted Haste and Regain to master and automaton!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/backhand_blow.lua
-----------------------------------
do
    -----------------------------------
    -- Backhand Blow
    -- Hand-to-Hand weapon skill
    -- Skill Level: 100
    -- Deals params.critical damage. Chance of params.critical hit varies with TP.
    -- Aligned with the Breeze Gorget.
    -- Aligned with the Breeze Belt.
    -- Element: None
    -- Modifiers: STR:30%  DEX:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.backhand_blow.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1, 1, 1 }
        params.str_wsc = 0.3 params.dex_wsc = 0.3
        params.critVaries = { 0.4, 0.6, 0.8 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/2419.html
            params.str_wsc = 0.5 params.dex_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ACCURACY_DOWN, { power = 10, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/combo.lua
-----------------------------------
do
    -----------------------------------
    -- Combo
    -- Hand-to-Hand weapon skill
    -- Skill level: 5
    -- Delivers a threefold attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: None
    -- Modifiers: STR:20%  DEX:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.combo.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 3
        params.ftpMod = { 1.0, 1.25, 1.5 }
        params.str_wsc = 0.3 params.dex_wsc = 0.15

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/2416.html
            params.ftpMod = { 1.0, 2.4, 3.4 }
            params.str_wsc = 0.3 params.dex_wsc = 0.3
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/dragon_kick.lua
-----------------------------------
do
    -----------------------------------
    -- Dragon Kick
    -- Hand-to-Hand weapon skill
    -- Skill Level: 225
    -- Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Breeze Gorget & Thunder Gorget.
    -- Aligned with the Breeze Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:50%  VIT:50%
    -- 100%TP    200%TP    300%TP
    -- 2.00      2.50      3.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.dragon_kick.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 2.0, 2.5, 3.5 }
        params.atkVaries = { 1.15, 1.25, 1.35 }
        params.str_wsc = 1.0
        params.vit_wsc = 0.5
        params.kick = true -- https://www.bluegartr.com/threads/112776-Dev-Tracker-Findings-Posts-%28NO-DISCUSSION%29?p=6712150&viewfull=1#post6712150

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- https://www.bg-wiki.com/ffxi/Dragon_Kick
            params.ftpMod = { 1.7, 3.0, 5.0 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/exploding_palm.lua
-----------------------------------
do
    -----------------------------------
    -- Exploding Palm (Formerly Spinning Attack)
    -- Hand-to-Hand weapon skill
    -- Skill Level: 150
    -- Delivers an area attack. Radius varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Flame Gorget & Thunder Gorget.
    -- Aligned with the Flame Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR: 35%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    -- TODO: Radius 5y at 2334 TP
    m:addOverride('xi.actions.weaponskills.exploding_palm.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.5, 1.7, 1.9 }
        params.str_wsc = .75
        params.dex_wsc = .5
        params.ignoredDefense = { 0.25, 0.35, 0.45 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1.0 -- http://wiki.ffo.jp/html/2421.html
            params.multiHitfTP = true
        end

        local asuranHitCount = 0

        if xi.wsEffect.has(player, xi.wsEffect.ASURAN_FISTS_COMBO) then
            local _, hitCount = xi.wsEffect.peek(player)
            asuranHitCount = hitCount
            params.damageMultiplier = 1 + asuranHitCount * 0.05
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.MAGIC_DEF_DOWN, { power = 5, duration = 45, origin = player })
        end

        -- Exploding Palm is an AoE weaponskill. Delay consumption so every target
        -- processed by the same action receives the empowered damage multiplier.
        if asuranHitCount > 0 then
            player:timer(0, function(playerArg)
                if xi.wsEffect.has(playerArg, xi.wsEffect.ASURAN_FISTS_COMBO) then
                    xi.wsEffect.consume(playerArg)
                    xi.wsEffect.message(playerArg, string.format('Asuran Fists increased Exploding Palm damage by %i%%!', asuranHitCount * 5))
                end
            end)
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/final_heaven.lua
-----------------------------------
do
    -----------------------------------
    -- Skill: Final Heaven
    -- H2H weapon skill
    -- Skill Level N/A
    -- Additional effect: temporarily enhances Subtle Blow xi.effect.
    -- Mods : VIT:60%
    -- 100%TP     200%TP     300%TP
    -- 3.0x        3.0x    3.0x
    -- +10 Subtle Blow for a short duration after using the weapon skill. (Not implemented)
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.final_heaven.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        -- number of normal hits for ws
        params.numHits = 2
        -- stat-modifiers (0.0 = 0%, 0.2 = 20%, 0.5 = 50%..etc)
        params.str_wsc = 0.6
        params.ftpMod = { 3.0, 3.0, 3.0 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.vit_wsc = 0.8
            -- as of 02.03.2022 the ws doesnt yet apply ftp to all stage, was delaied to be done in line with other relic ws
            -- http://wiki.ffo.jp/html/2426.html and https://forum.square-enix.com/ffxi/threads/55998-October-2019-FINAL-FANTASY-XI-Digest?highlight=2019+update
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.RELIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/howling_fist.lua
-----------------------------------
do
    -----------------------------------
    -- Howling Fist
    -- Hand-to-Hand weapon skill
    -- Skill Level: 200
    -- Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Ignores some defense.
    -- Aligned with the Light Gorget & Thunder Gorget.
    -- Aligned with the Light Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:20%  VIT:50%
    -- 100%TP    200%TP    300%TP
    -- 2.50      2.75      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.howling_fist.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params     = {}
        params.numHits   = 2
        params.ftpMod    = { 2.0, 2.5, 3.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 } -- https://w.atwiki.jp/studiogobli/pages/93.html
        params.str_wsc   = 0.3
        params.vit_wsc   = 0.5

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/2422.html
            params.ftpMod = { 2.05, 3.55, 5.75 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.CHAKRA_BOOST, 25, 60) then
            xi.wsEffect.message(player, 'Your next Chakra will restore 25% more HP!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/one_inch_punch.lua
-----------------------------------
do
    -----------------------------------
    -- One Inch Punch
    -- Hand-to-Hand weapon skill
    -- Skill level: 75
    -- Delivers an attack that ignores target's defense. Amount ignored varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget.
    -- Aligned with the Shadow Belt.
    -- Element: None
    -- Modifiers: VIT:40%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.one_inch_punch.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.4
        -- Defense ignored is 0%, 30%, 50% as per http://www.bg-wiki.com/bg/One_Inch_Punch
        params.ignoredDefense = { 0.1, 0.3, 0.5 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/2418.html
            params.vit_wsc = 1.0
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

                    -- Add critical hit buff after WS for 45 seconds
        player:addStatusEffect(xi.effect.CRITICAL_BOOST, { power = 10, duration = 45, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/raging_fists.lua
-----------------------------------
do
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
    m:addOverride('xi.actions.weaponskills.raging_fists.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
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
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shoulder_tackle.lua
-----------------------------------
do
    -----------------------------------
    -- Shoulder Tackle
    -- Hand-to-Hand weapon skill
    -- Skill Level: 40
    -- Stuns target. Chance of stunning varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Aqua Gorget & Thunder Gorget.
    -- Aligned with the Aqua Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: VIT:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shoulder_tackle.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 2
        params.ftpMod  = { 1, 1, 1 }
        params.vit_wsc = 0.3
        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.multiHitfTP = true -- http://wiki.ffo.jp/html/2417.html
            params.vit_wsc     = 1
        end

        -- Handle status effect
        local effectId      = xi.effect.STUN
        local actionElement = xi.element.THUNDER
        local power         = 1
        local duration      = math.floor(tp / 500 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
