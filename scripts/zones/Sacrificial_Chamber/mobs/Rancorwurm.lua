-----------------------------------
-- Area: Sacrificial Chamber
--  Mob: Rancorwurm
-- KSNM: The Ravening Worm
-----------------------------------
require('scripts/globals/sandworm')
-----------------------------------

local tuning =
{
    level                 = 85,
    hpBonus               = 0,
    attackBonus           = 0,
    defenseBonus          = 0,
    accuracyBonus         = 0,
    evasionBonus          = 0,
    magicAttackBonus      = 0,
    regain                = 20,
    physicalDamageTaken   = 0,
    rangedDamageTaken     = 0,
    breathDamageTaken     = 0,
    magicDamageTaken      = 0,
}

---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.sandworm.onMobInitialize(mob)
end

entity.onMobSpawn = function(mob)
    if mob:getMainLvl() ~= tuning.level then
        mob:setMobLevel(tuning.level)
    end

    mob:addMod(xi.mod.HP, tuning.hpBonus)
    mob:addMod(xi.mod.ATT, tuning.attackBonus)
    mob:addMod(xi.mod.DEF, tuning.defenseBonus)
    mob:addMod(xi.mod.ACC, tuning.accuracyBonus)
    mob:addMod(xi.mod.EVA, tuning.evasionBonus)
    mob:addMod(xi.mod.MATT, tuning.magicAttackBonus)
    mob:setMod(xi.mod.REGAIN, tuning.regain)
    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken)
    mob:setMod(xi.mod.UDMGRANGE, tuning.rangedDamageTaken)
    mob:setMod(xi.mod.UDMGBREATH, tuning.breathDamageTaken)
    mob:setMod(xi.mod.UDMGMAGIC, tuning.magicDamageTaken)

    -- Subterranean sandworm: strongly resists Earth, slightly weak to its opposite (Wind).
    mob:setMod(xi.mod.EARTH_SDT, 4000)
    mob:setMod(xi.mod.EARTH_RES_RANK, 10)
    mob:setMod(xi.mod.WIND_SDT, -1000)

    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200) -- +100% physical damage output
    mob:setHP(mob:getMaxHP())
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.SANDWORM_WRANGLER)
    end
end

return entity
