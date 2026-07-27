-----------------------------------
-- Area: Waughroon Shrine
--  Mob: Ro'Hyu Blackanvil
-- KSNM: Heavy Is the Shell
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
}

---@type TMobEntity
local entity = {}

local function applySlowAura(mob)
    if not mob:hasStatusEffect(xi.effect.COLURE_ACTIVE) then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.SLOW, subPower = 5000, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
    end
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.GRAVITY)
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
    mob:setMobMod(xi.mobMod.SKILL_LIST, 2098)
    mob:setHP(mob:getMaxHP())

    xi.mix.jobSpecial.config(mob, {
        between = 5,
        specials =
        {
            { id = xi.mobSkill.MIGHTY_STRIKES_1, hpp = 80 },
            { id = xi.mobSkill.MIGHTY_STRIKES_1, hpp = 40 },
            { id = xi.mobSkill.MIGHTY_STRIKES_1, hpp = 5 },
        },
    })

    applySlowAura(mob)
end

entity.onMobFight = function(mob, target)
    applySlowAura(mob)

    if mob:getHPP() <= 40 then
        mob:setMobMod(xi.mobMod.SKILL_LIST, 2099)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.DISPERSER_OF_DARKNESS)
    end
end

return entity
