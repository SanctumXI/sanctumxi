-----------------------------------
-- Shared behaviour for Hugo and Linkshell Library treasury NPCs.
-----------------------------------
require('scripts/globals/linkshell_treasury')

local treasuryNpc = {}

local function printNoLinkshell(player)
    player:printToPlayer('You must have a pearl equipped in Linkshell 1.', xi.msg.channel.SYSTEM_3)
end

local function getTradedTreasuryItem(trade)
    local tradedItemID = 0
    local tradedQuantity = 0

    for slot = 0, 7 do
        local itemID = trade:getItemId(slot)
        local quantity = trade:getSlotQty(slot)

        if itemID ~= 0 and quantity > 0 then
            if not xi.linkshellTreasury.isAllowedItem(itemID) or (tradedItemID ~= 0 and tradedItemID ~= itemID) then
                return nil
            end

            tradedItemID = itemID
            tradedQuantity = tradedQuantity + quantity
        end
    end

    if tradedItemID == 0 or tradedQuantity == 0 then
        return nil
    end

    return { itemID = tradedItemID, quantity = tradedQuantity }
end

treasuryNpc.onTrade = function(player, npc, trade)
    if not xi.linkshellTreasury.hasLinkshell(player) then
        printNoLinkshell(player)
        return
    end

    local tradedItem = getTradedTreasuryItem(trade)
    if not tradedItem then
        player:printToPlayer('The treasury only accepts approved HNM items, one item type per trade.', xi.msg.channel.SYSTEM_3)
        return
    end

    local itemID = tradedItem.itemID
    local quantity = tradedItem.quantity
    if not xi.linkshellTreasury.depositItem(player, itemID, quantity) then
        player:printToPlayer('The treasury deposit failed. Your items were not removed.', xi.msg.channel.SYSTEM_3)
        return
    end

    player:tradeComplete()
    player:printToPlayer(string.format(
        'Deposited %u %s. Treasury balance: %u.',
        quantity,
        xi.linkshellTreasury.getItemName(itemID),
        xi.linkshellTreasury.getItemCount(player, itemID)
    ), xi.msg.channel.SYSTEM_3)
end

treasuryNpc.onTrigger = function(player, npc)
    if not xi.linkshellTreasury.hasLinkshell(player) then
        printNoLinkshell(player)
        return
    end

    player:printToPlayer(string.format('Current Registered LS: %s', xi.linkshellTreasury.getLinkshellName(player)), xi.msg.channel.SYSTEM_3)
    player:printToPlayer('Trade me the items used to summon the fiercest monsters in Vana\'diel. I\'ll safeguard them for your linkshell.', xi.msg.channel.SYSTEM_3)
    xi.linkshellTreasury.openShop(player)
end

return treasuryNpc
