require('modules/module_utils')

local m = Module:new('eres')
m:setEnabled(true)

m:addOverride('xi.zones.Tahrongi_Canyon.Zone.onInitialize', function(zone)
    super(zone)
    print('[eres] onInitialize fired')

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Eres',
        groupId     = 51,
        groupZoneId = 45,
        x           = -470.8,
        y           = -39.7,
        z           = -160.2,
        rotation    = 160,
        minLevel    = 90,
        maxLevel    = 90,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobSpawn = function(mob)
            mob:setLocalVar('CUSTOM_DROP_DONE', 0)
            mob:addImmunity(xi.immunity.GRAVITY)
            mob:addImmunity(xi.immunity.BIND)
            mob:addImmunity(xi.immunity.LIGHT_SLEEP)
            mob:addImmunity(xi.immunity.TERROR)
            mob:addMod(xi.mod.SILENCERES, 20)
            mob:addMod(xi.mod.STATUSRES, 10)
            mob:setMaxHP(75000)
            mob:setHP(75000)
            mob:setMP(15000)
            mob:setModelSize(2)
            mob:addMod(xi.mod.REGAIN, 75)
            mob:addMod(xi.mod.ATT, 200)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MODIFIER, 75)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
            mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
            mob:addMod(xi.mod.MATT, 25)
            mob:setMobMod(xi.mobMod.MAGIC_COOL, 30)
            mob:setMobAbilityEnabled(true)
            mob:setMagicCastingEnabled(true)
            end,

            onMobMobskillChoose = function(mob, target, skillId)
         local skills =
        {
            xi.mobSkill.HELLCLAP,
            xi.mobSkill.HELLSNAP,
            xi.mobSkill.HELLSTORM,
            xi.mobSkill.HELL_SCISSORS,
            xi.mobSkill.SPIRAL_HELL,
            
        }

            return skills[math.randomInt(1, #skills)]
        end,

           onMobFight = function(mob, target)
            if mob:getHPP() < 20 then
                mob:setMobMod(xi.mobMod.SPELL_LIST, 155)
            elseif mob:getHPP() < 50 then
                mob:setMobMod(xi.mobMod.SPELL_LIST, 154)
            else
                mob:setMobMod(xi.mobMod.SPELL_LIST, 153)
            end
        end,

        onMobDeath = function(mob, player, optParams, target)
            if mob:getLocalVar('CUSTOM_DROP_DONE') == 1 then
                return
            end

            mob:setLocalVar('CUSTOM_DROP_DONE', 1)

            if player == nil then
                return
            end

            -- drops here
        end,

        onMobDespawn = function(mob)
            local RESPAWN_DELAY = math.randomInt(50000, 60000)

            mob:timer(RESPAWN_DELAY, function(mobArg)
                mobArg:setSpawn(-470.732, -39.698, -160.194, 160)
                mobArg:spawn()
            end)

            print(string.format('[Eres] Respawn in %.2f minutes', RESPAWN_DELAY / 60000))
        end,
    })

    mob:setSpawn(-470.732, -39.698, -160.194, 160)
    mob:spawn()
end)

return m