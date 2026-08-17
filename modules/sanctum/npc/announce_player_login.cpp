/************************************************************************
 * Player Login Announcements
 *
 * Sends login notifications only to online players whose Linkshell 1
 * matches either active linkshell of the player who logged in.
 ************************************************************************/

#include "common/database.h"

#include "map/entities/char_entity.h"
#include "map/ipc_client.h"
#include "map/linkshell.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/moduleutils.h"

namespace
{

void notifyLinkshellOneMembers(CLuaBaseEntity* luaEntity)
{
    if (luaEntity == nullptr)
    {
        return;
    }

    auto* PChar = dynamic_cast<CCharEntity*>(luaEntity->GetBaseEntity());
    if (PChar == nullptr)
    {
        return;
    }

    const uint32 linkshellId1 = PChar->PLinkshell1 ? PChar->PLinkshell1->getID() : 0;
    const uint32 linkshellId2 = PChar->PLinkshell2 ? PChar->PLinkshell2->getID() : 0;

    if (linkshellId1 == 0 && linkshellId2 == 0)
    {
        return;
    }

    const auto notifyRecipients = [PChar](const auto& rset)
    {
        if (!rset)
        {
            return;
        }

        const auto decoratedMessage = fmt::format("Player {} has logged in.", PChar->getName());
        while (rset->next())
        {
            message::send(ipc::ChatMessageCustom{
                .recipientId = rset->template get<uint32>("charid"),
                .senderName  = "",
                .message     = decoratedMessage,
                .messageType = MESSAGE_SYSTEM_3,
            });
        }
    };

    if (linkshellId1 != 0 && linkshellId2 != 0 && linkshellId1 != linkshellId2)
    {
        notifyRecipients(db::preparedStmt(
            "SELECT charid FROM accounts_sessions "
            "WHERE charid <> ? AND (linkshellid1 = ? OR linkshellid1 = ?)",
            PChar->id,
            linkshellId1,
            linkshellId2));
    }
    else
    {
        const uint32 linkshellId = linkshellId1 != 0 ? linkshellId1 : linkshellId2;
        notifyRecipients(db::preparedStmt(
            "SELECT charid FROM accounts_sessions WHERE charid <> ? AND linkshellid1 = ?",
            PChar->id,
            linkshellId));
    }
}

} // namespace

class AnnouncePlayerLoginModule final : public CPPModule
{
    void OnInit() override
    {
        auto xiTable = lua["xi"].get_or_create<sol::table>();
        auto table   = xiTable["announcePlayerLogin"].get_or_create<sol::table>();
        table.set_function("notifyLinkshellOneMembers", notifyLinkshellOneMembers);
    }
};

REGISTER_CPP_MODULE(AnnouncePlayerLoginModule);
