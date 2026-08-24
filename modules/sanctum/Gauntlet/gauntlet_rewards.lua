local rewards = {}

local function hasEntries(dropConfig)
    return
        dropConfig ~= nil and
        (#(dropConfig.fixed or {}) > 0 or #(dropConfig.groups or {}) > 0)
end

local function getItemName(itemId)
    local item = GetItemByID(itemId)

    return item and item:getName():gsub('_', ' ') or string.format('item %u', itemId)
end

local function notifyReward(audience, recipient, mob, itemId, quantity)
    local itemName = getItemName(itemId)
    local quantityText = quantity > 1 and string.format('%u x ', quantity) or ''
    local message = string.format(
        '%s receives %s%s from %s.',
        recipient:getName(),
        quantityText,
        itemName,
        mob:getPacketName())

    for _, member in ipairs(audience) do
        member:printToPlayer(message, xi.msg.channel.SYSTEM_3)
    end
end

local function giveToRandomMember(mob, members, audience, itemId, quantity)
    if #members == 0 then
        return false
    end

    local startIndex = math.randomInt(1, #members)

    for offset = 0, #members - 1 do
        local index = ((startIndex + offset - 1) % #members) + 1
        local recipient = members[index]

        if recipient:addItem({ id = itemId, quantity = quantity, silent = true }) then
            notifyReward(audience, recipient, mob, itemId, quantity)
            return true
        end
    end

    for _, member in ipairs(members) do
        member:printToPlayer(
            string.format('The %s reward could not be delivered because eligible inventories were full.', getItemName(itemId)),
            xi.msg.channel.SYSTEM_3)
    end

    return false
end


local function selectGroupItem(group)
    local totalWeight = 0

    for _, drop in ipairs(group.items) do
        totalWeight = totalWeight + (drop.weight or 1)
    end

    local roll = math.randomInt(1, totalWeight)

    for _, drop in ipairs(group.items) do
        roll = roll - (drop.weight or 1)

        if roll <= 0 then
            return drop
        end
    end

    return group.items[#group.items]
end

function rewards.hasDrops(dropConfig)
    return hasEntries(dropConfig)
end

function rewards.prepareMob(mob)
    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
end

function rewards.awardPersonalDrops(mob, dropConfig, members, audience)
    if not hasEntries(dropConfig) or #members == 0 then
        return 0
    end

    local delivered = 0

    for _, drop in ipairs(dropConfig.fixed or {}) do
        if math.randomInt(1, 1000) <= (drop.rate or 1000) then
            local rewardGiven = giveToRandomMember(mob, members, audience, drop.itemId, drop.quantity or 1)

            if rewardGiven then
                delivered = delivered + 1
            end
        end
    end

    for _, group in ipairs(dropConfig.groups or {}) do
        if math.randomInt(1, 1000) <= (group.rate or 1000) then
            local drop = selectGroupItem(group)
            local rewardGiven = giveToRandomMember(mob, members, audience, drop.itemId, drop.quantity or 1)

            if rewardGiven then
                delivered = delivered + 1
            end
        end
    end

    return delivered
end

function rewards.awardExp(members, totalExp, message)
    if #members == 0 then
        return false
    end

    local expPerMember = math.floor(totalExp / #members)

    for _, member in ipairs(members) do
        member:addExp(expPerMember)
        member:printToPlayer(message, xi.msg.channel.SYSTEM_3)
    end

    return true
end

return rewards
