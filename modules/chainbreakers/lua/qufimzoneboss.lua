require('modules/module_utils')

local m = Module:new('qufim_lord')
m:setEnabled(true)

m:addOverride('xi.zones.Qufim_Island.Zone.onInitialize', function(zone)
    super(zone)
    print('[qufim_lord] onInitialize fired')

    local minlevel = 25
    local maxlevel = 35

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Lord of Qufim',
        groupId     = 12,
        groupZoneId = 267,
        x           = 45.27,
        y           = -20.1,
        z           = 275.37,
        rotation    = 123,
        minLevel    = 34,
        maxLevel    = 35,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobSpawn = function(mob)
            mob:setMaxHP(3500)
            mob:setHP(3500)
            mob:setModelSize(2.5)
            mob:setMod(xi.mod.REGEN, 3)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 125)
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
                local bonusExp = 750 * #eligibleMembers
                
                    player:addExp(bonusExp)
                                    
            else
                player:printToPlayer(
                    'A party member is level 36 or higher. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
            end 
        end,

        onMobDespawn = function(mob, player, optParams)

            local RESPAWN_DELAY = math.random(1800000, 3600000) -- 30 to 60 min in ms

            mob:timer(RESPAWN_DELAY, function(mob)
                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(45.272, -20.034, 275.370, 123)
                mob:spawn()
            end)

            print(string.format('[qufim_lord] Respawn in %.2f minutes', RESPAWN_DELAY / 60000))
            
            end,
    })

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(45.272, -20.034, 275.370, 123)
    mob:spawn()
end)

return m