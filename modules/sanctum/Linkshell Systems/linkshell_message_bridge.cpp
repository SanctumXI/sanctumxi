/*
 * Sanctum companion linkshell-message bridge.
 *
 * The companion API only queues authenticated shellholder requests. A map
 * process claims each request atomically and publishes it through the normal
 * CLinkshell path so online members receive the standard in-game packet.
 */

#include "common/database.h"
#include "common/logging.h"

#include "map/items/item_linkshell.h"
#include "map/linkshell.h"
#include "map/utils/moduleutils.h"

#include <chrono>
#include <cstdint>
#include <optional>
#include <random>
#include <string>

namespace
{

constexpr std::size_t MaxLinkshellMessageLength = 127;

struct MessageCommand
{
    uint64      id{};
    uint32      linkshellId{};
    uint32      authenticatedAccountId{};
    uint32      actorCharacterId{};
    uint32      expectedMessageTime{};
    std::string actorName;
    std::string message;
    std::string expectedMessage;
};

auto messageSchemaExists() -> bool
{
    static std::optional<bool> schemaExists;
    if (schemaExists.has_value())
    {
        return *schemaExists;
    }

    const auto result = db::preparedStmt(
        "SELECT 1 FROM information_schema.tables "
        "WHERE table_schema = DATABASE() "
        "AND table_name = 'linkshell_message_commands' LIMIT 1");
    schemaExists = result && result->rowsCount() > 0;
    return *schemaExists;
}

auto makeClaimToken(const void* moduleAddress) -> std::string
{
    const auto now = std::chrono::high_resolution_clock::now().time_since_epoch().count();
    std::random_device randomDevice;
    return std::to_string(reinterpret_cast<std::uintptr_t>(moduleAddress)) + "-" +
           std::to_string(now) + "-" + std::to_string(randomDevice());
}

auto hasPendingCommand() -> bool
{
    const auto result = db::preparedStmt(
        "SELECT id FROM linkshell_message_commands WHERE status = 'pending' ORDER BY id LIMIT 1");
    return result && result->rowsCount() > 0;
}

auto claimNextCommand(const std::string& claimToken) -> std::optional<MessageCommand>
{
    const auto claim = db::preparedStmt(
        "UPDATE linkshell_message_commands "
        "SET status = 'processing', claim_token = ?, claimed_at = CURRENT_TIMESTAMP(6) "
        "WHERE status = 'pending' ORDER BY id LIMIT 1",
        claimToken);
    if (!claim || claim->rowsAffected() != 1)
    {
        return std::nullopt;
    }

    const auto result = db::preparedStmt(
        "SELECT id, linkshell_id, authenticated_account_id, actor_charid, actor_name, "
        "message, expected_message, expected_messagetime "
        "FROM linkshell_message_commands "
        "WHERE status = 'processing' AND claim_token = ? ORDER BY id LIMIT 1",
        claimToken);
    if (!result || !result->next())
    {
        return std::nullopt;
    }

    return MessageCommand{
        .id                  = result->get<uint64>("id"),
        .linkshellId         = result->get<uint32>("linkshell_id"),
        .authenticatedAccountId = result->get<uint32>("authenticated_account_id"),
        .actorCharacterId    = result->get<uint32>("actor_charid"),
        .expectedMessageTime = result->get<uint32>("expected_messagetime"),
        .actorName           = result->get<std::string>("actor_name"),
        .message             = result->get<std::string>("message"),
        .expectedMessage     = result->getOrDefault<std::string>("expected_message", ""),
    };
}

auto isCurrentShellholder(const MessageCommand& command) -> bool
{
    const auto result = db::preparedStmt(
        "SELECT c.charname, i.extra "
        "FROM chars AS c "
        "INNER JOIN char_inventory AS i ON i.charid = c.charid "
        "WHERE c.charid = ? AND c.accid = ? "
        "AND i.itemId IN (513, 514, 515) AND i.quantity > 0",
        command.actorCharacterId,
        command.authenticatedAccountId);
    if (!result)
    {
        return false;
    }

    while (result->next())
    {
        if (result->get<std::string>("charname") != command.actorName)
        {
            continue;
        }

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
        if (storedId == command.linkshellId && rank == LSTYPE_LINKSHELL)
        {
            return true;
        }
    }

    return false;
}

void finishCommand(const MessageCommand& command, const std::string& claimToken, const std::string& status, const std::string& failureReason = "")
{
    db::preparedStmt(
        "UPDATE linkshell_message_commands "
        "SET status = ?, failure_reason = ?, completed_at = CURRENT_TIMESTAMP(6) "
        "WHERE id = ? AND status = 'processing' AND claim_token = ? LIMIT 1",
        status,
        failureReason,
        command.id,
        claimToken);
}

void processNextCommand(const std::string& claimToken)
{
    if (!hasPendingCommand())
    {
        return;
    }

    const auto command = claimNextCommand(claimToken);
    if (!command.has_value())
    {
        return;
    }

    if (command->message.empty() || command->message.size() > MaxLinkshellMessageLength || command->actorName.empty())
    {
        finishCommand(*command, claimToken, "failed", "The queued linkshell message was invalid.");
        ShowWarningFmt("LinkshellMessageBridge rejected invalid command {}.", command->id);
        return;
    }

    if (!isCurrentShellholder(*command))
    {
        finishCommand(*command, claimToken, "failed", "The requesting character is no longer this linkshell's shellholder.");
        ShowWarningFmt("LinkshellMessageBridge rejected unauthorized command {}.", command->id);
        return;
    }

    auto* PLinkshell = linkshell::GetLinkshell(command->linkshellId);
    const bool loadedForCommand = PLinkshell == nullptr;
    if (loadedForCommand)
    {
        PLinkshell = linkshell::LoadLinkshell(command->linkshellId);
    }

    if (PLinkshell == nullptr)
    {
        finishCommand(*command, claimToken, "failed", "The linkshell no longer exists on the game server.");
        ShowWarningFmt("LinkshellMessageBridge could not load linkshell {} for command {}.", command->linkshellId, command->id);
        return;
    }

    const bool applied = PLinkshell->trySetMessage(
        command->message,
        command->actorName,
        command->expectedMessageTime,
        command->expectedMessage);

    if (loadedForCommand)
    {
        linkshell::UnloadLinkshell(command->linkshellId);
    }

    if (!applied)
    {
        finishCommand(*command, claimToken, "superseded", "The linkshell message changed before this command was applied.");
        return;
    }

    finishCommand(*command, claimToken, "applied");
    ShowInfoFmt("LinkshellMessageBridge published command {} for linkshell {}.", command->id, command->linkshellId);
}

} // namespace

class LinkshellMessageBridgeModule final : public CPPModule
{
    void OnInit() override
    {
        claimToken_ = makeClaimToken(this);
        if (messageSchemaExists())
        {
            // A process can die after claiming a row. Returning only old claims
            // to pending prevents a restart from losing the requested edit.
            db::preparedStmt(
                "UPDATE linkshell_message_commands "
                "SET status = 'pending', claim_token = NULL, claimed_at = NULL "
                "WHERE status = 'processing' "
                "AND claimed_at < CURRENT_TIMESTAMP(6) - INTERVAL 2 MINUTE");
        }
    }

    void OnTimeServerTick() override
    {
        if (messageSchemaExists())
        {
            processNextCommand(claimToken_);
        }
    }

private:
    std::string claimToken_;
};

REGISTER_CPP_MODULE(LinkshellMessageBridgeModule);
