/*
 * Sanctum linkshell recruitment pearl delivery.
 *
 * The companion API approves an application but never writes directly into a
 * live character inventory. The Linkshell Concierge uses this module to show
 * and deliver approved linkpearls through the normal map-server inventory path.
 */

#include "common/database.h"
#include "common/logging.h"

#include "map/entities/char_entity.h"
#include "map/enums/chat_message_type.h"
#include "map/item_container.h"
#include "map/ipc_client.h"
#include "map/items.h"
#include "map/items/item_linkshell.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/charutils.h"
#include "map/utils/itemutils.h"
#include "map/utils/moduleutils.h"

#include <chrono>
#include <optional>
#include <string>
#include <utility>

namespace
{

struct ApprovedApplication
{
    uint64      applicationId{};
    uint32      linkshellId{};
    uint32      secondsRemaining{};
    uint16      color{};
    std::string linkshellName;
};

struct OnlineApproval
{
    uint64      applicationId{};
    uint32      applicantCharacterId{};
    std::string linkshellName;
};

constexpr auto NotificationPollInterval = std::chrono::seconds(5);
constexpr auto ExpirationSweepInterval  = std::chrono::minutes(1);

auto recruitmentSchemaExists() -> bool
{
    static std::optional<bool> schemaExists;
    if (schemaExists.has_value())
    {
        return *schemaExists;
    }

    const auto result = db::preparedStmt(
        "SELECT COUNT(DISTINCT column_name) AS column_count "
        "FROM information_schema.columns "
        "WHERE table_schema = DATABASE() "
        "AND table_name = 'linkshell_recruitment_applications' "
        "AND column_name IN ('pearl_claim_expires_at', 'pearl_online_notified_at') "
        "HAVING COUNT(DISTINCT column_name) = 2");
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

void expireDeferredApplications(CCharEntity* player)
{
    db::preparedStmt(
        "UPDATE linkshell_recruitment_applications "
        "SET status = 'withdrawn', active_slot = NULL "
        "WHERE applicant_charid = ? "
        "AND applicant_account_id = ? "
        "AND status = 'approved' "
        "AND active_slot = 1 "
        "AND pearl_delivered_at IS NULL "
        "AND LEAST("
        "COALESCE(decided_at, applied_at) + INTERVAL 7 DAY, "
        "COALESCE(pearl_claim_expires_at, COALESCE(decided_at, applied_at) + INTERVAL 7 DAY)"
        ") <= CURRENT_TIMESTAMP(6)",
        player->id,
        player->accid);
}

void expireAllApplications()
{
    db::preparedStmt(
        "UPDATE linkshell_recruitment_applications "
        "SET status = 'withdrawn', active_slot = NULL "
        "WHERE status = 'approved' "
        "AND active_slot = 1 "
        "AND pearl_delivered_at IS NULL "
        "AND LEAST("
        "COALESCE(decided_at, applied_at) + INTERVAL 7 DAY, "
        "COALESCE(pearl_claim_expires_at, COALESCE(decided_at, applied_at) + INTERVAL 7 DAY)"
        ") <= CURRENT_TIMESTAMP(6)");
}

auto getApprovedApplication(CCharEntity* player) -> std::optional<ApprovedApplication>
{
    const auto result = db::preparedStmt(
        "SELECT a.id, a.linkshell_id, l.name, l.color, "
        "GREATEST(TIMESTAMPDIFF(SECOND, CURRENT_TIMESTAMP(6), LEAST("
        "COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY, "
        "COALESCE(a.pearl_claim_expires_at, COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY)"
        ")), 0) AS seconds_remaining "
        "FROM linkshell_recruitment_applications AS a "
        "INNER JOIN linkshells AS l ON l.linkshellid = a.linkshell_id "
        "WHERE a.applicant_charid = ? "
        "AND a.applicant_account_id = ? "
        "AND a.status = 'approved' "
        "AND a.active_slot = 1 "
        "AND a.pearl_delivered_at IS NULL "
        "AND LEAST("
        "COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY, "
        "COALESCE(a.pearl_claim_expires_at, COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY)"
        ") > CURRENT_TIMESTAMP(6) "
        "AND l.broken = 0 "
        "ORDER BY a.decided_at, a.id "
        "LIMIT 1",
        player->id,
        player->accid);
    if (!result || !result->next())
    {
        return std::nullopt;
    }

    return ApprovedApplication{
        .applicationId    = result->get<uint64>("id"),
        .linkshellId      = result->get<uint32>("linkshell_id"),
        .secondsRemaining = result->get<uint32>("seconds_remaining"),
        .color            = result->get<uint16>("color"),
        .linkshellName    = result->get<std::string>("name"),
    };
}

auto getPendingLinkpearlSecondsRemaining(CLuaBaseEntity* luaEntity) -> uint32
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

    expireDeferredApplications(player);
    const auto application = getApprovedApplication(player);
    return application ? application->secondsRemaining : 0;
}

void markPendingLinkpearlNotified(CLuaBaseEntity* luaEntity, const std::string& expectedLinkshellName)
{
    if (!luaEntity || !recruitmentSchemaExists())
    {
        return;
    }

    auto* player = dynamic_cast<CCharEntity*>(luaEntity->GetBaseEntity());
    if (!player)
    {
        return;
    }

    expireDeferredApplications(player);
    const auto application = getApprovedApplication(player);
    if (!application || application->linkshellName != expectedLinkshellName)
    {
        return;
    }

    db::preparedStmt(
        "UPDATE linkshell_recruitment_applications "
        "SET pearl_online_notified_at = COALESCE(pearl_online_notified_at, CURRENT_TIMESTAMP(6)) "
        "WHERE id = ? "
        "AND status = 'approved' "
        "AND active_slot = 1 "
        "AND pearl_delivered_at IS NULL "
        "LIMIT 1",
        application->applicationId);
}

auto getNextOnlineApproval() -> std::optional<OnlineApproval>
{
    const auto result = db::preparedStmt(
        "SELECT a.id, a.applicant_charid, l.name "
        "FROM linkshell_recruitment_applications AS a "
        "INNER JOIN linkshells AS l ON l.linkshellid = a.linkshell_id "
        "INNER JOIN accounts_sessions AS s ON s.charid = a.applicant_charid "
        "WHERE a.status = 'approved' "
        "AND a.active_slot = 1 "
        "AND a.pearl_delivered_at IS NULL "
        "AND a.pearl_online_notified_at IS NULL "
        "AND a.decided_at >= CURRENT_TIMESTAMP(6) - INTERVAL 1 MINUTE "
        "AND LEAST("
        "COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY, "
        "COALESCE(a.pearl_claim_expires_at, COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY)"
        ") > CURRENT_TIMESTAMP(6) "
        "AND l.broken = 0 "
        "ORDER BY a.decided_at, a.id "
        "LIMIT 1");
    if (!result || !result->next())
    {
        return std::nullopt;
    }

    return OnlineApproval{
        .applicationId       = result->get<uint64>("id"),
        .applicantCharacterId = result->get<uint32>("applicant_charid"),
        .linkshellName       = result->get<std::string>("name"),
    };
}

void notifyNextOnlineApproval()
{
    const auto approval = getNextOnlineApproval();
    if (!approval)
    {
        return;
    }

    const auto claim = db::preparedStmt(
        "UPDATE linkshell_recruitment_applications AS a "
        "INNER JOIN accounts_sessions AS s ON s.charid = a.applicant_charid "
        "SET a.pearl_online_notified_at = CURRENT_TIMESTAMP(6) "
        "WHERE a.id = ? "
        "AND a.status = 'approved' "
        "AND a.active_slot = 1 "
        "AND a.pearl_delivered_at IS NULL "
        "AND a.pearl_online_notified_at IS NULL "
        "AND a.decided_at >= CURRENT_TIMESTAMP(6) - INTERVAL 1 MINUTE "
        "AND LEAST("
        "COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY, "
        "COALESCE(a.pearl_claim_expires_at, COALESCE(a.decided_at, a.applied_at) + INTERVAL 7 DAY)"
        ") > CURRENT_TIMESTAMP(6)",
        approval->applicationId);
    if (!claim || claim->rowsAffected() != 1)
    {
        return;
    }

    message::send(ipc::ChatMessageCustom{
        .recipientId = approval->applicantCharacterId,
        .senderName  = "LS Concierge",
        .message     = fmt::format(
            "Your application to {} was accepted. A linkpearl is waiting at any Linkshell Concierge. "
            "Claim it within seven days of approval.",
            approval->linkshellName),
        .messageType = MESSAGE_SYSTEM_3,
    });
}

auto getPendingLinkpearlName(CLuaBaseEntity* luaEntity) -> std::string
{
    if (!luaEntity || !recruitmentSchemaExists())
    {
        return {};
    }

    auto* player = dynamic_cast<CCharEntity*>(luaEntity->GetBaseEntity());
    if (!player)
    {
        return {};
    }

    expireDeferredApplications(player);
    const auto application = getApprovedApplication(player);
    return application ? application->linkshellName : std::string{};
}

auto claimPendingLinkpearl(CLuaBaseEntity* luaEntity, const std::string& expectedLinkshellName) -> std::string
{
    if (!luaEntity || !recruitmentSchemaExists())
    {
        return "unavailable";
    }

    auto* player = dynamic_cast<CCharEntity*>(luaEntity->GetBaseEntity());
    if (!player)
    {
        return "unavailable";
    }

    expireDeferredApplications(player);
    const auto application = getApprovedApplication(player);
    if (!application)
    {
        return "unavailable";
    }

    if (application->linkshellName != expectedLinkshellName)
    {
        return "unavailable";
    }

    if (hasLinkshellMembership(player->id, application->linkshellId))
    {
        return markDelivered(*application) ? "already_member" : "error";
    }

    if (player->getStorage(LOC_INVENTORY)->GetFreeSlotsCount() == 0)
    {
        return "inventory_full";
    }

    if (!addRecruitmentLinkpearl(player, *application))
    {
        return "error";
    }

    if (!markDelivered(*application))
    {
        ShowWarning(
            "LinkshellRecruitment delivered application %llu to character %u but could not mark it joined.",
            application->applicationId,
            player->id);
    }

    return "delivered";
}

auto deferPendingLinkpearl(CLuaBaseEntity* luaEntity, const std::string& expectedLinkshellName) -> uint32
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

    expireDeferredApplications(player);
    const auto application = getApprovedApplication(player);
    if (!application || application->linkshellName != expectedLinkshellName)
    {
        return 0;
    }

    const auto update = db::preparedStmt(
        "UPDATE linkshell_recruitment_applications "
        "SET pearl_claim_expires_at = COALESCE("
        "pearl_claim_expires_at, LEAST("
        "COALESCE(decided_at, applied_at) + INTERVAL 7 DAY, "
        "CURRENT_TIMESTAMP(6) + INTERVAL 3 DAY)) "
        "WHERE id = ? "
        "AND status = 'approved' "
        "AND active_slot = 1 "
        "AND pearl_delivered_at IS NULL "
        "LIMIT 1",
        application->applicationId);
    if (!update)
    {
        return 0;
    }

    const auto result = db::preparedStmt(
        "SELECT GREATEST("
        "TIMESTAMPDIFF(SECOND, CURRENT_TIMESTAMP(6), LEAST("
        "COALESCE(decided_at, applied_at) + INTERVAL 7 DAY, "
        "pearl_claim_expires_at)), 0) AS seconds_remaining "
        "FROM linkshell_recruitment_applications "
        "WHERE id = ? "
        "AND status = 'approved' "
        "AND active_slot = 1 "
        "AND LEAST("
        "COALESCE(decided_at, applied_at) + INTERVAL 7 DAY, "
        "pearl_claim_expires_at) > CURRENT_TIMESTAMP(6) "
        "LIMIT 1",
        application->applicationId);
    if (!result || !result->next())
    {
        return 0;
    }

    return result->get<uint32>("seconds_remaining");
}

} // namespace

class LinkshellRecruitmentModule final : public CPPModule
{
    void OnInit() override
    {
        auto xiTable = lua["xi"].get_or_create<sol::table>();
        auto table   = xiTable["linkshellRecruitment"].get_or_create<sol::table>();
        table.set_function("getPendingLinkpearlName", getPendingLinkpearlName);
        table.set_function("getPendingLinkpearlSecondsRemaining", getPendingLinkpearlSecondsRemaining);
        table.set_function("markPendingLinkpearlNotified", markPendingLinkpearlNotified);
        table.set_function("claimPendingLinkpearl", claimPendingLinkpearl);
        table.set_function("deferPendingLinkpearl", deferPendingLinkpearl);
    }

    void OnTimeServerTick() override
    {
        const auto now = std::chrono::steady_clock::now();
        if (now < nextNotificationCheck_ && now < nextExpirationSweep_)
        {
            return;
        }

        if (!recruitmentSchemaExists())
        {
            nextNotificationCheck_ = now + NotificationPollInterval;
            nextExpirationSweep_   = now + ExpirationSweepInterval;
            return;
        }

        if (now >= nextExpirationSweep_)
        {
            nextExpirationSweep_ = now + ExpirationSweepInterval;
            expireAllApplications();
        }

        if (now >= nextNotificationCheck_)
        {
            nextNotificationCheck_ = now + NotificationPollInterval;
            notifyNextOnlineApproval();
        }
    }

private:
    std::chrono::steady_clock::time_point nextNotificationCheck_{};
    std::chrono::steady_clock::time_point nextExpirationSweep_{};
};

REGISTER_CPP_MODULE(LinkshellRecruitmentModule);
