-----------------------------------
-- Sanctum Linkshell HNM Treasury
-----------------------------------

xi = xi or {}
xi.linkshellTreasury = xi.linkshellTreasury or {}

-- For the initial test, the treasury uses Linkshell 1.
xi.linkshellTreasury.linkshellSlot = 1

xi.linkshellTreasury.type =
{
    LINKSHELL = 1,
    PEARLSACK = 2,
    LINKPEARL = 3,
    BROKEN    = 4,
}

-- Every item the treasury accepts is defined here.
-- Adding another item requires only another table entry.
xi.linkshellTreasury.items =
{
    [3339] =
    {
        name = 'Jug of Honey Wine',
        category = 'NQ_ZILART',
    },

    [3340] =
    {
        name = 'Cup of Sweet Tea',
        category = 'HQ_ZILART',
    },

    [3341] =
    {
        name = 'Beastly Shank',
        category = 'NQ_ZILART',
    },

    [3342] =
    {
        name = 'Savory Shank',
        category = 'HQ_ZILART',
    },

    [3343] =
    {
        name = 'Clump of Blue Pondweed',
        category = 'NQ_ZILART',
    },

    [3344] =
    {
        name = 'Clump of Red Pondweed',
        category = 'HQ_ZILART',
    },
}

function xi.linkshellTreasury.getLinkshellID(player)
    return player:getLinkshellID(
        xi.linkshellTreasury.linkshellSlot
    )
end

function xi.linkshellTreasury.getLinkshellType(player)
    return player:getLinkshellType(
        xi.linkshellTreasury.linkshellSlot
    )
end

function xi.linkshellTreasury.canWithdraw(player)
    local linkshellType =
        xi.linkshellTreasury.getLinkshellType(player)

    return
        linkshellType == xi.linkshellTreasury.type.LINKSHELL or
        linkshellType == xi.linkshellTreasury.type.PEARLSACK
end

function xi.linkshellTreasury.hasLinkshell(player)
    return xi.linkshellTreasury.getLinkshellID(player) > 0
end

function xi.linkshellTreasury.isAllowedItem(itemID)
    return xi.linkshellTreasury.items[itemID] ~= nil
end

function xi.linkshellTreasury.getItemData(itemID)
    return xi.linkshellTreasury.items[itemID]
end

function xi.linkshellTreasury.getItemName(itemID)
    local itemData = xi.linkshellTreasury.getItemData(itemID)

    if itemData then
        return itemData.name
    end

    return string.format('Item %u', itemID)
end

function xi.linkshellTreasury.getItemCount(player, itemID)
    if
        not xi.linkshellTreasury.hasLinkshell(player) or
        not xi.linkshellTreasury.isAllowedItem(itemID)
    then
        return 0
    end

    return player:getLinkshellTreasuryItemCount(
        xi.linkshellTreasury.linkshellSlot,
        itemID
    )
end

function xi.linkshellTreasury.depositItem(player, itemID, quantity)
    if
        not xi.linkshellTreasury.hasLinkshell(player) or
        not xi.linkshellTreasury.isAllowedItem(itemID) or
        quantity <= 0
    then
        return false
    end

    return player:depositLinkshellTreasuryItem(
        xi.linkshellTreasury.linkshellSlot,
        itemID,
        quantity
    )
end

function xi.linkshellTreasury.withdrawItem(player, itemID, quantity)
    if
        not xi.linkshellTreasury.hasLinkshell(player) or
        not xi.linkshellTreasury.canWithdraw(player) or
        not xi.linkshellTreasury.isAllowedItem(itemID) or
        quantity <= 0
    then
        return false
    end

    return player:withdrawLinkshellTreasuryItem(
        xi.linkshellTreasury.linkshellSlot,
        itemID,
        quantity
    )
end

-----------------------------------
-- Opens the Linkshell Treasury Shop
-----------------------------------
function xi.linkshellTreasury.openShop(player)
    local stock = {}

    if not xi.linkshellTreasury.hasLinkshell(player) then
        player:printToPlayer(
            'You must equip a linkshell in slot 1 to access the treasury.',
            xi.msg.channel.SYSTEM_3
        )

        return false
    end

    for itemID, _ in pairs(xi.linkshellTreasury.items) do
        local quantity = xi.linkshellTreasury.getItemCount(player, itemID)

        if quantity > 0 then
            table.insert(stock, { itemID, quantity })
        end
    end

    if #stock == 0 then
        player:printToPlayer(
            'Your linkshell treasury does not contain any pop items.',
            xi.msg.channel.SYSTEM_3
        )

        return false
    end

    -- Keep the shop list in consistent item-ID order.
    table.sort(stock, function(a, b)
        return a[1] < b[1]
    end)

-- Create the temporary shop first.
player:createShop(#stock, 250)

for _, stockItem in ipairs(stock) do
    player:addShopItem(stockItem[1], stockItem[2])
end

player:sendMenu(xi.menuType.SHOP)

    return true
end

return xi.linkshellTreasury