-----------------------------------
-- Area: Balga's Dais
--  Mob: Tzee Xicu's Hierophant
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
    accuracyBonus         = 30,
    evasionBonus          = 0,
    magicAttackBonus      = 0,
    baseDamageMultiplier  = 125,
    enspellDamageBonus    = 30,
    regain                = 20,
    physicalDamageTaken   = 0,
    rangedDamageTaken     = 0,
    breathDamageTaken     = 0,
    magicDamageTaken      = -5000,
    auraPhysicalReduction = -5000,
    auraReturnTime        = 600,
    auraSize              = -125,
    auraWeightPower       = 50,
    addEffectChance       = 25,
    addEffectPower        = 20,
    addEffectDuration     = 60,
}

---@type TMobEntity
local entity = {}

local function enableAura(mob)
    if not mob:hasStatusEffect(xi.effect.COLURE_ACTIVE) then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.WEIGHT, subPower = tuning.auraWeightPower, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
    end

    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken + tuning.auraPhysicalReduction)
end

local function disableAura(mob)
    mob:delStatusEffectSilent(xi.effect.COLURE_ACTIVE)
    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken)
end

-- Keep this mob's own enmity list in sync with its allies, so the whole pull effectively
-- shares one hate pool
local function syncEnmity(mob)
    local battlefield = mob:getBattlefield()
    if not battlefield then
        return
    end

    for _, ally in pairs(battlefield:getMobs(true, true)) do
        if ally:getID() ~= mob:getID() and ally:isAlive() then
            for _, entry in ipairs(ally:getEnmityList()) do
                if entry.entity then
                    local myCE, myVE = 0, 0
                    for _, mine in ipairs(mob:getEnmityList()) do
                        if mine.entity:getID() == entry.entity:getID() then
                            myCE, myVE = mine.ce, mine.ve
                            break
                        end
                    end

                    local ceDelta = entry.ce - myCE
                    local veDelta = entry.ve - myVE
                    if ceDelta > 0 or veDelta > 0 then
                        mob:addEnmity(entry.entity, math.max(ceDelta, 0), math.max(veDelta, 0))
                    end
                end
            end
        end
    end
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
    mob:setMod(xi.mod.AURA_SIZE, tuning.auraSize)
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
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, tuning.baseDamageMultiplier)

    mob:setMod(xi.mod.SILENCE_RES_RANK, 12)
    mob:setMod(xi.mod.WIND_SDT, -1500)
    mob:setMod(xi.mod.EARTH_SDT, 500)

    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)
    mob:setMod(xi.mod.POISON_RES_RANK, 6)
    mob:setMod(xi.mod.ENSPELL_DMG_BONUS, tuning.enspellDamageBonus)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 2100)
    mob:setLocalVar('auraPhase', 0)
    mob:setLocalVar('auraReturn', 0)
    mob:setHP(mob:getMaxHP())
    mob:setBaseSpeed(55)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.VORTICOSE_SANDS, cooldown = 180, hpp = 75 },
        },
    })

    enableAura(mob)
end

entity.onMobFight = function(mob, target)
    syncEnmity(mob)

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
        chance   = tuning.addEffectChance,
        effectId = xi.effect.PARALYSIS,
        power    = tuning.addEffectPower,
        duration = tuning.addEffectDuration,
    }

    return xi.combat.action.executeAddEffectEnfeeblement(mob, target, params)
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.ENDER_OF_IDOLATRY)
    end

    local battlefield = mob:getBattlefield()
    if battlefield then
        for _, ally in pairs(battlefield:getMobs(true, true)) do
            if ally:getName() == 'Divine_Reproach' and ally:isAlive() then
                ally:setHP(0)
            end
        end
    end
end

return entity
