require('modules/module_utils')

local m = Module:new('sanctum_jeishu')
m:setEnabled(true)

m:addOverride('xi.zones.La_Theine_Plateau.Zone.onInitialize', function(zone)
    super(zone)
    print('[Jeishu] onInitialize fired')

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Jeishu',
        groupId     = 57,
        groupZoneId = 289,
        x           = -834.1,
        y           = 16.6,
        z           = 449.2,
        rotation    = 241,
        minLevel    = 90,
        maxLevel    = 90,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobSpawn = function(mob)
            mob:setLocalVar('CUSTOM_DROP_DONE', 0)
            mob:addImmunity(xi.immunity.GRAVITY)
            mob:addImmunity(xi.immunity.BIND)
            mob:addImmunity(xi.immunity.BLIND)
            mob:addImmunity(xi.immunity.LIGHT_SLEEP)
            mob:addImmunity(xi.immunity.DARK_SLEEP)
            mob:addImmunity(xi.immunity.TERROR)
            mob:setMaxHP(45000)
            mob:setHP(45000)
            mob:setMP(10000)
            mob:setMod(xi.mod.DOUBLE_ATTACK, 30)
            mob:addMod(xi.mod.ATT, 150)
            mob:addMod(xi.mod.REGAIN, 100)
            mob:addMod(xi.mod.MATT, 175)
            mob:setMobMod(xi.mobMod.MAGIC_COOL, 20)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)
            mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
            mob:setMobAbilityEnabled(true)
            mob:setLocalVar('ADDS_75', 0)
            mob:setLocalVar('ADDS_50', 0)
            mob:setLocalVar('ADDS_25', 0)
        end,

        onMobFight = function(mob, target)
            local function spawnAdds(phaseName, hpPercent, addCount)
                if mob:getHPP() > hpPercent then
                    return
                end

                local varName = 'ADDS_' .. phaseName
                if mob:getLocalVar(varName) == 1 then
                    return
                end

                mob:setLocalVar(varName, 1)

                local zone = mob:getZone()
                local x    = mob:getXPos()
                local y    = mob:getYPos()
                local z    = mob:getZPos()
                local r    = mob:getRotPos()

                for i = 1, addCount do
                    local angle    = ((i - 1) / addCount) * math.pi * 2
                    local distance = 4

                    local spawnX = x + math.cos(angle) * distance
                    local spawnY = y
                    local spawnZ = z + math.sin(angle) * distance

                    local add = zone:insertDynamicEntity({
                        objtype     = xi.objType.MOB,
                        name        = 'Protector',
                        groupId     = 3,
                        groupZoneId = 155,
                        x           = spawnX,
                        y           = spawnY,
                        z           = spawnZ,
                        rotation    = r,
                        minLevel    = 85,
                        maxLevel    = 85,
                        releaseIdOnDisappear = true,

                        onMobSpawn = function(addMob)
                            addMob:setMaxHP(5000)
                            addMob:setHP(5000)
                            addMob:setMaxMP(2000)
                            addMob:setMP(2000)
                            addMob:setDropID(0)
                            addMob:addMod(xi.mod.REGAIN, 150)
                            addMob:setMobMod(xi.mobMod.NO_DROPS, 1)
                            addMob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
                            addMob:addMod(xi.mod.MATT, 75)
                            addMob:setMobMod(xi.mobMod.MAGIC_COOL, 25)
                            addMob:setMobAbilityEnabled(true)
                            addMob:setMagicCastingEnabled(true)
                            addMob:setMobMod(xi.mobMod.SUPERLINK, mob:getTargID())
                        end,

                        onMobMobskillChoose = function(mob, target, skillId)
                            local skills =
                            {
                                xi.mobSkill.DARK_NOVA,
                                xi.mobSkill.DISPELLING_WIND,
                            }

                            return skills[math.randomInt(1, #skills)]
                        end,

                        onMobSpellChoose = function(mob, target, spellId)
                            local spellList =
                        {

                        [ 1] = { xi.magic.spell.BLIZZARD_IV, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
                        [ 2] = { xi.magic.spell.FREEZE_II,  target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
                        [ 3] = { xi.magic.spell.SILENCEGA, target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SILENCE,   0, 100 },
                        [ 4] = { xi.magic.spell.GRAVIGA,   target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.WEIGHT,    0, 100 },
                        [ 5] = { xi.magic.spell.BLIZZAGA_III, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
                        [ 6] = { xi.magic.spell.BLIZZARD_III, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },

                        }

    if target:hasStatusEffectByFlag(xi.effectFlag.DISPELABLE) then
        table.insert(spellList, #spellList + 1, { xi.magic.spell.DISPELGA, target, false, xi.action.type.NONE, nil, 0, 100 })
    end

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end,

                        onMobDeath = function(addMob)
                            addMob:setLocalVar('DEAD', 1)
                        end,
                    })

                    if add then
                        add:setSpawn(spawnX, spawnY, spawnZ, r)
                        add:spawn()

                        if target then
                            add:updateEnmity(target)
                        end
                    end
                end
            end

            spawnAdds('75', 75, 1)
            spawnAdds('50', 50, 2)
            spawnAdds('25', 25, 3)
        end,

        onMobMobskillChoose = function(mob, target, skillId)
            local skills =
            {
                xi.mobSkill.DARK_NOVA,
                xi.mobSkill.PYRIC_BLAST,
                xi.mobSkill.WING_THRUST,
                xi.mobSkill.DISPELLING_WIND,

            }

            return skills[math.randomInt(1, #skills)]
        end,

        onMobDeath = function(mob, player, optParams, target)
            if mob:getLocalVar('CUSTOM_DROP_DONE') == 1 then
                return
            end

            mob:setLocalVar('CUSTOM_DROP_DONE', 1)

            if player == nil then
                return
            end

            local th = mob:getTHlevel() or 0

            local function rollDrop(itemId, baseChance)
                local finalChance = math.min(baseChance + th * 2, 100)

                if math.randomInt(1, 100) <= finalChance then
                    player:addTreasure(itemId, mob)
                end
            end

            rollDrop(11501, 10)
            rollDrop(11354, 5)
            rollDrop(19048, 50)
            rollDrop(1461, 15)
            rollDrop(19163, 20)
            rollDrop(902, 100)
            rollDrop(886, 100)
            rollDrop(11543, 30)
            rollDrop(11578, 30)
        end,

        onMobDespawn = function(mob, player, optParams)
            local RESPAWN_DELAY = math.randomInt(50000, 60000)

            mob:timer(RESPAWN_DELAY, function(mob)
                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(-834.074, 16.628, 449.167, 241)
                mob:spawn()
            end)

            print(string.format('[JEISHU] Respawn in %.2f minutes', RESPAWN_DELAY / 60000))
        end,
    })

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(-834.074, 16.628, 449.167, 241) -- !pos -834.074 16.628 449.167 102
    mob:spawn()
end)

return m
