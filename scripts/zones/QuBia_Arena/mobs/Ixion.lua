-----------------------------------
-- Area: Qu'Bia Arena
--  Mob: Ixion
-- KSNM: Ride the Lightning
-----------------------------------
require('scripts/globals/dark_ixion')
-----------------------------------

local tuning =
{
    level                 =     85,
    hpBonus               =  -9000,
    attackBonus           =      0,
    defenseBonus          =      0,
    accuracyBonus         =     30,
    evasionBonus          =    -10,
    magicAttackBonus      =      0,
    regain                =     20,
    physicalDamageTaken   =      0, -- -2500 is -25%, etc
    rangedDamageTaken     =      0,
    breathDamageTaken     =      0,
    magicDamageTaken      =      0,
}

---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.darkixion.onMobInitialize(mob)
end

entity.onMobSpawn = function(mob)
    xi.darkixion.onBattlefieldMobSpawn(mob)

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

    mob:setMod(xi.mod.THUNDER_SDT, -4000)
    mob:setMod(xi.mod.THUNDER_RES_RANK, 10)
    mob:setMod(xi.mod.ICE_SDT, 1000)

    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)
    mob:setMod(xi.mod.SLOW_RES_RANK, 8)

    mob:setHP(mob:getMaxHP())
end

entity.onCriticalHit = function(mob, attacker)
    xi.darkixion.onCriticalHit(mob, attacker)
end

entity.onWeaponskillHit = function(mob, attacker, weaponskill)
    xi.darkixion.onWeaponskillHit(mob, attacker, weaponskill)
end

entity.onMobWeaponSkill = function(mob, target, skill, action)
    xi.darkixion.onMobWeaponSkill(target, mob, skill)
end

entity.onMobEngage = function(mob, target)
    xi.darkixion.onBattlefieldMobEngage(mob, target)
end

entity.onMobDisengage = function(mob)
    xi.darkixion.onBattlefieldMobDisengage(mob)
end

entity.onMobFight = function(mob, target)
    xi.darkixion.onMobFight(mob, target)
end

entity.onMobDeath = function(mob, player, optParams)
    xi.darkixion.hitLists[mob:getID()] = nil
end

entity.onMobDespawn = function(mob)
    xi.darkixion.hitLists[mob:getID()] = nil
end

return entity
