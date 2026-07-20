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

    local slowTier = slowTable[master and master:countEffect(xi.effect.EARTH_MANEUVER) or 0]

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
    local params = {}

    params.baseDamage     = automaton:getWeaponDmg()
    params.numHits        = utils.clamp(1 + xi.automaton.getExtraHits(automaton, 1), 1, 8)
    params.fTP            = { 1.0, 1.0, 1.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = params.numHits

    -- local hammermillEquipped = automaton:hasAttachmentSet(xi.item.HAMMERMILL_ATTACHMENT) Not used? Delete?

    if math.randomFloat(0, 1) * 100 < chance then
        target:addStatusEffect(xi.effect.STUN, { power = 1, duration = 6, origin = automaton })
    end

    local slowPower = automaton:getMod(xi.mod.AUTO_SHIELD_BASH_SLOW)
    if slowPower > 0 then
        local duration = 20
        if slowPower == 12 then
            duration = math.randomInt(20, 35)
        elseif slowPower == 19 then
            duration = math.randomInt(51, 57)
        elseif slowPower == 25 then
            duration = math.randomInt(70, 75)
        end
    end

    local att = automaton:getStat(xi.mod.ATT)
    local def = target:getStat(xi.mod.DEF)

    if not att or not def or def <= 0 then
        return 0
    end

    local ratio = utils.clamp(att / def, 0.2, 1.3)
    local pdif = math.random(ratio * 0.8 * 1000, ratio * 1.2 * 1000)

    damage = damage * (pdif / 1000)

    damage = utils.handleStoneskin(target, damage)
    target:takeDamage(damage, automaton, xi.attackType.PHYSICAL, xi.damageType.BLUNT)
    target:updateEnmityFromDamage(automaton, damage)
    target:addEnmity(automaton, 500, 1000)

    return damage
end

return abilityObject
