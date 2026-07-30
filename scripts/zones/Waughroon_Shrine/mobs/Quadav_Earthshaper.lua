-----------------------------------
-- Area: Waughroon Shrine
--  Mob: Quadav Earthshaper
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
    local spellList =
    {
        { xi.magic.spell.QUAKE,       target, false, xi.action.type.DAMAGE_TARGET, nil, 0, 125 },
        { xi.magic.spell.STONE_IV,    target, false, xi.action.type.DAMAGE_TARGET, nil, 0, 100 },
        { xi.magic.spell.STONE_III,   target, false, xi.action.type.DAMAGE_TARGET, nil, 0,  50 },
        { xi.magic.spell.STONEGA_II,  target, false, xi.action.type.DAMAGE_TARGET, nil, 0,  75 },
        { xi.magic.spell.STONEGA_III, target, false, xi.action.type.DAMAGE_TARGET, nil, 0, 100 },
    }

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

return entity
