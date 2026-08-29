local data = require('modules/sanctum/variant_system/variant_tables')

local rewards = {}
local sanctumRingItem = xi.item.CALIBER_RING
local sanctumRingName = 'Sanctum Ring'
local sanctumRingOwnedScrollChance =
    data.settings.zoneBossSanctumRingOwnedScrollChance or 75

local function addCosmetics(available, seen, items)
    for _, item in ipairs(items or {}) do
        local itemId = type(item) == 'table' and (item.itemId or item.id) or item

        if itemId ~= nil and not seen[itemId] then
            available[#available + 1] = itemId
            seen[itemId] = true
        end
    end
end

local function getCampCosmetics(zoneName, campKey)
    local zoneCamps = data.cosmeticCamps[zoneName]

    if zoneCamps == nil then
        return {}
    end

    return zoneCamps[campKey] or {}
end

local function getZoneBossCosmetics(bossConfig)
    local available = {}
    local seen      = {}

    for _, campKey in ipairs(bossConfig.cosmeticCamps or {}) do
        addCosmetics(available, seen, getCampCosmetics(bossConfig.cosmeticZone, campKey))
    end

    return available
end

local function getItemName(itemId)
    if itemId == sanctumRingItem then
        return sanctumRingName
    end

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

local function addExpReward(player, amount)
    local bridge = xi.variantSystemRewards

    if bridge ~= nil and bridge.addExpSilent ~= nil then
        if bridge.addExpSilent(player, amount) then
            return true, true
        end
    end

    player:addExp(amount)
    return true, false
end

local function getExpRewardName(player)
    local bridge = xi.variantSystemRewards

    if
        bridge ~= nil and
        bridge.usesLimitPoints ~= nil and
        bridge.usesLimitPoints(player)
    then
        return 'limit points'
    end

    return 'experience points'
end

local function announceZoneBossPersonalReward(player, boss, state, itemId)
    local obtainsMessage = getZoneText(player, 'PLAYER_OBTAINS_ITEM')

    if itemId == sanctumRingItem then
        for participantId, participant in pairs(state.participants) do
            local audience = GetPlayerByID(participantId)

            if
                participant.points >= 1 and
                audience ~= nil and
                audience:isPC() and
                audience:getZoneID() == boss:getZoneID()
            then
                audience:printToPlayer(
                    string.format('%s obtains a %s.', player:getName(), sanctumRingName),
                    xi.msg.channel.SYSTEM_3)
            end
        end

        return
    end

    if obtainsMessage == nil then
        local obtainedMessage = getZoneText(player, 'ITEM_OBTAINED')

        if obtainedMessage ~= nil then
            player:messageSpecial(obtainedMessage, itemId)
        else
            player:printToPlayer(
                string.format('Obtained: %s.', getItemName(itemId)),
                xi.msg.channel.SYSTEM_3)
        end

        return
    end

    for participantId, participant in pairs(state.participants) do
        local audience = GetPlayerByID(participantId)

        if
            participant.points >= 1 and
            audience ~= nil and
            audience:isPC() and
            audience:getZoneID() == boss:getZoneID()
        then
            audience:messageName(obtainsMessage, player, itemId)
        end
    end
end

local function giveZoneBossPersonalItem(player, boss, state, itemId)
    if itemId == nil then
        return false
    end

    if player:addItem(itemId) == nil then
        local messageId = getZoneText(player, 'ITEM_CANNOT_BE_OBTAINED')

        if messageId ~= nil and itemId ~= sanctumRingItem then
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

    return giveZoneBossPersonalItem(player, boss, state, itemId)
end

function rewards.selectSanctumRingPersonalDrop(player, boss)
    if player:hasItem(sanctumRingItem) then
        if math.randomInt(1, 100) <= sanctumRingOwnedScrollChance then
            return xi.item.DRAGON_CHRONICLES
        end

        return nil
    end

    if math.randomInt(1, 800) <= math.min(800, boss:getMainLvl()) then
        return sanctumRingItem
    end

    return nil
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

            local rewardName = getExpRewardName(member)
            local _, awardedSilently = addExpReward(member, memberReward)

            if awardedSilently then
                member:printToPlayer(
                    string.format('%s bonus: %u %s.', label, memberReward, rewardName),
                    xi.msg.channel.SYSTEM_3)
            end
        end
    end

    return awarded
end

function rewards.addCosmeticDrops(boss, chainConfig)
    boss:addListener('ITEM_DROPS', 'SANCTUM_VARIANT_COSMETICS', function(_, loot)
        local available = {}

        addCosmetics(
            available,
            {},
            getCampCosmetics(chainConfig.cosmeticZone, chainConfig.cosmeticCamp))

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
                    local rewardName = getExpRewardName(player)

                    if player:checkDifficulty(boss) > xi.mobDifficulty.TOO_WEAK then
                        expReward = math.min(
                            bossConfig.xpCap or 0,
                            math.floor(participant.points * (bossConfig.xpPerPoint or 0)))

                        if expReward > 0 then
                            addExpReward(player, expReward)
                        end
                    end

                    player:printToPlayer(
                        string.format(
                            '%s participation: %u points, %u %s.',
                            bossConfig.displayName,
                            participant.points,
                            expReward,
                            rewardName),
                        xi.msg.channel.SYSTEM_3)
                end

                giveZoneBossPersonalItem(
                    player,
                    boss,
                    state,
                    rewards.selectSanctumRingPersonalDrop(player, boss))
                giveZoneBossPersonalReward(player, boss, state)
            end
        end
    end
end

return rewards
