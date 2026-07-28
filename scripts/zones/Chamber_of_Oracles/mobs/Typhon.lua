-----------------------------------
-- Area: Chamber of Oracles
--  Mob: Typhon
-- KSNM: Three's a Crowd
-----------------------------------
mixins =
{
    require('scripts/mixins/families/hydra'),
}
-----------------------------------

local tuning =
{
    level                 = 80,
    hpBonus               = 0,
    attackBonus           = 0,
    defenseBonus          = 0,
    accuracyBonus         = 30,
    evasionBonus          = 0,
    magicAttackBonus      = 0,
    regen                 = 25,
    regain                = 25,
    physicalDamageTaken   = 0,
    rangedDamageTaken     = 0,
    breathDamageTaken     = 0,
    magicDamageTaken      = 0,
}

---@type TMobEntity
local entity = {}

local function updateHeadBonuses(mob)
    local intactHeads = 2 - mob:getAnimationSub()
    local multiplier  = math.max(0, intactHeads) * 0.75

    mob:setMod(xi.mod.REGEN, math.floor(tuning.regen * multiplier))
    mob:setMod(xi.mod.REGAIN, math.floor(tuning.regain * multiplier))
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
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
    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken)
    mob:setMod(xi.mod.UDMGRANGE, tuning.rangedDamageTaken)
    mob:setMod(xi.mod.UDMGBREATH, tuning.breathDamageTaken)
    mob:setMod(xi.mod.UDMGMAGIC, tuning.magicDamageTaken)

    mob:setMod(xi.mod.WATER_SDT, -3000)
    mob:setMod(xi.mod.WATER_RES_RANK, 8)
    mob:setMod(xi.mod.FIRE_SDT, 1000)
    mob:setMod(xi.mod.THUNDER_SDT, 1500)

    mob:setMod(xi.mod.POISON_RES_RANK, 8)

    mob:setMobMod(xi.mobMod.NO_MOVE, 0)
    mob:setMobMod(xi.mobMod.AOE_HIT_ALL, 1)
    mob:setHP(mob:getMaxHP())

    updateHeadBonuses(mob)
end

entity.onMobEngage = function(mob, target)
    updateHeadBonuses(mob)
end

entity.onMobFight = function(mob, target)
    updateHeadBonuses(mob)
end

entity.onCriticalHit = function(mob, attacker)
    xi.mixin.hydra.onCriticalHit(mob)
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.HYDRA_HEADHUNTER)
    end
end

return entity
