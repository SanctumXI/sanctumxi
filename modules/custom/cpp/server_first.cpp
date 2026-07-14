/*
 * Server First support
 */

#include "common/database.h"

#include "map/alliance.h"
#include "map/entities/charentity.h"
#include "map/items/item_linkshell.h"
#include "map/lua/lua_baseentity.h"
#include "map/party.h"
#include "map/utils/moduleutils.h"

#include <algorithm>
#include <cctype>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace
{

constexpr std::size_t MaxEventKeyLength = 96;
constexpr std::size_t MaxTextLength     = 255;
constexpr std::size_t MaxMessageLength  = 511;
constexpr std::size_t MaxParticipants   = 36;

// This is populated once at map-server startup.  Synthesis results only need
// an in-memory lookup, never a database query, which keeps the crafting path
// safe to run on every successful synthesis.
std::unordered_map<uint16, std::string> highSkillCrafts;

struct Participant
{
    uint32      charId{};
    std::string charName;
    std::string linkshellName;
    bool        isLeader{};
};

auto shorten(std::string value, const std::size_t length) -> std::string
{
    value.resize(std::min(value.size(), length));
    return value;
}

auto toParticipant(CLuaBaseEntity* luaEntity, sol::state& lua) -> sol::table
{
    auto result = lua.create_table();
    if (!luaEntity)
    {
        return result;
    }

    auto* player = dynamic_cast<CCharEntity*>(luaEntity->GetBaseEntity());
    if (!player)
    {
        return result;
    }

    result["char_id"]   = player->id;
    result["char_name"] = std::string(player->getName());

    // Uses the EQUIPPED linkshell.  A player carrying a second pearl isn't treated as actively representing that LS.
    if (auto* item = dynamic_cast<CItemLinkshell*>(player->getEquip(SLOT_LINK1)); item && item->isType(ITEM_LINKSHELL))
    {
        result["linkshell_name"] = item->getSignature();
    }

    if (player->PParty)
    {
        result["is_party_leader"] = player->PParty->GetLeader() == player;

        if (player->PParty->m_PAlliance && player->PParty->m_PAlliance->getMainParty())
        {
            result["is_alliance_leader"] = player->PParty->m_PAlliance->getMainParty()->GetLeader() == player;
        }
    }

    return result;
}

auto parseParticipants(const sol::table& input) -> std::vector<Participant>
{
    std::vector<Participant> participants;
    std::unordered_set<uint32> seenIds;

    for (const auto& entry : input)
    {
        if (participants.size() == MaxParticipants || !entry.second.is<sol::table>())
        {
            break;
        }

        const auto table = entry.second.as<sol::table>();
        const auto charId = table.get_or("char_id", uint32{});
        const auto charName = shorten(table.get_or("char_name", std::string{}), MaxTextLength);

        if (charId == 0 || charName.empty() || !seenIds.insert(charId).second)
        {
            continue;
        }

        participants.emplace_back(Participant{
            .charId        = charId,
            .charName      = charName,
            .linkshellName = shorten(table.get_or("linkshell_name", std::string{}), MaxTextLength),
            .isLeader      = table.get_or("is_leader", false),
        });
    }

    return participants;
}

auto claimFirst(const sol::table& input) -> bool
{
    const auto eventKey  = shorten(input.get_or("event_key", std::string{}), MaxEventKeyLength);
    const auto category  = shorten(input.get_or("category", std::string{}), MaxTextLength);
    const auto subject   = shorten(input.get_or("subject", std::string{}), MaxTextLength);
    const auto creditType = shorten(input.get_or("credit_type", std::string{}), MaxTextLength);
    const auto creditName = shorten(input.get_or("credit_name", std::string{}), MaxTextLength);
    const auto message   = shorten(input.get_or("message", std::string{}), MaxMessageLength);
    const auto zoneId    = input.get_or("zone_id", uint16{});

    const auto participantObject = input["participants"];
    if (!participantObject.valid() || !participantObject.is<sol::table>())
    {
        ShowWarningFmt("ServerFirst rejected a claim with no roster for event key '{}'", eventKey);
        return false;
    }

    const auto participants = parseParticipants(participantObject.as<sol::table>());

    if (eventKey.empty() || category.empty() || subject.empty() || creditType.empty() || creditName.empty() || message.empty() || participants.empty())
    {
        ShowWarningFmt("ServerFirst rejected an invalid claim for event key '{}'", eventKey);
        return false;
    }

    if (!db::preparedStmt("START TRANSACTION"))
    {
        ShowErrorFmt("ServerFirst could not start the transaction for '{}'", eventKey);
        return false;
    }

    const auto rollback = []()
    {
        db::preparedStmt("ROLLBACK");
    };

    const auto eventInsert = db::preparedStmt(
        "INSERT IGNORE INTO server_first_events "
        "(event_key, category, subject, credit_type, credit_name, zone_id, announced_message, occurred_at) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, UNIX_TIMESTAMP())",
        eventKey,
        category,
        subject,
        creditType,
        creditName,
        zoneId,
        message);

    if (!eventInsert || eventInsert->rowsAffected() != 1)
    {
        rollback();
        return false; // Already claimed by someone else, no server first awarded
    }

    for (const auto& participant : participants)
    {
        const auto rosterInsert = db::preparedStmt(
            "INSERT INTO server_first_participants "
            "(event_key, charid, charname, linkshell_name, is_leader) VALUES (?, ?, ?, NULLIF(?, ''), ?)",
            eventKey,
            participant.charId,
            participant.charName,
            participant.linkshellName,
            participant.isLeader ? 1 : 0);

        if (!rosterInsert || rosterInsert->rowsAffected() != 1)
        {
            ShowErrorFmt("ServerFirst could not archive the roster for '{}'", eventKey);
            rollback();
            return false;
        }
    }

    if (!db::preparedStmt("COMMIT"))
    {
        rollback();
        ShowErrorFmt("ServerFirst could not commit the claim for '{}'", eventKey);
        return false;
    }

    return true;
}

auto recordLegend(const sol::table& input) -> bool
{
    const auto charId     = input.get_or("char_id", uint32{});
    const auto charName   = shorten(input.get_or("char_name", std::string{}), MaxTextLength);
    const auto weaponId   = input.get_or("weapon_id", uint16{});
    const auto weaponName = shorten(input.get_or("weapon_name", std::string{}), MaxTextLength);
    const auto weaponKind = shorten(input.get_or("weapon_kind", std::string{}), MaxTextLength);
    const auto zoneId     = input.get_or("zone_id", uint16{});

    if (charId == 0 || charName.empty() || weaponId == 0 || weaponName.empty() || weaponKind.empty())
    {
        ShowWarning("ServerFirst rejected an invalid legendary-weapon record.");
        return false;
    }

    const auto insert = db::preparedStmt(
        "INSERT INTO server_legendary_weapons "
        "(charid, charname, weapon_id, weapon_name, weapon_kind, zone_id, awarded_at) "
        "VALUES (?, ?, ?, ?, ?, ?, UNIX_TIMESTAMP())",
        charId,
        charName,
        weaponId,
        weaponName,
        weaponKind,
        zoneId);

    return insert && insert->rowsAffected() == 1;
}

auto formatItemName(std::string itemName) -> std::string
{
    bool capitalize = true;

    for (auto& character : itemName)
    {
        if (character == '_')
        {
            character = ' ';
        }

        if (capitalize && std::isalpha(static_cast<unsigned char>(character)))
        {
            character = static_cast<char>(std::toupper(static_cast<unsigned char>(character)));
        }

        capitalize = character == ' ' || character == '-';
    }

    return itemName;
}

void loadHighSkillCrafts()
{
    // The item list is intentionally data-driven.  It captures every pre-SoA
    // Cursed -1 output and every +1 output whose recipe needs a 100+ craft
    // skill, including items added by future database corrections. Cursed
    // pieces are intentionally included at their normal recipe ranks. It runs
    // only during startup; successful synthesis performs a hash-map lookup.
    const auto rset = db::preparedStmt(
        "SELECT DISTINCT item.itemid AS item_id, item.name AS item_name "
        "FROM synth_recipes AS recipe "
        "INNER JOIN ("
        "SELECT ID, Result AS item_id FROM synth_recipes "
        "UNION ALL SELECT ID, ResultHQ1 AS item_id FROM synth_recipes "
        "UNION ALL SELECT ID, ResultHQ2 AS item_id FROM synth_recipes "
        "UNION ALL SELECT ID, ResultHQ3 AS item_id FROM synth_recipes"
        ") AS craft_output ON craft_output.ID = recipe.ID "
        "INNER JOIN item_basic AS item ON item.itemid = craft_output.item_id "
        "WHERE recipe.Desynth = 0 "
        "AND (recipe.content_tag IS NULL OR recipe.content_tag IN ('ZILART', 'COP', 'TOAU', 'WOTG')) "
        "AND ((item.name LIKE 'cursed%' AND RIGHT(item.name, 3) = '_-1') "
        "OR (RIGHT(item.name, 3) = '_+1' "
        "AND GREATEST(recipe.Wood, recipe.Smith, recipe.Gold, recipe.Cloth, "
        "recipe.Leather, recipe.Bone, recipe.Alchemy, recipe.Cook) >= 100))");

    if (!rset)
    {
        ShowError("ServerFirst could not load its high-skill craft catalogue.");
        return;
    }

    highSkillCrafts.clear();
    while (rset->next())
    {
        const auto itemId   = rset->get<uint16>("item_id");
        const auto itemName = rset->get<std::string>("item_name");
        highSkillCrafts.emplace(itemId, formatItemName(itemName));
    }

    ShowInfoFmt("ServerFirst loaded {} high-skill crafted-item announcements.", highSkillCrafts.size());
}

auto getHighSkillCraftName(const uint16 itemId) -> sol::optional<std::string>
{
    if (const auto entry = highSkillCrafts.find(itemId); entry != highSkillCrafts.end())
    {
        return entry->second;
    }

    return sol::nullopt;
}

} // namespace

class ServerFirstModule final : public CPPModule
{
    void OnInit() override
    {
        loadHighSkillCrafts();

        const auto trackedItems = lua["xi"]["serverFirstConfig"]["trackedItemIds"];
        if (trackedItems.valid() && trackedItems.is<sol::table>())
        {
            for (const auto& entry : trackedItems.as<sol::table>())
            {
                if (entry.second.is<uint16>())
                {
                    luautils::RegisterPlayerItemAddedCallback(entry.second.as<uint16>());
                }
            }
        }
        else
        {
            ShowWarning("ServerFirst did not receive its tracked item ID configuration.");
        }

        auto xiTable = lua["xi"].get_or_create<sol::table>();
        auto table = xiTable["serverFirst"].get_or_create<sol::table>();
        table.set_function("participant", [this](CLuaBaseEntity* entity)
        {
            return toParticipant(entity, lua);
        });
        table.set_function("claim", claimFirst);
        table.set_function("recordLegend", recordLegend);
        table.set_function("getHighSkillCraftName", getHighSkillCraftName);
    }
};

REGISTER_CPP_MODULE(ServerFirstModule);
