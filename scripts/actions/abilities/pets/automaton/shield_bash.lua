-----------------------------------
-- Shield Bash (Automaton)
-- Description: Deals damage and stuns the target. Additional effect: Slow - Based on Earth Maneuvers if Hammermill is equipped.
-- Hammermill Slow increases with tiers per Earth Maneuver, at 3, overrides Haste (tier 6) -- Confirmed in Brenner.
-- https://wiki.ffo.jp/html/12156.html
-----------------------------------
---@type TAbilityAutomaton
local abilityObject = {}

-- Slow tier and duration based on Earth Maneuvers.
local slowTable =
{
    [1] = { tier = 4, duration = 30 },
    [2] = { tier = 5, duration = 50 },
    [3] = { tier = 6, duration = 70 },
}

local function applyHammermillSlow(automaton, target, skill, master)
    local power = automaton:getMod(xi.mod.AUTO_SHIELD_BASH_SLOW) * 100
    if power <= 0 then
        return
    end

    -- Count Earth maneuvers and map safely into slowTable (no index 0)
    local earthCount = master and master:countEffect(xi.effect.EARTH_MANEUVER) or 0
    local slowTier   = slowTable[earthCount]

    if not slowTier then
        -- No slow if we have 0 Earth Maneuvers
        return
    end

    local params =
    {
        [1] = { effectId = xi.effect.SLOW, power = power, duration = slowTier.duration, tier = slowTier.tier },
    }

    xi.combat.action.executeMobskillStatusEffect(automaton, target, skill, params, { messageBypass = true })
end

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    return 0
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    -- Simple stun chance (adjust if you want different odds)
    local stunChance = 50 -- percent

    -- Base physical damage from the automaton’s weapon
    local baseDamage = automaton:getWeaponDmg()
    local att        = automaton:getStat(xi.mod.ATT)
    local def        = target:getStat(xi.mod.DEF)

    if not att or not def or def <= 0 then
        return 0
    end

    -- Apply stun with the defined chance
    if math.random() * 100 < stunChance then
        target:addStatusEffect(xi.effect.STUN, { power = 1, duration = 6, origin = automaton })
    end

    -- Apply Hammermill slow if the attachment is equipped
    if automaton:hasAttachmentSet(xi.item.HAMMERMILL_ATTACHMENT) then
        applyHammermillSlow(automaton, target, skill, master)
    end

    -- Randomize PDIF based on ATT/DEF ratio, clamped
    local ratio   = utils.clamp(att / def, 0.2, 1.3)
    local pdifMin = ratio * 0.8
    local pdifMax = ratio * 1.2
    local pdif    = pdifMin + (pdifMax - pdifMin) * math.random()

    local damage = baseDamage * pdif

    damage = utils.handleStoneskin(target, damage)
    target:takeDamage(damage, automaton, xi.attackType.PHYSICAL, xi.damageType.BLUNT)
    target:updateEnmityFromDamage(automaton, damage)
    target:addEnmity(automaton, 500, 1000)

    return damage
end

return abilityObject
