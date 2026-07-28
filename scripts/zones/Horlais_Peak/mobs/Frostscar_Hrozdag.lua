-----------------------------------
-- Area: Horlais Peak
--  Mob: Frostscar Hrozdag
-- KSNM: King of The North
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
}
-----------------------------------

local tuning =
{
    level                    = 85,
    hpBonus                  = 0,
    attackBonus              = 0,
    defenseBonus             = 0,
    accuracyBonus            = 30,
    evasionBonus             = 0,
    magicAttackBonus         = 0,
    regain                   = 20,
    physicalDamageTaken      = 0,
    rangedDamageTaken        = 0,
    breathDamageTaken        = 0,
    magicDamageTaken         = 0,
    auraDefenseBonus         = 200,
    auraMagicDefenseBonus    = 100,
    minionDefeatAttackBonus  = 15,
    auraReturnTime           = 600,
}

---@type TMobEntity
local entity = {}

local function enableAura(mob)
    if mob:getLocalVar('auraActive') == 0 then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.FLASH, subPower = 100, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
        mob:addMod(xi.mod.DEF, tuning.auraDefenseBonus)
        mob:addMod(xi.mod.MDEF, tuning.auraMagicDefenseBonus)
        mob:setLocalVar('auraActive', 1)
    end
end

local function disableAura(mob)
    if mob:getLocalVar('auraActive') == 1 then
        mob:delStatusEffectSilent(xi.effect.COLURE_ACTIVE)
        mob:delMod(xi.mod.DEF, tuning.auraDefenseBonus)
        mob:delMod(xi.mod.MDEF, tuning.auraMagicDefenseBonus)
        mob:setLocalVar('auraActive', 0)
    end
end

local function breakAura(mob)
    if mob:getLocalVar('auraPhase') == 0 then
        disableAura(mob)
        mob:setLocalVar('auraPhase', 1)
        mob:setLocalVar('auraReturn', GetSystemTime() + tuning.auraReturnTime)
    end
end

local function updateMinionBonus(mob)
    local battlefield = mob:getBattlefield()
    if not battlefield then
        return
    end

    local defeated = 0
    for _, ally in pairs(battlefield:getMobs(true, true)) do
        local name = ally:getName()
        if
            (name == 'Siege_Sniper' or name == 'Blackguard') and
            ally:isDead()
        then
            defeated = defeated + 1
        end
    end

    mob:setMod(xi.mod.ATTP, defeated * tuning.minionDefeatAttackBonus)
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
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
    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken)
    mob:setMod(xi.mod.UDMGRANGE, tuning.rangedDamageTaken)
    mob:setMod(xi.mod.UDMGBREATH, tuning.breathDamageTaken)
    mob:setMod(xi.mod.UDMGMAGIC, tuning.magicDamageTaken)

    mob:setMod(xi.mod.ICE_SDT, -4000)
    mob:setMod(xi.mod.ICE_RES_RANK, 10)
    mob:setMod(xi.mod.FIRE_SDT, 1000)

    mob:setMod(xi.mod.SLOW_RES_RANK, 8)
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)

    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
    mob:setMod(xi.mod.DOUBLE_ATTACK, 40)
    mob:setMod(xi.mod.CRITHITRATE, 10)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 2101)
    mob:setLocalVar('auraActive', 0)
    mob:setLocalVar('auraPhase', 0)
    mob:setLocalVar('auraReturn', 0)
    mob:setHP(mob:getMaxHP())

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            {
                id       = xi.mobSkill.MIGHTY_STRIKES_1,
                cooldown = 180,
                hpp      = 80,
                begCode  = breakAura,
            },
        },
    })

    enableAura(mob)
end

entity.onMobFight = function(mob, target)
    updateMinionBonus(mob)

    if mob:getLocalVar('auraPhase') == 0 and mob:getHPP() <= 75 then
        breakAura(mob)
    elseif
        mob:getLocalVar('auraPhase') == 1 and
        GetSystemTime() >= mob:getLocalVar('auraReturn')
    then
        enableAura(mob)
        mob:setLocalVar('auraPhase', 2)
    end
end

entity.onMobWeaponSkill = function(target, mob, skill)
    if skill:getID() == xi.mobSkill.HOWL_ORC then
        local battlefield = mob:getBattlefield()
        if battlefield then
            for _, ally in pairs(battlefield:getMobs(true, true)) do
                if
                    ally:getID() ~= mob:getID() and
                    ally:isAlive() and
                    (ally:getName() == 'Siege_Sniper' or ally:getName() == 'Blackguard')
                then
                    ally:addStatusEffect(xi.effect.WARCRY, { power = 30, origin = mob, duration = 60 })
                end
            end
        end
    end
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.DEBASER_OF_DYNASTIES)
    end
end

return entity
