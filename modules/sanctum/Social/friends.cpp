/*
 * Sanctum mutual friends system.
 *
 * The companion dashboard and the in-game !friend command share the same
 * canonical relationship tables. Location is only returned by the dashboard
 * for accepted friends who are currently online.
 */

#include "common/database.h"

#include "map/entities/char_entity.h"
#include "map/enums/chat_message_type.h"
#include "map/ipc_client.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/moduleutils.h"

#include <algorithm>
#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace
{

struct CharacterIdentity
{
    uint32      id{};
    std::string name;
};

auto friendsSchemaExists() -> bool
{
    static std::optional<bool> schemaExists;
    if (schemaExists.has_value())
    {
        return *schemaExists;
    }

    const auto result = db::preparedStmt(
        "SELECT COUNT(*) AS table_count "
        "FROM information_schema.tables "
        "WHERE table_schema = DATABASE() "
        "AND table_name IN ('sanctum_friendships', 'sanctum_friend_preferences') "
        "HAVING COUNT(*) = 2");
    schemaExists = result && result->rowsCount() > 0;
    return *schemaExists;
}

auto getPlayer(CLuaBaseEntity* luaEntity) -> CCharEntity*
{
    return luaEntity ? dynamic_cast<CCharEntity*>(luaEntity->GetBaseEntity()) : nullptr;
}

auto findCharacter(const std::string& name) -> std::optional<CharacterIdentity>
{
    const auto result = db::preparedStmt(
        "SELECT charid, charname FROM chars WHERE charname = ? LIMIT 1",
        name);
    if (!result || !result->next())
    {
        return std::nullopt;
    }

    return CharacterIdentity{
        .id   = result->get<uint32>("charid"),
        .name = result->get<std::string>("charname"),
    };
}

auto pairIds(const uint32 first, const uint32 second) -> std::pair<uint32, uint32>
{
    return { std::min(first, second), std::max(first, second) };
}

auto requestFriend(CLuaBaseEntity* luaEntity, const std::string& targetName) -> std::string
{
    auto* player = getPlayer(luaEntity);
    if (!player || !friendsSchemaExists())
    {
        return "The Sanctum friends system is not installed yet.";
    }

    const auto target = findCharacter(targetName);
    if (!target)
    {
        return fmt::format("No character named {} was found.", targetName);
    }

    if (target->id == player->id)
    {
        return "You cannot send a friend request to yourself.";
    }

    const auto [lowId, highId] = pairIds(player->id, target->id);
    const auto existing = db::preparedStmt(
        "SELECT status, requested_by_charid FROM sanctum_friendships "
        "WHERE character_low_id = ? AND character_high_id = ? LIMIT 1",
        lowId,
        highId);
    if (existing && existing->next())
    {
        const auto status      = existing->get<std::string>("status");
        const auto requestedBy = existing->get<uint32>("requested_by_charid");
        if (status == "accepted")
        {
            return fmt::format("{} is already on your friends list.", target->name);
        }

        return requestedBy == player->id
            ? fmt::format("Your friend request to {} is still pending.", target->name)
            : fmt::format("{} already sent you a request. Use !friend accept {}.", target->name, target->name);
    }

    const auto insert = db::preparedStmt(
        "INSERT INTO sanctum_friendships "
        "(character_low_id, character_high_id, requested_by_charid, status) "
        "VALUES (?, ?, ?, 'pending')",
        lowId,
        highId,
        player->id);
    if (!insert || insert->rowsAffected() != 1)
    {
        return "The friend request could not be saved. Please try again.";
    }

    message::send(ipc::ChatMessageCustom{
        .recipientId = target->id,
        .senderName  = "Friends",
        .message     = fmt::format("{} sent you a friend request. Use !friend accept {} or !friend decline {}.", player->getName(), player->getName(), player->getName()),
        .messageType = MESSAGE_SYSTEM_3,
    });
    return fmt::format("Friend request sent to {}.", target->name);
}

auto acceptFriend(CLuaBaseEntity* luaEntity, const std::string& targetName) -> std::string
{
    auto* player = getPlayer(luaEntity);
    if (!player || !friendsSchemaExists())
    {
        return "The Sanctum friends system is not installed yet.";
    }

    const auto target = findCharacter(targetName);
    if (!target)
    {
        return fmt::format("No character named {} was found.", targetName);
    }

    const auto [lowId, highId] = pairIds(player->id, target->id);
    const auto update = db::preparedStmt(
        "UPDATE sanctum_friendships SET status = 'accepted', accepted_at = CURRENT_TIMESTAMP(6) "
        "WHERE character_low_id = ? AND character_high_id = ? "
        "AND status = 'pending' AND requested_by_charid = ? LIMIT 1",
        lowId,
        highId,
        target->id);
    if (!update || update->rowsAffected() != 1)
    {
        return fmt::format("There is no pending friend request from {}.", target->name);
    }

    message::send(ipc::ChatMessageCustom{
        .recipientId = target->id,
        .senderName  = "Friends",
        .message     = fmt::format("{} accepted your friend request.", player->getName()),
        .messageType = MESSAGE_SYSTEM_3,
    });
    return fmt::format("{} is now on your friends list.", target->name);
}

auto declineFriend(CLuaBaseEntity* luaEntity, const std::string& targetName) -> std::string
{
    auto* player = getPlayer(luaEntity);
    if (!player || !friendsSchemaExists())
    {
        return "The Sanctum friends system is not installed yet.";
    }

    const auto target = findCharacter(targetName);
    if (!target)
    {
        return fmt::format("No character named {} was found.", targetName);
    }

    const auto [lowId, highId] = pairIds(player->id, target->id);
    const auto remove = db::preparedStmt(
        "DELETE FROM sanctum_friendships "
        "WHERE character_low_id = ? AND character_high_id = ? "
        "AND status = 'pending' AND requested_by_charid = ? LIMIT 1",
        lowId,
        highId,
        target->id);
    return remove && remove->rowsAffected() == 1
        ? fmt::format("You declined {}'s friend request.", target->name)
        : fmt::format("There is no pending friend request from {}.", target->name);
}

auto removeFriend(CLuaBaseEntity* luaEntity, const std::string& targetName) -> std::string
{
    auto* player = getPlayer(luaEntity);
    if (!player || !friendsSchemaExists())
    {
        return "The Sanctum friends system is not installed yet.";
    }

    const auto target = findCharacter(targetName);
    if (!target)
    {
        return fmt::format("No character named {} was found.", targetName);
    }

    const auto [lowId, highId] = pairIds(player->id, target->id);
    const auto remove = db::preparedStmt(
        "DELETE FROM sanctum_friendships "
        "WHERE character_low_id = ? AND character_high_id = ? AND status = 'accepted' LIMIT 1",
        lowId,
        highId);
    if (!remove || remove->rowsAffected() != 1)
    {
        return fmt::format("{} is not on your friends list.", target->name);
    }

    db::preparedStmt(
        "DELETE FROM sanctum_friend_preferences "
        "WHERE (owner_charid = ? AND friend_charid = ?) "
        "OR (owner_charid = ? AND friend_charid = ?)",
        player->id,
        target->id,
        target->id,
        player->id);
    return fmt::format("{} was removed from your friends list.", target->name);
}

auto listFriends(CLuaBaseEntity* luaEntity) -> std::string
{
    auto* player = getPlayer(luaEntity);
    if (!player || !friendsSchemaExists())
    {
        return "The Sanctum friends system is not installed yet.";
    }

    const auto result = db::preparedStmt(
        "SELECT c.charname, f.status, f.requested_by_charid, "
        "CASE WHEN s.charid IS NULL THEN 0 ELSE 1 END AS is_online "
        "FROM sanctum_friendships AS f "
        "INNER JOIN chars AS c ON c.charid = CASE "
        "WHEN f.character_low_id = ? THEN f.character_high_id ELSE f.character_low_id END "
        "LEFT JOIN accounts_sessions AS s ON s.charid = c.charid "
        "WHERE f.character_low_id = ? OR f.character_high_id = ? "
        "ORDER BY f.status = 'pending', c.charname",
        player->id,
        player->id,
        player->id);
    if (!result)
    {
        return "The friends list could not be loaded.";
    }

    std::vector<std::string> friends;
    std::vector<std::string> incoming;
    std::vector<std::string> sent;
    while (result->next())
    {
        const auto name = result->get<std::string>("charname");
        if (result->get<std::string>("status") == "accepted")
        {
            friends.emplace_back(fmt::format("{} ({})", name, result->get<uint8>("is_online") != 0 ? "Online" : "Offline"));
        }
        else if (result->get<uint32>("requested_by_charid") == player->id)
        {
            sent.emplace_back(name);
        }
        else
        {
            incoming.emplace_back(name);
        }
    }

    const auto compact = [](const std::vector<std::string>& values) -> std::string
    {
        if (values.empty())
        {
            return "none";
        }

        const auto shown = std::min<size_t>(values.size(), 3);
        std::string text;
        for (size_t index = 0; index < shown; ++index)
        {
            if (!text.empty())
            {
                text += ", ";
            }
            text += values[index];
        }
        if (values.size() > shown)
        {
            text += fmt::format(" (+{} more)", values.size() - shown);
        }
        return text;
    };

    return fmt::format("Friends: {} | Incoming: {} | Sent: {}", compact(friends), compact(incoming), compact(sent));
}

void notifyFriendsOfLogin(CLuaBaseEntity* luaEntity)
{
    auto* player = getPlayer(luaEntity);
    if (!player || !friendsSchemaExists())
    {
        return;
    }

    const auto result = db::preparedStmt(
        "SELECT CASE WHEN f.character_low_id = ? THEN f.character_high_id ELSE f.character_low_id END AS friend_charid "
        "FROM sanctum_friendships AS f "
        "INNER JOIN accounts_sessions AS s ON s.charid = CASE "
        "WHEN f.character_low_id = ? THEN f.character_high_id ELSE f.character_low_id END "
        "LEFT JOIN sanctum_friend_preferences AS p "
        "ON p.owner_charid = s.charid AND p.friend_charid = ? "
        "WHERE (f.character_low_id = ? OR f.character_high_id = ?) "
        "AND f.status = 'accepted' AND COALESCE(p.notify_on_login, 1) = 1",
        player->id,
        player->id,
        player->id,
        player->id,
        player->id);
    if (!result)
    {
        return;
    }

    while (result->next())
    {
        message::send(ipc::ChatMessageCustom{
            .recipientId = result->get<uint32>("friend_charid"),
            .senderName  = "Friends",
            .message     = fmt::format("{} has logged in.", player->getName()),
            .messageType = MESSAGE_SYSTEM_3,
        });
    }
}

} // namespace

class SanctumFriendsModule final : public CPPModule
{
    void OnInit() override
    {
        auto xiTable = lua["xi"].get_or_create<sol::table>();
        auto table   = xiTable["sanctumFriends"].get_or_create<sol::table>();
        table.set_function("request", requestFriend);
        table.set_function("accept", acceptFriend);
        table.set_function("decline", declineFriend);
        table.set_function("remove", removeFriend);
        table.set_function("list", listFriends);
        table.set_function("notifyFriendsOfLogin", notifyFriendsOfLogin);
    }
};

REGISTER_CPP_MODULE(SanctumFriendsModule);
