-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Hugo
-- Sanctum Linkshell HNM Treasury
-----------------------------------

require('scripts/globals/linkshell_treasury')
require('scripts/globals/npc_util')
-----------------------------------

local entity = {}

local categoryNames =
{
    NQ_ZILART = 'NQ Zilart Kings',
    HQ_ZILART = 'HQ Zilart Kings',
    TOAU      = 'ToAU Kings',
}

local showMainMenu
local showCategoryMenu
local showWithdrawConfirmation

local function printNoLinkshell(player)
    player:printToPlayer(
        'You must have a pearl equipped in Linkshell 1.',
        xi.msg.channel.SYSTEM_3
    )
end

local function getTradedTreasuryItem(trade)
    local tradedItemID = 0
    local tradedQuantity = 0

    for slot = 0, 7 do
        local itemID = trade:getItemId(slot)
        local quantity = trade:getSlotQty(slot)

        if itemID ~= 0 and quantity > 0 then
            if not xi.linkshellTreasury.isAllowedItem(itemID) then
                return nil
            end

            if tradedItemID ~= 0 and tradedItemID ~= itemID then
                return nil
            end

            tradedItemID = itemID
            tradedQuantity = tradedQuantity + quantity
        end
    end

    if tradedItemID == 0 or tradedQuantity == 0 then
        return nil
    end

    return
    {
        itemID = tradedItemID,
        quantity = tradedQuantity,
    }
end

local function getTreasuryItemsByCategory(category)
    local itemList = {}

    for itemID, itemData in pairs(xi.linkshellTreasury.items) do
        if itemData.category == category then
            table.insert(itemList,
            {
                itemID = itemID,
                name = itemData.name,
            })
        end
    end

    table.sort(itemList, function(a, b)
        return a.itemID < b.itemID
    end)

    return itemList
end

local function performWithdrawal(player, itemID, category)
    local itemName = xi.linkshellTreasury.getItemName(itemID)
    local balanceBefore = xi.linkshellTreasury.getItemCount(player, itemID)

    if balanceBefore < 1 then
        player:printToPlayer(
            string.format(
                'The treasury does not contain any %s.',
                itemName
            ),
            xi.msg.channel.SYSTEM_3
        )

        player:timer(100, function(delayedPlayer)
            showCategoryMenu(delayedPlayer, category)
        end)

        return
    end

    if player:getFreeSlotsCount() <= 0 then
        player:printToPlayer(
            'You do not have enough inventory space.',
            xi.msg.channel.SYSTEM_3
        )

        player:timer(100, function(delayedPlayer)
            showCategoryMenu(delayedPlayer, category)
        end)

        return
    end

    local databaseResult = xi.linkshellTreasury.withdrawItem(
        player,
        itemID,
        1
    )

    if not databaseResult then
        player:printToPlayer(
            'The treasury withdrawal failed. You do not have access to withdraw items.',
            xi.msg.channel.SYSTEM_3
        )

        return
    end

    local addedItem = player:addItem(itemID, 1)

    if not addedItem then
        local restoreResult = xi.linkshellTreasury.depositItem(
            player,
            itemID,
            1
        )

        player:printToPlayer(
            string.format(
                '%s could not be added to your inventory. Returning to treasury...',
                itemName
            ),
            xi.msg.channel.SYSTEM_3
        )

        return
    end

    local balanceAfter = xi.linkshellTreasury.getItemCount(player, itemID)

    player:printToPlayer(
        string.format(
            'You withdrew one %s. Treasury balance: %u.',
            itemName,
            balanceAfter
        ),
        xi.msg.channel.SYSTEM_3
    )
end

showWithdrawConfirmation = function(player, itemID, category)
    local itemName = xi.linkshellTreasury.getItemName(itemID)
    local balance = xi.linkshellTreasury.getItemCount(player, itemID)

    player:customMenu({
        title = string.format(
            'Withdraw %s? Stored: %u',
            itemName,
            balance
        ),

        options =
        {
            {
                'Yes',
                function(playerArg)
                    playerArg:printToPlayer(
                        'Attempting Withdrawal...',
                        xi.msg.channel.SYSTEM_3
                    )

                    performWithdrawal(
                        playerArg,
                        itemID,
                        category
                    )
                end,
            },

            {
                'No',
                function(playerArg)
                    playerArg:timer(100, function(delayedPlayer)
                        showCategoryMenu(
                            delayedPlayer,
                            category
                        )
                    end)
                end,
            },
        },
    })
end

showCategoryMenu = function(player, category)
    local itemList = getTreasuryItemsByCategory(category)

    if #itemList == 0 then
        player:printToPlayer(
            'No treasury items are configured for this category.',
            xi.msg.channel.SYSTEM_3
        )

        player:timer(100, function(delayedPlayer)
            showMainMenu(delayedPlayer)
        end)

        return
    end

    local options = {}

    for _, entry in ipairs(itemList) do
        local selectedItemID = entry.itemID
        local itemName = entry.name
        local balance = xi.linkshellTreasury.getItemCount(
            player,
            selectedItemID
        )

        table.insert(options,
        {
            string.format(
                '%s (%u)',
                itemName,
                balance
            ),

            function(playerArg)
                local confirmationItemID = selectedItemID
                local confirmationCategory = category

                playerArg:timer(100, function(delayedPlayer)
                    showWithdrawConfirmation(
                        delayedPlayer,
                        confirmationItemID,
                        confirmationCategory
                    )
                end)
            end,
        })
    end

    table.insert(options,
    {
        'Back',
        function(playerArg)
            playerArg:timer(100, function(delayedPlayer)
                showMainMenu(delayedPlayer)
            end)
        end,
    })

    player:customMenu({
        title = categoryNames[category] or 'HNM Pop Items',
        options = options,
    })
end

showMainMenu = function(player)
    player:customMenu({
        title = 'What items would you like to withdraw?',

        options =
        {
            {
                'NQ Zilart King Pop Items',
                function(playerArg)
                    playerArg:timer(100, function(delayedPlayer)
                        showCategoryMenu(
                            delayedPlayer,
                            'NQ_ZILART'
                        )
                    end)
                end,
            },

            {
                'HQ Zilart King Pop Items',
                function(playerArg)
                    playerArg:timer(100, function(delayedPlayer)
                        showCategoryMenu(
                            delayedPlayer,
                            'HQ_ZILART'
                        )
                    end)
                end,
            },

            {
                'ToAU King Pop Items',
                function(playerArg)
                    playerArg:timer(100, function(delayedPlayer)
                        showCategoryMenu(
                            delayedPlayer,
                            'TOAU'
                        )
                    end)
                end,
            },
        },
    })
end

entity.onTrade = function(player, npc, trade)
    if not xi.linkshellTreasury.hasLinkshell(player) then
        printNoLinkshell(player)
        return
    end

    local tradedItem = getTradedTreasuryItem(trade)

    if not tradedItem then
        player:printToPlayer(
            'The treasury only accepts approved HNM items, one item type per trade.',
            xi.msg.channel.SYSTEM_3
        )

        return
    end

    local itemID = tradedItem.itemID
    local quantity = tradedItem.quantity
    local itemName = xi.linkshellTreasury.getItemName(itemID)

    if not xi.linkshellTreasury.depositItem(player, itemID, quantity) then
        player:printToPlayer(
            'The treasury deposit failed. Your items were not removed.',
            xi.msg.channel.SYSTEM_3
        )

        return
    end

    player:tradeComplete()

    local newBalance = xi.linkshellTreasury.getItemCount(
        player,
        itemID
    )

    player:printToPlayer(
        string.format(
            'Deposited %u %s. Treasury balance: %u.',
            quantity,
            itemName,
            newBalance
        ),
        xi.msg.channel.SYSTEM_3
    )
end

entity.onTrigger = function(player, npc)
    if not xi.linkshellTreasury.hasLinkshell(player) then
        printNoLinkshell(player)
        return
    end

    showMainMenu(player)
end

return entity
