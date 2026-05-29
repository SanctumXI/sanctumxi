require('modules/module_utils')

local m = Module:new('western_altepa_worm_trial')
m:setEnabled(true)

local npcName = '???'

local firstWormName = 'Trial Worm'
local addWormName   = 'Trial Sandworm'

local firstWaveXP = 5000
local addWaveXP   = 10000

local spawnPos =
{
    x = 298,
    y = 0.74,
    z = 107,
    rotation = 0,
}

local function awardBonusXP(player, mob, amount)
    if not player or amount <= 0 then
        return
    end

    local members = player:getAlliance()

    if members == nil or #members == 0 then
        members = player:getParty()
    end

    if members == nil or #members == 0 then
        members = { player }
    end

    for _, member in pairs(members) do
        if
            member and
            member:getZoneID() == mob:getZoneID() and
            member:checkDistance(mob) <= 50
        then
            member:addExp(amount)
            member:printToPlayer(string.format('You receive %u bonus EXP!', amount), xi.msg.channel.SYSTEM_3)
        end
    end
end

local function spawnWorm(zone, name, x, y, z)
    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = name,
        groupId     = 42,
        groupZoneId = 5,
        x           = x,
        y           = y,
        z           = z,
        rotation    = 0,
        minLevel    = 50,
        maxLevel    = 50,
        specialSpawnAnimation = true,
        releaseIdOnDisappear  = false,

        onMobSpawn = function(mobArg)
            mobArg:setMobMod(xi.mobMod.NO_DROPS, 1)
        end,
    })

    mob:spawn()
    return mob
end

m:addOverride('xi.zones.Western_Altepa_Desert.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = '???',
        x        = spawnPos.x,
        y        = spawnPos.y,
        z        = spawnPos.z,
        rotation = spawnPos.rotation,

        onTrade = function(player, npc, trade)
            if npc:getLocalVar('TRIAL_ACTIVE') == 1 then
                player:printToPlayer('The trial is already active.', xi.msg.channel.SYSTEM_3)
                return
            end

            if trade:hasItemQty(xi.item.WATER_CRYSTAL, 1) and trade:getItemCount() == 1 then
                player:tradeComplete()
                npc:setLocalVar('TRIAL_ACTIVE', 1)

                player:printToPlayer('The sand begins to move...', xi.msg.channel.SYSTEM_3)

                local worm = spawnWorm(zone, firstWormName, spawnPos.x + 3, spawnPos.y, spawnPos.z)

                worm:setLocalVar('TRIAL_NPC_ID', npc:getID())

                worm:addListener('DEATH', 'TRIAL_FIRST_WORM_DEATH', function(mob, killer)
                    awardBonusXP(killer, mob, firstWaveXP)
                end)

                worm:addListener('DESPAWN', 'TRIAL_FIRST_WORM_DESPAWN', function(mob)
                    local trialNpc = GetNPCByID(mob:getLocalVar('TRIAL_NPC_ID'))

                    local x = mob:getXPos()
                    local y = mob:getYPos()
                    local z = mob:getZPos()

                    local remainingAdds = 3
                    local addWaveRewarded = false

                    local function onAddDeath(addMob, killer)
                        remainingAdds = remainingAdds - 1

                        if remainingAdds <= 0 and not addWaveRewarded then
                            addWaveRewarded = true
                            awardBonusXP(killer, addMob, addWaveXP)

                            if trialNpc then
                                trialNpc:setLocalVar('TRIAL_ACTIVE', 0)
                            end
                        end
                    end

                    local add1 = spawnWorm(zone, addWormName, x + 2, y, z)
                    local add2 = spawnWorm(zone, addWormName, x - 2, y, z)
                    local add3 = spawnWorm(zone, addWormName, x, y, z + 2)

                    add1:addListener('DEATH', 'TRIAL_ADD_WORM_DEATH_1', onAddDeath)
                    add2:addListener('DEATH', 'TRIAL_ADD_WORM_DEATH_2', onAddDeath)
                    add3:addListener('DEATH', 'TRIAL_ADD_WORM_DEATH_3', onAddDeath)
                end)

                return
            end

            player:printToPlayer('Trade me a Water Crystal.', xi.msg.channel.SYSTEM_3)
        end,

        onTrigger = function(player, npc)
            player:printToPlayer('Trade me a Water Crystal.', xi.msg.channel.SYSTEM_3)
        end,
    })
end)

return m