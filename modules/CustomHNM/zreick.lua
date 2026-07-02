require('modules/module_utils')

local m = Module:new('zreick')
m:setEnabled(true)

m:addOverride('xi.zones.Konschtat_Highlands.Zone.onInitialize', function(zone)
    super(zone)
    print('[Zreick] onInitialize fired')

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Zreick',
        groupId     = 34,
        groupZoneId = 191,
        x           = 467.8,
        y           = -15.7,
        z           = -441.2,
        rotation    = 163,
        minLevel    = 90,
        maxLevel    = 90,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobSpawn = function(mob)
            mob:setLocalVar('CUSTOM_DROP_DONE', 0)
            mob:addImmunity(xi.immunity.GRAVITY)
            mob:addImmunity(xi.immunity.BIND)
            mob:addMod(xi.mod.SILENCERES, 50)
            mob:addMod(xi.mod.STATUSRES, 100)
            mob:addImmunity(xi.immunity.LIGHT_SLEEP)
            mob:addImmunity(xi.immunity.DARK_SLEEP)
            mob:addImmunity(xi.immunity.TERROR)
            mob:setMaxHP(50000)
            mob:setHP(50000)
            mob:addMod(xi.mod.REGAIN, 75)
            mob:setMobMod(xi.mobMod.WEAPON_BONUS, 35) 
            mob:addMod(xi.mod.ATT, 150)
             mob:addMod(xi.mod.MATT, 175)
            mob:setMobMod(xi.mobMod.MAGIC_COOL, 30)
            mob:setModelSize(1.2)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 175)
            mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
            mob:setMobAbilityEnabled(true)
            mob:setMagicCastingEnabled(true)
            
        end,

        onMobMobskillChoose = function(mob, target, skillId)
         local skills =
        {
            xi.mobSkill.RAZOR_FANG_2,
            xi.mobSkill.WINDS_OF_OBLIVION,
            xi.mobSkill.IMPACT_STREAM,
            xi.mobSkill.MEDUSA_JAVELIN,
            xi.mobSkill.POLAR_BLAST,
            
        }

            return skills[math.random(1, #skills)]
        end,

        onMobSpellChoose = function(mob, target, spellId)
         local spellList =
    {
        [ 1] = { xi.magic.spell.BLIZZARD_V,    target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 2] = { xi.magic.spell.BLIZZARD_IV, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 3] = { xi.magic.spell.FREEZE_II,  target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 4] = { xi.magic.spell.CURE_V,    mob,    false, xi.action.type.HEALING_TARGET,       50,                  0, 100 },
        [ 5] = { xi.magic.spell.SILENCEGA, target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SILENCE,   0, 100 },
        [ 6] = { xi.magic.spell.GRAVIGA,   target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.WEIGHT,    0, 100 },
        [ 7] = { xi.magic.spell.BLIZZAGA_IV, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 8] = { xi.magic.spell.BLIZZAGA_III, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 9] = { xi.magic.spell.BLIZZARD_III, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 10] = { xi.magic.spell.FREEZE, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
    }

    if target:hasStatusEffectByFlag(xi.effectFlag.DISPELABLE) then
        table.insert(spellList, #spellList + 1, { xi.magic.spell.DISPELGA, target, false, xi.action.type.NONE, nil, 0, 100 })
    end

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end,

        onMobDeath = function(mob, player, optParams, target)
      if mob:getLocalVar('CUSTOM_DROP_DONE') == 1 then
        return
    end

    mob:setLocalVar('CUSTOM_DROP_DONE', 1)

    if player == nil then
        return
    end

    local th = mob:getTHlevel() or 0 -- LSB usually tracks TH on the mob

    local function rollDrop(itemId, baseChance)
    local finalChance = math.min(baseChance + th *2, 100)

        if math.random(1, 100) <= finalChance then
            player:addTreasure(itemId, mob)
        end
    end

    -- itemId, base chance %
    rollDrop(658, 10)
    rollDrop(15859, 5)
    rollDrop(1313, 50)
    rollDrop(16113, 15)
    rollDrop(15918, 20)
    rollDrop(747, 100)
    rollDrop(646, 100)
    rollDrop(11359, 30)
        end,

        onMobDespawn = function(mob, player, optParams)

            local RESPAWN_DELAY = math.random(50000, 60000) -- 18 - 22 hrs

            mob:timer(RESPAWN_DELAY, function(mob)
                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(467.732, -15.698, -441.194, 163)
                mob:spawn()
            end)

            print(string.format('[Zreick] Respawn in %.2f minutes', RESPAWN_DELAY / 60000))
            
            end,
              
    })
    -- Spawn on zone/server initialize
    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(467.732, -15.698, -441.194, 163)
    mob:spawn()
end)

return m