require('modules/module_utils')

local m = Module:new('weirdo')
m:setEnabled(true)

local spawnRadius = 20
local minLevel = 34
local maxLevel = 44
local weirdoSpawns =
{
    {
        label    = 'Weirdo_1',
        x        = -86.44,
        y        = -38.75,
        z        = 40.08,
        rotation = 0,
    },

    {
        label    = 'Weirdo_2',
        x        = -92.76, 
        y        = -37.41,
        z        = 226.58, 
        rotation = 0,
    },
}

local function getRandomSpawn(center)
    local angle = math.random() * math.pi * 2
    local distance = math.random() * spawnRadius

    local x = center.x + math.cos(angle) * distance
    local z = center.z + math.sin(angle) * distance

    return x, center.y, z, center.rotation
end

local function setupWeirdo(zone, spawnData)
    local thisSpawn = spawnData

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Weirdo',
        groupId     = 1,
        groupZoneId = 137,

        x        = spawnData.x,
        y        = spawnData.y,
        z        = spawnData.z,
        rotation = spawnData.rotation,

        minLevel = 43,
        maxLevel = 44,

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
            mob:setMaxHP(4000)
            mob:setHP(4000)
            mob:setModelSize(3)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)
            mob:setMobMod(xi.mobMod.NO_AGGRO, 1)
            mob:setDropID(0)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)

            print(string.format(
                '[%s] Spawned at X: %.2f Y: %.2f Z: %.2f',
                thisSpawn.label,
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
                local bonusExp = 1250 * #eligibleMembers

                    player:addExp(bonusExp)
               
            else
                player:printToPlayer(
                    'A party member is outside the level range of 34-44. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
            end
        end,

        onMobDespawn = function(mob)
            local RESPAWN_DELAY = math.random(1800000, 3600000) -- 30 to 60 minutes

            mob:timer(RESPAWN_DELAY, function(mob)
                local x, y, z, rot = getRandomSpawn(thisSpawn)

                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(x, y, z, rot)

                print(string.format(
                    '[%s] Respawning at X: %.2f Y: %.2f Z: %.2f',
                    thisSpawn.label,
                    x,
                    y,
                    z
                ))

                mob:spawn()
            end)

            print(string.format(
                '[%s] Respawn in %.2f minutes',
                thisSpawn.label,
                RESPAWN_DELAY / 60000
            ))
        end,
    })

    if mob == nil then
        print(string.format('[%s] Failed to insert dynamic entity.', spawnData.label))
        return
    end

    local x, y, z, rot = getRandomSpawn(spawnData)

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(x, y, z, rot)

    print(string.format(
        '[%s] Initial spawn at X: %.2f Y: %.2f Z: %.2f',
        spawnData.label,
        x,
        y,
        z
    ))

    mob:spawn()
end

m:addOverride('xi.zones.Gusgen_Mines.Zone.onInitialize', function(zone)
    super(zone)

    print('[weirdo] onInitialize fired')

    for _, spawnData in ipairs(weirdoSpawns) do
        setupWeirdo(zone, spawnData)
    end
end)

return m