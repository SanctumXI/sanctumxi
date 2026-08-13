/*
 * Sanctum linkshell recruitment pearl delivery.
 *
 * The companion API approves an application but never writes directly into a
 * live character inventory. This module consumes approved applications after
 * login and creates the pearl through the normal map-server inventory path.
 */

#include "common/database.h"
#include "common/logging.h"

#include "map/entities/char_entity.h"
#include "map/items.h"
#include "map/items/item_linkshell.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/charutils.h"
#include "map/utils/itemutils.h"
#include "map/utils/moduleutils.h"

#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace
{

struct ApprovedApplication
{
    uint64      applicationId{};
    uint32      linkshellId{};
    uint16      color{};
    std::string linkshellName;
};

auto recruitmentSchemaExists() -> bool
{
    static std::optional<bool> schemaExists;
    if (schemaExists.has_value())
    {
        return *schemaExists;
    }

    const auto result = db::preparedStmt(
        "SELECT 1 FROM information_schema.tables "
        "WHERE table_schema = DATABASE() "
        "AND table_name = 'linkshell_recruitment_applications' LIMIT 1");
    schemaExists = result && result->rowsCount() > 0;
    return *schemaExists;
}

auto hasLinkshellMembership(const uint32 charId, const uint32 linkshellId) -> bool
{
    const auto result = db::preparedStmt(
        "SELECT extra FROM char_inventory "
        "WHERE charid = ? AND itemId IN (513, 514, 515) AND quantity > 0",
        charId);
    if (!result)
    {
        return false;
    }

    while (result->next())
    {
        const auto extra = result->getBlobBytes("extra");
        if (extra.size() < 9)
        {
            continue;
        }

        const auto storedId =
            static_cast<uint32>(static_cast<uint8>(extra[0])) |
            (static_cast<uint32>(static_cast<uint8>(extra[1])) << 8U) |
            (static_cast<uint32>(static_cast<uint8>(extra[2])) << 16U) |
            (static_cast<uint32>(static_cast<uint8>(extra[3])) << 24U);
        const auto rank = static_cast<uint8>(extra[8]);
        if (storedId == linkshellId && rank >= LSTYPE_LINKSHELL && rank <= LSTYPE_LINKPEARL)
        {
            return true;
        }
    }

    return false;
}

auto markDelivered(const ApprovedApplication& application) -> bool
{
    const auto update = db::preparedStmt(
        "UPDATE linkshell_recruitment_applications "
        "SET status = 'joined', active_slot = NULL, pearl_delivered_at = CURRENT_TIMESTAMP(6) "
        "WHERE id = ? AND status = 'approved' AND pearl_delivered_at IS NULL LIMIT 1",
        application.applicationId);
    return update && update->rowsAffected() == 1;
}

auto addRecruitmentLinkpearl(CCharEntity* player, const ApprovedApplication& application) -> bool
{
    auto item = xi::items::spawn(ITEMID::LINKPEARL);
    if (!item)
    {
        ShowWarning("LinkshellRecruitment could not create item 515 for character %u.", player->id);
        return false;
    }

    auto* pearl = static_cast<CItemLinkshell*>(item.get());
    pearl->setSignature(application.linkshellName);
    pearl->SetLSID(application.linkshellId);
    pearl->SetLSColor(application.color);
    pearl->SetLSType(LSTYPE_LINKPEARL);
    pearl->setQuantity(1);

    return charutils::AddItem(player, LOC_INVENTORY, std::move(item)) != ERROR_SLOTID;
}

auto deliverApprovedPearls(CLuaBaseEntity* luaEntity) -> uint8
{
    if (!luaEntity || !recruitmentSchemaExists())
    {
        return 0;
    }

    auto* player = dynamic_cast<CCharEntity*>(luaEntity->GetBaseEntity());
    if (!player)
    {
        return 0;
    }

    const auto result = db::preparedStmt(
        "SELECT a.id, a.linkshell_id, l.name, l.color "
        "FROM linkshell_recruitment_applications AS a "
        "INNER JOIN linkshells AS l ON l.linkshellid = a.linkshell_id "
        "WHERE a.applicant_charid = ? "
        "AND a.applicant_account_id = ? "
        "AND a.status = 'approved' "
        "AND a.active_slot = 1 "
        "AND a.pearl_delivered_at IS NULL "
        "AND l.broken = 0 "
        "ORDER BY a.decided_at, a.id",
        player->id,
        player->accid);
    if (!result)
    {
        return 0;
    }

    std::vector<ApprovedApplication> applications;
    while (result->next())
    {
        applications.emplace_back(ApprovedApplication{
            .applicationId = result->get<uint64>("id"),
            .linkshellId   = result->get<uint32>("linkshell_id"),
            .color         = result->get<uint16>("color"),
            .linkshellName = result->get<std::string>("name"),
        });
    }

    uint8 delivered = 0;
    for (const auto& application : applications)
    {
        const bool alreadyMember = hasLinkshellMembership(player->id, application.linkshellId);
        if (!alreadyMember && !addRecruitmentLinkpearl(player, application))
        {
            // Inventory is probably full. Leave the approval pending so a
            // future login can retry without duplicating an item.
            continue;
        }

        if (markDelivered(application))
        {
            ++delivered;
        }
    }

    return delivered;
}

} // namespace

class LinkshellRecruitmentModule final : public CPPModule
{
    void OnInit() override
    {
        auto xiTable = lua["xi"].get_or_create<sol::table>();
        auto table   = xiTable["linkshellRecruitment"].get_or_create<sol::table>();
        table.set_function("deliverApprovedPearls", deliverApprovedPearls);
    }
};

REGISTER_CPP_MODULE(LinkshellRecruitmentModule);
