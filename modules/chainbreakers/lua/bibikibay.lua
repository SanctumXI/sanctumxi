require('modules/module_utils')

local m = Module:new('Suiza')
m:setEnabled(true)

m:addOverride('xi.zones.Bibiki_Bay.Zone.onInitialize', function(zone)
    super(zone)
    print('[suiza] onInitialize fired')

    local minLevel = 30
    local maxLevel = 40

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Suiza',
        groupId     = 50,
        groupZoneId = 82,
        x           = 445.63,
        y           = -20,
        z           = 763.90,
        rotation    = 221,
        minLevel    = 40,
        maxLevel    = 40,
       
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobSpawn = function(mob)
            mob:setMaxHP(4000)
            mob:setHP(4000)
            mob:setModelSize(2)
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
                local bonusExp = 1000 * #eligibleMembers
                
                    player:addExp(bonusExp)
                                    
            else
                player:printToPlayer(
                    'A party member is outside the level range of 30-40. No bonus EXP awarded.',
                    xi.msg.channel.SYSTEM_3
                )
            end   
        end,
             
        onMobDespawn = function(mob, player, optParams)

            local RESPAWN_DELAY = math.random(1800000, 3600000) -- 30 to 60 min in ms

            mob:timer(RESPAWN_DELAY, function(mob)
                mob:setDropID(0)
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
                mob:setSpawn(445.631, -20.000, 763.904, 221)
                mob:spawn()
            end)

            print(string.format('[suiza] Respawn in %.2f minutes', RESPAWN_DELAY / 60000))
            
            end,
              
    })
    -- Spawn on zone/server initialize
    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setSpawn(445.631, -20.000, 763.904, 221)
    mob:spawn()
end)

return m