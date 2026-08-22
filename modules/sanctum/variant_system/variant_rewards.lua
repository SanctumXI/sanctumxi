local data = require('modules/sanctum/variant_system/variant_tables')

local rewards = {}

-- FFXI chat palette color 256 is item green; color 255 restores the message color.
local itemColor  = string.char(0x1E, 0x02)
local colorReset = string.char(0x1E, 0x01)

local function getCosmeticsForLevel(level)
    local available = {}
    local seen      = {}

    for _, pool in ipairs(data.cosmeticPools) do
        if level >= pool.minLevel and level <= pool.maxLevel then
            for _, item in ipairs(pool.items) do
                local itemId = type(item) == 'table' and (item.itemId or item.id) or item

                if itemId ~= nil and not seen[itemId] then
                    available[#available + 1] = itemId
                    seen[itemId] = true
                end
            end
        end
    end

    return available
end

local function getItemName(itemId)
    local item = GetItemByID(itemId)

    if item == nil then
        return string.format('item %u', itemId)
    end

    return item:getName():gsub('_', ' ')
end

local function getZoneText(player, key)
    local zone = zones[player:getZoneID()]

    return zone ~= nil and zone.text ~= nil and zone.text[key] or nil
end

local function addParticipationExp(player, amount)
    local bridge = xi.variantSystemRewards

    if bridge ~= nil and bridge.addExpSilent ~= nil then
        return bridge.addExpSilent(player, amount)
    end

    player:addExp(amount)
    return true
end

local function getZoneBossCosmetics(bossConfig)
    return getCosmeticsForLevel(bossConfig.cosmeticLevel or bossConfig.level or 1)
end

local function announceZoneBossPersonalReward(player, boss, state, itemId)
    local itemName        = getItemName(itemId)
    local coloredItemName = itemColor .. itemName .. colorReset

    player:printToPlayer(
        string.format(
            'You find a %s on the %s.',
            coloredItemName,
            state.config.displayName or boss:getPacketName()),
        xi.msg.channel.SYSTEM_3)

    local obtainsMessage = string.format(
        '%s obtains a %s.',
        player:getName(),
        coloredItemName)

    for participantId, participant in pairs(state.participants) do
        local audience = GetPlayerByID(participantId)

        if
            participant.points >= 1 and
            audience ~= nil and
            audience:isPC() and
            audience:getZoneID() == boss:getZoneID()
        then
            audience:printToPlayer(obtainsMessage, xi.msg.channel.SYSTEM_3)
        end
    end
end

local function giveZoneBossPersonalReward(player, boss, state)
    local bossConfig = state.config
    local unowned = {}

    for _, itemId in ipairs(getZoneBossCosmetics(bossConfig)) do
        if not player:hasItem(itemId) then
            unowned[#unowned + 1] = itemId
        end
    end

    local isFallback = #unowned == 0
    local itemId = isFallback and bossConfig.fallbackItem or
        unowned[math.randomInt(1, #unowned)]

    if itemId == nil then
        player:printToPlayer(
            'No personal Zone Boss reward is configured for this zone.',
            xi.msg.channel.SYSTEM_3)
        return false
    end

    if player:addItem(itemId) == nil then
        local messageId = getZoneText(player, 'ITEM_CANNOT_BE_OBTAINED')

        if messageId ~= nil then
            player:messageSpecial(messageId, itemId)
        else
            player:printToPlayer(
                string.format(
                    'Your Zone Boss reward (%s) could not be delivered because your inventory is full.',
                    getItemName(itemId)),
                xi.msg.channel.SYSTEM_3)
        end

        return false
    end

    announceZoneBossPersonalReward(player, boss, state, itemId)

    return true
end

function rewards.getRewardOwner(killer)
    local owner = killer

    while owner ~= nil and not owner:isPC() do
        local master = owner:getMaster()

        if master == nil or master:getID() == owner:getID() then
            return nil
        end

        owner = master
    end

    return owner
end

function rewards.awardBonusExp(mob, killer, amount, label, halveBelowEvenMatch)
    local owner = rewards.getRewardOwner(killer)

    if owner == nil then
        return false
    end

    local members = owner:getAlliance()
    local seen    = {}
    local reward  = math.floor(amount)
    local awarded = false

    for _, member in ipairs(members) do
        if
            member ~= nil and
            member:isPC() and
            not member:isDead() and
            member:getZoneID() == mob:getZoneID() and
            member:checkKillCredit(mob) and
            not seen[member:getID()]
        then
            seen[member:getID()] = true
            awarded = true

            local memberReward = reward

            if
                halveBelowEvenMatch and
                member:checkDifficulty(mob) < xi.mobDifficulty.EVEN_MATCH
            then
                memberReward = math.floor(memberReward / 2)
            end

            member:addExp(memberReward)
            member:printToPlayer(
                string.format('%s bonus: %u EXP.', label, memberReward),
                xi.msg.channel.SYSTEM_3)
        end
    end

    return awarded
end

function rewards.addCosmeticDrops(boss, chainConfig)
    boss:addListener('ITEM_DROPS', 'SANCTUM_VARIANT_COSMETICS', function(mobArg, loot)
        local available = getCosmeticsForLevel(mobArg:getMainLvl())

        if #available > 0 then
            loot:addItemFixed(available[math.randomInt(1, #available)], 1000)

            if math.randomInt(1, 100) <= 50 then
                loot:addItemFixed(available[math.randomInt(1, #available)], 1000)
            end
        end

        for _, drop in ipairs(chainConfig.specialCosmetics or {}) do
            local itemId = type(drop) == 'table' and (drop.itemId or drop.id) or drop
            local rate   = type(drop) == 'table' and (drop.rate or 1000) or 1000

            if itemId ~= nil and rate > 0 then
                loot:addItemFixed(itemId, math.min(1000, rate))
            end
        end
    end)
end

function rewards.awardZoneBossRewards(boss, state)
    if state == nil then
        return
    end

    local bossConfig = state.config

    for playerId, participant in pairs(state.participants) do
        if participant.points >= 1 then
            local player = GetPlayerByID(playerId)

            if
                player ~= nil and
                player:isPC() and
                player:getZoneID() == boss:getZoneID()
            then
                if player:isDead() then
                    player:printToPlayer(
                        'Unfortunately you are dead and therefore get no experience points.',
                        xi.msg.channel.SYSTEM_3)
                else
                    local expReward = 0

                    if player:checkDifficulty(boss) > xi.mobDifficulty.TOO_WEAK then
                        expReward = math.min(
                            bossConfig.xpCap or 0,
                            math.floor(participant.points * (bossConfig.xpPerPoint or 0)))

                        if expReward > 0 then
                            addParticipationExp(player, expReward)
                        end
                    end

                    player:printToPlayer(
                        string.format(
                            '%s participation: %u points, %u EXP.',
                            bossConfig.displayName,
                            participant.points,
                            expReward),
                        xi.msg.channel.SYSTEM_3)
                end

                giveZoneBossPersonalReward(player, boss, state)
            end
        end
    end
end

return rewards
