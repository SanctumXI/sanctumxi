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
    level                   = 80,
    hpBonus                 = 0,
    attackBonus             = 0,
    defenseBonus            = 0,
    accuracyBonus           = 30,
    evasionBonus            = 0,
    magicAttackBonus        = 0,
    baseDamageMultiplier    = 163,
    barofieldFTPHundredths  = 520,
    barofieldHastePower     = 1500,
    barofieldHasteDuration  = 120,
    headBreakDamage         = 1500,
    headRegrowSeconds       = 60,
    blastMagicAccuracyBonus = 150,
    regen                   = 25,
    regain                  = 25,
    physicalDamageTaken     = 0,
    rangedDamageTaken       = 0,
    breathDamageTaken       = 0,
    magicDamageTaken        = 0,
}

local tremblingThresholds = { 75, 50, 25 }

---@type TMobEntity
local entity = {}

local function tryThresholdTrembling(mob)
    local phase     = mob:getLocalVar('tremblingPhase') + 1
    local threshold = tremblingThresholds[phase]

    if
        threshold and
        mob:getHPP() <= threshold and
        mob:canChangeState() and
        mob:actionQueueEmpty()
    then
        mob:setLocalVar('tremblingPhase', phase)
        mob:setLocalVar('[MobSkill]NoTPCost', xi.mobSkill.TREMBLING)
        mob:useMobAbility(xi.mobSkill.TREMBLING)
    end
end

local function updateHeadBonuses(mob)
    local brokenHeads  = mob:getAnimationSub()
    local previousState = mob:getLocalVar('previousBrokenHeads')
    local intactHeads   = 3 - brokenHeads
    local multiplier  = math.max(0, intactHeads) * 0.75

    if brokenHeads ~= previousState then
        if brokenHeads == 0 then
            mob:setLocalVar('forcePyricBlast', 1)
        elseif brokenHeads == 1 then
            mob:setLocalVar('forcePolarBlast', 1)
        end
    end

    mob:setLocalVar('previousBrokenHeads', brokenHeads)
    mob:setMod(xi.mod.REGEN, math.floor(tuning.regen * multiplier))
    mob:setMod(xi.mod.REGAIN, math.floor(tuning.regain * multiplier))
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
end

entity.onMobSpawn = function(mob)
    mob:renameEntity('Typhon', true)

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
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, tuning.baseDamageMultiplier)
    mob:setLocalVar('BarofieldFTP', tuning.barofieldFTPHundredths)
    mob:setLocalVar('headBreakDamageThreshold', tuning.headBreakDamage)
    mob:setLocalVar('headRegrowMin', tuning.headRegrowSeconds)
    mob:setLocalVar('headRegrowMax', tuning.headRegrowSeconds)
    mob:setLocalVar('headgrow1', 0)
    mob:setLocalVar('headgrow2', 0)
    mob:setLocalVar('HydraBlastMacc', tuning.blastMagicAccuracyBonus)
    mob:setLocalVar('forcePyricBlast', 1)
    mob:setLocalVar('forcePolarBlast', 0)
    mob:setLocalVar('previousBrokenHeads', 0)
    mob:setLocalVar('tremblingPhase', 0)
    mob:setLocalVar('[MobSkill]NoTPCost', 0)
    mob:setHP(mob:getMaxHP())

    updateHeadBonuses(mob)
end

entity.onMobEngage = function(mob, target)
    updateHeadBonuses(mob)
end

entity.onMobFight = function(mob, target)
    updateHeadBonuses(mob)
    tryThresholdTrembling(mob)
end

entity.onCriticalHit = function(mob, attacker)
    xi.mixin.hydra.onCriticalHit(mob)
end

entity.onMobMobskillChoose = function(mob, target, skillId)
    local brokenHeads = mob:getAnimationSub()
    local isBlast     = skillId == xi.mobSkill.PYRIC_BLAST or skillId == xi.mobSkill.POLAR_BLAST

    if brokenHeads == 0 and mob:getLocalVar('forcePyricBlast') == 1 then
        mob:setLocalVar('forcePyricBlast', 0)
        mob:setLocalVar('nextHydraBlast', 1)
        return xi.mobSkill.PYRIC_BLAST
    elseif brokenHeads == 1 and mob:getLocalVar('forcePolarBlast') == 1 then
        mob:setLocalVar('forcePolarBlast', 0)
        return xi.mobSkill.POLAR_BLAST
    end

    if not isBlast then
        return skillId
    end

    if brokenHeads == 0 then
        if mob:getLocalVar('nextHydraBlast') == 0 then
            mob:setLocalVar('nextHydraBlast', 1)
            return xi.mobSkill.PYRIC_BLAST
        end

        mob:setLocalVar('nextHydraBlast', 0)
        return xi.mobSkill.POLAR_BLAST
    elseif brokenHeads == 1 then
        return xi.mobSkill.POLAR_BLAST
    end

    return xi.mobSkill.BAROFIELD
end

entity.onMobWeaponSkill = function(mob, target, skill, action)
    if skill:getID() == xi.mobSkill.BAROFIELD then
        mob:addStatusEffect(xi.effect.HASTE, { power = tuning.barofieldHastePower, duration = tuning.barofieldHasteDuration, origin = mob })
    end
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.HYDRA_HEADHUNTER)
    end
end

return entity
