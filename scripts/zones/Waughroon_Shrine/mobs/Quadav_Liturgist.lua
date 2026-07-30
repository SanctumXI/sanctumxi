-----------------------------------
-- Area: Waughroon Shrine
--  Mob: Quadav Liturgist
-- KSNM: Heavy Is the Shell
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
}
-----------------------------------

local tuning =
{
    level                = 75,
    accuracyBonus        = 15,
    rangedAccuracyBonus  = 15,
    baseDamageMultiplier = 125,
    curePotency          = 25,
    magicCooldown        = 12,
    refresh              = 20,
}

---@type TMobEntity
local entity = {}

local function getBattlefieldAllies(mob)
    local allies      = {}
    local battlefield = mob:getBattlefield()

    if battlefield then
        for _, ally in pairs(battlefield:getMobs(true, true)) do
            if
                ally and
                ally:getID() ~= mob:getID() and
                ally:isAlive()
            then
                table.insert(allies, ally)
            end
        end
    end

    return allies
end

local function findAfflictedTarget(mob, allies, effect)
    if mob:hasStatusEffect(effect) then
        return mob
    end

    for _, ally in pairs(allies) do
        if
            ally:checkDistance(mob) <= 20 and
            ally:hasStatusEffect(effect)
        then
            return ally
        end
    end

    return nil
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.SILENCE)
end

entity.onMobSpawn = function(mob)
    if mob:getMainLvl() ~= tuning.level then
        mob:setMobLevel(tuning.level)
    end

    mob:setMod(xi.mod.EARTH_SDT, -1500)
    mob:setMod(xi.mod.WIND_SDT, 500)
    mob:setMod(xi.mod.POISON_RES_RANK, 4)

    mob:addMod(xi.mod.ACC, tuning.accuracyBonus)
    mob:addMod(xi.mod.RACC, tuning.rangedAccuracyBonus)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, tuning.baseDamageMultiplier)
    mob:setMobMod(xi.mobMod.MAGIC_COOL, tuning.magicCooldown)
    mob:setMod(xi.mod.CURE_POTENCY, tuning.curePotency)
    mob:setMod(xi.mod.REFRESH, tuning.refresh)
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local allies = getBattlefieldAllies(mob)

    -- Status removal takes priority over every other cast when a valid target is afflicted.
    local statusTarget = findAfflictedTarget(mob, allies, xi.effect.BLINDNESS)
    if statusTarget then
        return xi.magic.spell.BLINDNA, statusTarget
    end

    statusTarget = findAfflictedTarget(mob, allies, xi.effect.PARALYSIS)
    if statusTarget then
        return xi.magic.spell.PARALYNA, statusTarget
    end

    -- Esuna is self-targeted and should only be selected when its AoE can cleanse something.
    local esunaEffects =
    {
        xi.effect.FLASH,
        xi.effect.POISON,
        xi.effect.CURSE_I,
        xi.effect.CURSE_II,
        xi.effect.DISEASE,
        xi.effect.PLAGUE,
    }

    for _, effect in pairs(esunaEffects) do
        -- Esuna chooses the ailment from the caster, then removes that ailment in an AoE.
        if mob:hasStatusEffect(effect) then
            return xi.magic.spell.ESUNA, mob
        end
    end

    local spellList =
    {
        { xi.magic.spell.SLOW,        target, false, xi.action.type.ENFEEBLING_TARGET,  xi.effect.SLOW,      0, 100 },
        { xi.magic.spell.SHELLRA_III, mob,    true,  xi.action.type.ENHANCING_FORCE_SELF, xi.effect.SHELL,   3,  75 },
        { xi.magic.spell.REGEN_II,    mob,    true,  xi.action.type.ENHANCING_TARGET,   xi.effect.REGEN,     2,  75 },
        { xi.magic.spell.CURE_IV,     mob,    true,  xi.action.type.HEALING_TARGET,     60,                  0, 100 },
        { xi.magic.spell.CURE_V,      mob,    true,  xi.action.type.HEALING_TARGET,     35,                  0, 150 },
        { xi.magic.spell.STONESKIN,   mob,    false, xi.action.type.ENHANCING_TARGET,   xi.effect.STONESKIN, 0,  50 },
        { xi.magic.spell.BANISH_II,   target, false, xi.action.type.DAMAGE_TARGET,      nil,                 0,  50 },
        { xi.magic.spell.CURAGA_II,   mob,    true,  xi.action.type.HEALING_FORCE_SELF, 60,                  0, 125 },
        { xi.magic.spell.REPOSE,      target, false, xi.action.type.ENFEEBLING_TARGET,  xi.effect.SLEEP_I,   0,  50 },
        { xi.magic.spell.BANISH_III,  target, false, xi.action.type.DAMAGE_TARGET,      nil,                 0, 100 },
        { xi.magic.spell.BANISHGA_II, target, false, xi.action.type.DAMAGE_TARGET,      nil,                 0,  75 },
    }

    return xi.combat.behavior.chooseAction(mob, target, allies, spellList)
end

return entity
