require('modules/module_utils')

local m = Module:new('tzargul')
m:setEnabled(true)

m:addOverride('xi.zones.Meriphataud_Mountains.Zone.onInitialize', function(zone)
    super(zone)
    print('[tzargul] onInitialize fired')

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Tzargul',
        groupId     = 14,
        groupZoneId = 27,
        x           = -642.8,
        y           = 0.0,
        z           = 431.4,
        rotation    = 238,
        minLevel    = 80,
        maxLevel    = 80,
        { 618.877, -8.472, -427.443, 182 }, -- !pos 618.877 -8.472 -427.443 119
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobSpawn = function(mob)
            mob:setMaxHP(22500)
            mob:setHP(22500)
            mob:setModelSize(2.5)
            mob:setMod(xi.mod.DOUBLE_ATTACK, 20)
            mob:setMod(xi.mod.REGEN, 5)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
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

                            if member:getMainLvl() <= 64 then
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
                local bonusExp = 5000 * #eligibleMembers
                
                    player:addExp(bonusExp)
                                    
            else
                player:printToPlayer(
                    'A party member is outside the level range of 65-75. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
            end   
        end,
             
        onMobDespawn = function(mob, player, optParams)

            local RESPAWN_DELAY = math.randomInt(64800000, 79200000) -- 18 - 22 hrs

            mob:timer(RESPAWN_DELAY, function(mob)
                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(642.819, -0.009, -431.412, 238)
                mob:spawn()
            end)

            print(string.format('[tzargul] Respawn in %.2f minutes', RESPAWN_DELAY / 60000))
            
            end,
              
    })
    -- Spawn on zone/server initialize
    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(642.819, -0.009, -431.412, 238)
    mob:spawn()
end)

return m