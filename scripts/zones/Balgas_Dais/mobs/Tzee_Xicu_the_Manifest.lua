-----------------------------------
-- Area: Balga's Dais
--  Mob: Tzee Xicu the Manifest
-- KSNM: Wing and a Prayer
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
}
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
    auraPhysicalReduction = -5000,
    auraReturnTime        = 600,
}

---@type TMobEntity
local entity = {}

local function enableAura(mob)
    if not mob:hasStatusEffect(xi.effect.COLURE_ACTIVE) then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.WEIGHT, subPower = 50, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
    end

    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken + tuning.auraPhysicalReduction)
end

local function disableAura(mob)
    mob:delStatusEffectSilent(xi.effect.COLURE_ACTIVE)
    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken)
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
    mob:setMod(xi.mod.AURA_SIZE, -125)
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
    mob:setMod(xi.mod.UDMGRANGE, tuning.rangedDamageTaken)
    mob:setMod(xi.mod.UDMGBREATH, tuning.breathDamageTaken)
    mob:setMod(xi.mod.UDMGMAGIC, tuning.magicDamageTaken)
    mob:setMobMod(xi.mobMod.SKILL_LIST, 2100)
    mob:setLocalVar('auraPhase', 0)
    mob:setLocalVar('auraReturn', 0)
    mob:setHP(mob:getMaxHP())

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.ASTRAL_FLOW_1, cooldown = 180, hpp = 75 },
        },
    })

    enableAura(mob)
end

entity.onMobFight = function(mob, target)
    local auraPhase = mob:getLocalVar('auraPhase')

    if
        auraPhase == 0 and
        mob:getHPP() <= 70
    then
        disableAura(mob)
        mob:setLocalVar('auraPhase', 1)
        mob:setLocalVar('auraReturn', GetSystemTime() + tuning.auraReturnTime)
    elseif
        auraPhase == 1 and
        GetSystemTime() >= mob:getLocalVar('auraReturn')
    then
        enableAura(mob)
        mob:setLocalVar('auraPhase', 2)
    end
end

entity.onAdditionalEffect = function(mob, target, damage)
    local params =
    {
        chance   = 25,
        effectId = xi.effect.PARALYSIS,
        power    = 20,
        duration = 60,
    }

    return xi.combat.action.executeAddEffectEnfeeblement(mob, target, params)
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.ENDER_OF_IDOLATRY)
    end
end

return entity
