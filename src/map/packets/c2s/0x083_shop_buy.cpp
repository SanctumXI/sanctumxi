/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "0x083_shop_buy.h"

#include "entities/char_entity.h"
#include "lua/lua_base_entity.h"
#include "packets/s2c/0x01d_item_same.h"
#include "packets/s2c/0x03f_shop_buy.h"
#include "trade_container.h"
#include "utils/charutils.h"
#include "utils/itemutils.h"

namespace
{
constexpr uint8 LINKSHELL_TREASURY_SHOP_TYPE = 250;
}

auto GP_CLI_COMMAND_SHOP_BUY::validate(MapSession* PSession, const CCharEntity* PChar) const -> PacketValidationResult
{
    return PacketValidator()
        .mustEqual(this->PropertyItemIndex, 0, "PropertyItemIndex not 0");
}

void GP_CLI_COMMAND_SHOP_BUY::process(MapSession* PSession, CCharEntity* PChar) const
{
    auto quantity = this->ItemNum;

    // Prevent users from buying from invalid container slots.
    if (this->ShopItemIndex > PChar->Container->getExSize() - 1)
    {
        ShowError(
            "User '%s' attempting to buy vendor item from an invalid slot!",
            PChar->getName());

        return;
    }

    const uint16 itemId = PChar->Container->getItemID(this->ShopItemIndex);
    const uint32 price  = PChar->Container->getQuantity(this->ShopItemIndex);

    const CItem* PItem = xi::items::lookup(itemId);

    if (!PItem)
    {
        ShowWarning(
            "User '%s' attempting to buy an invalid item from vendor!",
            PChar->getName());

        return;
    }

    if (quantity == 0)
    {
        return;
    }

    // Prevent purchasing larger stacks than the actual stack size.
    if (quantity > PItem->getStackSize())
    {
        quantity = PItem->getStackSize();
    }

    // Sanctum Custom Linkshell Treasury Shop Logic

    if (PChar->Container->getType() == LINKSHELL_TREASURY_SHOP_TYPE)
    {
        constexpr uint8 linkshellSlot = 1;

        CLuaBaseEntity luaPlayer(PChar);

        const uint32 linkshellID = luaPlayer.getLinkshellID(linkshellSlot);

        if (linkshellID == 0)
        {
            ShowWarning(
                "Linkshell Treasury: Player '%s' has no linkshell equipped in slot 1.",
                PChar->getName());

            return;
        }

        // The displayed price is only the stock indicator.
        // The database withdrawal function performs the real stock check.
        if (!luaPlayer.withdrawLinkshellTreasuryItem(
                linkshellSlot,
                itemId,
                quantity))
        {
            ShowWarning(
                "Linkshell Treasury: Failed withdrawal. "
                "Player: %s, Linkshell: %u, Item: %u, Quantity: %u",
                PChar->getName(),
                linkshellID,
                itemId,
                quantity);

            return;
        }

        // Add the withdrawn item to the player's inventory.
        if (charutils::AddItem(
                PChar,
                LOC_INVENTORY,
                itemId,
                quantity) == ERROR_SLOTID)
        {
            // Restore treasury stock if inventory delivery fails.
            luaPlayer.depositLinkshellTreasuryItem(
                linkshellSlot,
                itemId,
                quantity);

            ShowWarning(
                "Linkshell Treasury: Item delivery failed and stock was refunded. "
                "Player: %s, Linkshell: %u, Item: %u, Quantity: %u",
                PChar->getName(),
                linkshellID,
                itemId,
                quantity);

            return;
        }

        ShowInfo(
            "Linkshell Treasury: Player '%s' withdrew %u of item ID %u "
            "from linkshell ID %u.",
            PChar->getName(),
            quantity,
            itemId,
            linkshellID);

        PChar->pushPacket<GP_SERV_COMMAND_SHOP_BUY>(
            this->ShopItemIndex,
            quantity);

        PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(PChar);

        return;
    }

     /************************************************************************
     * Normal gil shop logic
     ************************************************************************/

    const CItem* gil = PChar->getStorage(LOC_INVENTORY)->GetItem(0);

    if (!gil || !gil->isType(ITEM_CURRENCY) || gil->getReserve() != 0)
    {
        ShowError("User '%s' has invalid gil", PChar->getName());
        return;
    }

    if (gil->getQuantity() >= (price * quantity))
    {
        if (charutils::AddItem(
                PChar,
                LOC_INVENTORY,
                itemId,
                quantity) != ERROR_SLOTID)
        {
            charutils::UpdateItem(
                PChar,
                LOC_INVENTORY,
                0,
                -static_cast<int32>(price * quantity));

            ShowInfo(
                "User '%s' purchased %u of item of ID %u [from VENDOR]",
                PChar->getName(),
                quantity,
                itemId);

            PChar->pushPacket<GP_SERV_COMMAND_SHOP_BUY>(
                this->ShopItemIndex,
                quantity);

            PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(PChar);
        }
    }
}
