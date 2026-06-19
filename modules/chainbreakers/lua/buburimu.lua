require('modules/module_utils')

local m = Module:new('crawler_king')
m:setEnabled(true)

local spawnCenter =
{
    x = 535.92,
    y = 0.15,
    z = -245.97,
    rotation = 1,
}

local spawnRadius = 35
local minLevel = 14
local maxLevel = 24

local function getRandomSpawn()
    local angle = math.random() * math.pi * 2
    local distance = math.random() * spawnRadius

    local x = spawnCenter.x + math.cos(angle) * distance
    local z = spawnCenter.z + math.sin(angle) * distance

    return x, spawnCenter.y, z, spawnCenter.rotation
end


m:addOverride('xi.zones.Buburimu_Peninsula.Zone.onInitialize', function(zone)
    super(zone)
    print('[crawler_king] onInitialize fired')

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Crawler King',
        groupId     = 42,
        groupZoneId = 48,
        x           = spawnCenter.x,
        y           = spawnCenter.y,
        z           = spawnCenter.z,
        rotation    = spawnCenter.rotation,
        minLevel    = 24,
        maxLevel    = 24,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobInitialize = function(mob)
                -- VISUAL SIZE:
            mob:setModelSize(5)

            -- PHYSICAL HITBOX:
            local baseHitbox = mob:getHitboxSize()

            if baseHitbox <= 0 then
                baseHitbox = 5.0
        end
            mob:setHitboxSize(baseHitbox * 2.0)
        end,

        onMobSpawn = function(mob)
            mob:setMaxHP(2500)
            mob:setHP(2500)
            mob:setModelSize(5)
            mob:setMobFlags(mob:getMobFlags())
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)
            mob:setMobMod(xi.mobMod.NO_AGGRO, 1)
            
            print(string.format(
                '[crawler_king] Spawned at X: %.2f Y: %.2f Z: %.2f',
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
                local bonusExp = 500 * #eligibleMembers
                
                    player:addExp(bonusExp)
                                    
            else
                player:printToPlayer(
                    'A party member is outside the level range of 14-24. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
            end   
        end,
             
        onMobDespawn = function(mob)
            local RESPAWN_DELAY = math.random(1800000, 3600000) -- 30 to 60 minutes

            mob:timer(RESPAWN_DELAY, function(mob)
                local x, y, z, rot = getRandomSpawn()

                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)

                mob:setSpawn(x, y, z, rot)

                print(string.format(
                    '[crawler_king] Respawning at X: %.2f Y: %.2f Z: %.2f',
                    x, y, z
                ))

                mob:spawn()
            end)

            print(string.format('[crawler_king] Respawn in %.2f minutes', RESPAWN_DELAY / 60000))
            
            end,
              
    })
    -- Spawn on zone/server initialize
    local x, y, z, rot = getRandomSpawn()

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)

    mob:setSpawn(x, y, z, rot)

    print(string.format(
        '[crawler_king] Initial spawn at X: %.2f Y: %.2f Z: %.2f',
        x, y, z
    ))

    mob:spawn()
end)

return m