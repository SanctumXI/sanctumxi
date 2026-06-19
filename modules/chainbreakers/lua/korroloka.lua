require('modules/module_utils')

local m = Module:new('korrolokaxp')
m:setEnabled(true)

local spawnRadius = 8

local function getRandomSpawn(center)
    local angle = math.random() * math.pi * 2
    local distance = math.random() * spawnRadius

    local x = center.x + math.cos(angle) * distance
    local z = center.z + math.sin(angle) * distance

    return x, center.y, z, center.rotation
end

local function setupMonster1(zone)
    local spawn =
    {
        label    = 'Monster1',
        x        = -216.84,
        y        = -5.00,
        z        = 76.35,
        rotation = 251,
    }

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Golden Crab',
        groupId     = 56,
        groupZoneId = 4,

        x        = spawn.x,
        y        = spawn.y,
        z        = spawn.z,
        rotation = spawn.rotation,

        minLevel = 34,
        maxLevel = 34,

        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobInitialize = function(mob)
            mob:setModelSize(3)

            local baseHitbox = mob:getHitboxSize()

            if baseHitbox <= 0 then
                baseHitbox = 5.0
            end

            mob:setHitboxSize(baseHitbox * 2.0)
        end,

        onMobSpawn = function(mob)
            mob:setMaxHP(3500)
            mob:setHP(3500)
            mob:setModelSize(3)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)
            mob:setMobMod(xi.mobMod.NO_AGGRO, 1)
            mob:setDropID(0)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)

            print(string.format(
                '[%s] Spawned at X: %.2f Y: %.2f Z: %.2f',
                spawn.label,
                mob:getXPos(),
                mob:getYPos(),
                mob:getZPos()
            ))
        end,

onMobDeath = function(mob, player, optParams)
            if player == nil then
                return
            end

            local members = player:getParty()
            local minLevel = 24
            local maxLevel = 34

          
            if members == nil or #members < 1 or #members > 6 then
                player:printToPlayer(
                    'Party size is invalid. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
                return
            end

            local eligibleMembers = {}
            local seen = {}
            local allValid = true

            for _, member in ipairs(members) do
                if member ~= nil and member:isPC() then
                    local id = member:getID()

                    if not seen[id] then
                        seen[id] = true

                        if member:getZoneID() == mob:getZoneID() and member:checkDistance(mob) <= 50 then
                            table.insert(eligibleMembers, member)

                            local level = member:getMainLvl()

                            if level < minLevel or level > maxLevel then
                                allValid = false
                            end
                        end
                    end
                end
            end

            if #eligibleMembers == 0 then
                player:printToPlayer(
                    'No eligible party members were in range.',
                    xi.msg.channel.SYSTEM_3
                )
                return
            end

            if allValid then
                local bonusExp = 750 * #eligibleMembers
                
                    player:addExp(bonusExp)
                                    
            else
                player:printToPlayer(
                    'A party member is outside the level range of 24-34. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
            end   
        end,

        onMobDespawn = function(mob)
            local RESPAWN_DELAY = math.random(1800000, 3600000)

            mob:timer(RESPAWN_DELAY, function(mob)
                local x, y, z, rot = getRandomSpawn(spawn)

                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(x, y, z, rot)

                print(string.format(
                    '[%s] Respawning at X: %.2f Y: %.2f Z: %.2f',
                    spawn.label,
                    x,
                    y,
                    z
                ))

                mob:spawn()
            end)

            print(string.format(
                '[%s] Respawn in %.2f minutes',
                spawn.label,
                RESPAWN_DELAY / 60000
            ))
        end,
    })

    if mob == nil then
        print('[Golden_Crab] Failed to insert dynamic entity.')
        return
    end

    local x, y, z, rot = getRandomSpawn(spawn)

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(x, y, z, rot)

    print(string.format(
        '[%s] Initial spawn at X: %.2f Y: %.2f Z: %.2f',
        spawn.label,
        x,
        y,
        z
    ))

    mob:spawn()
end

local function setupMonster2(zone)
    local spawn =
    {
        label    = 'Monster2',
        x        = -442.78,
        y        = -10.00,
        z        = 241.20,
        rotation = 24,
    }

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Mr. Krabs',
        groupId     = 48,
        groupZoneId = 81,

        x        = spawn.x,
        y        = spawn.y,
        z        = spawn.z,
        rotation = spawn.rotation,

        minLevel = 40,
        maxLevel = 40,

        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobInitialize = function(mob)
            mob:setModelSize(4)

            local baseHitbox = mob:getHitboxSize()

            if baseHitbox <= 0 then
                baseHitbox = 5.0
            end

            mob:setHitboxSize(baseHitbox * 2.5)
        end,

        onMobSpawn = function(mob)
            mob:setMaxHP(4500)
            mob:setHP(4500)
            mob:setModelSize(4)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 175)
            mob:setMobMod(xi.mobMod.NO_AGGRO, 1)
            mob:setDropID(0)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)

            print(string.format(
                '[%s] Spawned at X: %.2f Y: %.2f Z: %.2f',
                spawn.label,
                mob:getXPos(),
                mob:getYPos(),
                mob:getZPos()
            ))
        end,

  onMobDeath = function(mob, player, optParams)
            if player == nil then
                return
            end

            local members = player:getParty()
        
            if members == nil or #members < 1 or #members > 6 then
                player:printToPlayer(
                    'Party size is invalid. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
                return
            end

            local eligibleMembers = {}
            local seen = {}
            local allValid = true
            local minlevel = 30
            local maxlevel = 40

            for _, member in ipairs(members) do
                if member ~= nil and member:isPC() then
                    local id = member:getID()

                    if not seen[id] then
                        seen[id] = true

                        if member:getZoneID() == mob:getZoneID() and member:checkDistance(mob) <= 50 then
                            table.insert(eligibleMembers, member)

                            local level = member:getMainLvl()

                            if level < minlevel or level > maxlevel then
                                allValid = false
                            end
                        end
                    end
                end
            end

            if #eligibleMembers == 0 then
                player:printToPlayer(
                    'No eligible party members were in range.',
                    xi.msg.channel.SYSTEM_3
                )
                return
            end

            if allValid then
                local bonusExp = 1250 * #eligibleMembers
                
                    player:addExp(bonusExp)
                                    
            else
                player:printToPlayer(
                    'A party member is outside the level range of 30-40. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
            end   
        end,

        onMobDespawn = function(mob)
            local RESPAWN_DELAY = math.random(1800000, 3600000)

            mob:timer(RESPAWN_DELAY, function(mob)
                local x, y, z, rot = getRandomSpawn(spawn)

                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(x, y, z, rot)

                print(string.format(
                    '[%s] Respawning at X: %.2f Y: %.2f Z: %.2f',
                    spawn.label,
                    x,
                    y,
                    z
                ))

                mob:spawn()
            end)

            print(string.format(
                '[%s] Respawn in %.2f minutes',
                spawn.label,
                RESPAWN_DELAY / 60000
            ))
        end,
    })

    if mob == nil then
        print('[Mr_Krabs] Failed to insert dynamic entity.')
        return
    end

    local x, y, z, rot = getRandomSpawn(spawn)

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(x, y, z, rot)

    print(string.format(
        '[%s] Initial spawn at X: %.2f Y: %.2f Z: %.2f',
        spawn.label,
        x,
        y,
        z
    ))

    mob:spawn()
end

m:addOverride('xi.zones.Korroloka_Tunnel.Zone.onInitialize', function(zone)
    super(zone)

    print('[krabs_module] onInitialize fired')

    setupMonster1(zone)
    setupMonster2(zone)
end)

return m