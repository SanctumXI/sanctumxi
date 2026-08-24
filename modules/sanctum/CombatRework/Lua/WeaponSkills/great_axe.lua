-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: great axe
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_great_axe')

-----------------------------------
-- Source: scripts/actions/weaponskills/armor_break.lua
-----------------------------------
do
    -----------------------------------
    -- Armor Break
    -- Great Axe weapon skill
    -- Skill level: 100
    -- Lowers enemy's defense. Duration of effect varies with TP.
    -- Lowers defense by as much as 15% if unresisted.
    -- Strong against: Antica, Bats, Cockatrice, Dhalmel, Lizards, Mandragora, Worms.
    -- Immune: Ahriman.
    -- Will stack with Sneak Attack.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: Wind
    -- Modifiers: STR:20%  VIT:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.armor_break.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.str_wsc = 0.3
        params.vit_wsc = 0.4

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
            params.vit_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.DEFENSE_DOWN
        local actionElement = xi.element.WIND
        local power         = 15
        local duration      = math.floor((120 + 6 * tp / 100) * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/full_break.lua
-----------------------------------
do
    -----------------------------------
    -- Full Break
    -- Great Axe weapon skill
    -- Skill level: 225 (Warriors only.)
    -- Lowers enemy's attack, defense, params.accuracy, and evasion. Duration of effect varies with TP.
    -- Lowers attack and defense by 12.5%, evasion by 20 points, and estimated to also lower params.accuracy by 20 points.
    -- These enfeebles are given as four seperate status effects, resists calculated seperately for each. They almost always wear off simultaneously, but have been observed to wear off at different times.
    -- Strong against: Coeurls.
    -- Immune: Antica, Cockatrice, Crawlers, Worms.
    -- Will stack with Sneak Attack.
    -- Aligned with the Aqua Gorget & Snow Gorget.
    -- Aligned with the Aqua Belt & Snow Belt.
    -- Element: Earth
    -- Modifiers: STR:50%  VIT:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.full_break.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1.25, 1.5 }
        params.str_wsc = 0.3
        params.vit_wsc = 0.7

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effects.
        local effects =
        {
            [1] = { xi.effect.ATTACK_DOWN,   xi.element.WATER, 12.5 },
            [2] = { xi.effect.DEFENSE_DOWN,  xi.element.WIND,  12.5 },
            [3] = { xi.effect.ACCURACY_DOWN, xi.element.EARTH, 20   },
            [4] = { xi.effect.EVASION_DOWN,  xi.element.ICE,   20   },
        }

        for index = 1, #effects do
            local effectId      = effects[index][1]
            local actionElement = effects[index][2]
            local power         = effects[index][3]
            local duration      = math.floor(60 + 3 * tp / 100 * applyResistanceAddEffect(player, target, actionElement, 0))
            xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)
        end

        if xi.wsEffect.set(player, xi.wsEffect.FULL_BREAK_DAMAGE, 5, 45) then
            xi.wsEffect.message(player, 'Full Break increased your damage dealt by 5%!')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/iron_tempest.lua
-----------------------------------
do
    -----------------------------------
    -- Iron Tempest
    -- Great Axe weapon skill
    -- Skill Level: 40
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Soil Gorget.
    -- Aligned with the Soil Belt.
    -- Element: None
    -- Modifiers: STR:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.iron_tempest.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.3
        params.atkVaries = { 1.0, 2.0, 3.5 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.SLOW, { power = 500, duration = 30, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/keen_edge.lua
-----------------------------------
do
    -----------------------------------
    -- Keen Edge
    -- Great Axe weapon skill
    -- Skill level: 150
    -- Delivers a single hit attack. Chance of params.critical varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget.
    -- Aligned with the Shadow Belt.
    -- Element: None
    -- Modifiers: STR:35%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.keen_edge.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.6
        params.critVaries = { 0.5, 0.75, 1.0 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1.0
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.CRIT_HIT_EVASION_DOWN, { power = 10, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/kings_justice.lua
-----------------------------------
do
    -----------------------------------
    -- Kings Justice
    -- Great Axe weapon skill
    -- Skill Level: N/A
    -- Delivers a threefold attack. Damage varies with TP. Conqueror: Aftermath effect varies with TP.
    -- Available only after completing the Unlocking a Myth (Warrior) quest.
    -- Aligned with the Breeze Gorget, Thunder Gorget & Soil Gorget.
    -- Aligned with the Breeze Belt, Thunder Belt & Soil Belt.
    -- Element: None
    -- Modifiers: STR:60%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.25      1.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.kings_justice.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 3
        params.ftpMod = { 1.5, 1.75, 2.0 }
        params.str_wsc = 0.7
            params.critVaries = { 0.15, 0.3, 0.5 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.0, 3.0, 5.0 }
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.MYTHIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/metatron_torment.lua
-----------------------------------
do
    -----------------------------------
    -- Metatron Torment
    -- Great Axe Weapon Skill
    -- Skill Level: N/A
    -- Lowers target's defense. Additional effect: temporarily lowers damage taken from enemies.
    -- Defense Down effect is 18.5%, 1 minute duration.
    -- Damage reduced is 20.4% or 52/256.
    -- Lasts 20 seconds at 100TP, 40 seconds at 200TP and 60 seconds at 300TP.
    -- Available only when equipped with the Relic Weapons Abaddon Killer (Dynamis use only) or Bravura.
    -- Also available as a Latent effect on Barbarus Bhuj
    -- Since these Relic Weapons are only available to Warriors, only Warriors may use this Weapon Skill.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:60%
    -- 100%TP    200%TP    300%TP
    -- 2.75      2.75      2.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.metatron_torment.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 2.75, 2.75, 2.75 }
        params.str_wsc = 0.8

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.8
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.RELIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.DEFENSE_DOWN
        local actionElement = xi.element.WIND
        local power         = 19
        local duration      = math.floor(120 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/raging_rush.lua
-----------------------------------
do
    -----------------------------------
    -- Raging Rush
    -- Great Axe weapon skill
    -- Skill level: 200 (Warriors only.)
    -- Delivers a three-hit attack. Chance of params.critical hit varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Snow Gorget & Aqua Gorget.
    -- Aligned with the Snow Belt & Aqua Belt.
    -- Element: None
    -- Modifiers: STR:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.raging_rush.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 3
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.5
        params.critVaries = { 0.25, 0.35, 0.5 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.critVaries = { 0.15, 0.3, 0.5 }
            params.str_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        player:addStatusEffect(xi.effect.BLOOD_RAGE, { power = 100, duration = 10, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shield_break.lua
-----------------------------------
do
    -----------------------------------
    -- Shield Break
    -- Great Axe weapon skill
    -- Skill level: 5
    -- Lowers enemy's Evasion. Duration of effect varies with TP.
    -- Lowers Evasion by as much as 40 if unresisted.
    -- Strong against: Bees, Beetles, Birds, Crabs, Crawlers, Flies, Lizards, Mandragora, Opo-opo, Pugils, Sabotenders, Scorpions, Sea Monks, Spiders, Tonberry, Yagudo.
    -- Immune: Bombs, Gigas, Ghosts, Sheep, Skeletons, Tigers.
    -- Will stack with Sneak Attack.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: Ice
    -- Modifiers: STR:60%  VIT:60%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shield_break.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.str_wsc = 0.2
        params.vit_wsc = 0.2

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
            params.vit_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.EVASION_DOWN
        local actionElement = xi.element.ICE
        local power         = 40
        local duration      = math.floor((120 + 6 * tp / 100) * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/steel_cyclone.lua
-----------------------------------
do
    -----------------------------------
    -- Steel Cyclone
    -- Great Axe weapon skill
    -- Skill level: 240
    -- Delivers a single-hit attack. Damage varies with TP.
    -- In order to obtain Steel Cyclone, the quest The Weight of Your Limits must be completed.
    -- Will stack with Sneak Attack.
    -- Aligned with the Breeze Gorget, Aqua Gorget & Snow Gorget.
    -- Aligned with the Breeze Belt, Aqua Belt & Snow Belt.
    -- Element: None
    -- Modifiers: STR:60%  VIT:60%
    -- 100%TP    200%TP    300%TP
    -- 1.50       2.5       4.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.steel_cyclone.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.75, 2.0, 2.5 }
        params.str_wsc = 0.6 params.vit_wsc = 0.6
        --params.atkVaries = { 1.66, 1.66, 1.66 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.5, 2.5, 4.0 }
            params.str_wsc = 0.6 params.vit_wsc = 0.6
            params.atkVaries = { 1.5, 1.5, 1.5 }
        end

        if player:getMainJob() == xi.job.WAR then
            params.vit_wsc = 0.7
            params.str_wsc = 0.6
            params.atkVaries = { 1.25, 1.5, 1.75 }
        end

        if player:getMainJob() == xi.job.DRK then
            params.vit_wsc = 0.3
            params.int_wsc = 0.7
            params.str_wsc = 0.0
            params.bonusWSmods = math.floor(player:getStat(xi.mod.ATT) / 20)
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
        local empoweredDuration = 45 + math.floor((tp - 1000) / 100) * 3

        player:addStatusEffect(xi.effect.DEFENSE_BOOST, { power = 20, duration = empoweredDuration, origin = player })

        if xi.wsEffect.set(player, xi.wsEffect.STEEL_CYCLONE_DEF, 70, empoweredDuration) then
            xi.wsEffect.message(player, 'Your next Great Axe weaponskill is empowered by your defense.')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/sturmwind.lua
-----------------------------------
do
    -----------------------------------
    -- Sturmwind
    -- Great Axe weapon skill
    -- Skill level: 70
    -- Delivers a two-hit attack. Attack varies with TP.
    -- Will stack with Sneak Attack, but only the first hit.
    -- Aligned with the Soil Gorget & Aqua Gorget.
    -- Aligned with the Soil Belt & Aqua Belt.
    -- Element: None
    -- Modifiers: STR:60%
    -- 100%TP    200%TP    300%TP
    -- 1.0       2.0       3.5
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.sturmwind.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.5
        params.atkVaries = { 1.0, 1.75, 2.5 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/weapon_break.lua
-----------------------------------
do
    -----------------------------------
    -- Weapon Break
    -- Great Axe weapon skill
    -- Skill level: 175
    -- Lowers enemy's attack. Duration of effect varies with TP.
    -- Lowers attack by as much as 25% if unresisted.
    -- Strong against: Manticores, Orcs, Rabbits, Raptors, Sheep.
    -- Immune: Crabs, Crawlers, Funguars, Quadavs, Pugils, Sahagin, Scorpion.
    -- Will stack with Sneak Attack.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: Water
    -- Modifiers: STR:60%  VIT:60%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.weapon_break.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.str_wsc = 0.32
        params.vit_wsc = 0.32

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
            params.vit_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.ATTACK_DOWN
        local actionElement = xi.element.WATER
        local power         = 25
        local duration      = math.floor(120 + 6 * tp / 100 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        player:addStatusEffect(xi.effect.ACCURACY_BOOST, { power = 20, duration = 45, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
