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

#include "ipc_server.h"

#include "besieged_system.h"
#include "campaign_system.h"
#include "character_cache.h"
#include "colonization_system.h"
#include "conquest_system.h"

#include <algorithm>
#include <concurrentqueue.h>
#include <map>
#include <memory>
#include <unordered_set>

#include "common/database.h"
#include "common/logging.h"

namespace
{

auto getZMQEndpointString() -> std::string
{
    return fmt::format("tcp://{}:{}", settings::get<std::string>("network.ZMQ_IP"), settings::get<uint16>("network.ZMQ_PORT"));
}

auto isAnyZoningChatBufferEnabled() -> bool
{
    return settings::get<bool>("main.ENABLE_TELL_ZONING_BUFFER") ||
           settings::get<bool>("main.ENABLE_PARTY_ZONING_BUFFER") ||
           settings::get<bool>("main.ENABLE_LINKSHELL_ZONING_BUFFER");
}

auto isTargetedChatBufferEnabled(const ipc::ChatMessageTargetType targetType) -> bool
{
    switch (targetType)
    {
        case ipc::ChatMessageTargetType::Party:
        case ipc::ChatMessageTargetType::Alliance:
            return settings::get<bool>("main.ENABLE_PARTY_ZONING_BUFFER");
        case ipc::ChatMessageTargetType::Linkshell:
            return settings::get<bool>("main.ENABLE_LINKSHELL_ZONING_BUFFER");
    }

    return false;
}

constexpr uint8 kMaxTargetedChatRetries = 3;

} // namespace

IPCServer::IPCServer(WorldEngine& worldServer)
: worldServer_(worldServer)
, zmqRouterWrapper_(getZMQEndpointString())
{
    TracyZoneScoped;
}

//
// IPP Lookup
//

auto IPCServer::getIPPForCharId(uint32 charId) -> Maybe<IPP>
{
    TracyZoneScoped;

    // TODO: We know when chars move, we could be caching this info
    // if (const auto cachedIPP = characterCache_.getCharacterIPP(charId))
    // {
    //     return *cachedIPP;
    // }

    const auto rset = db::preparedStmt("SELECT server_addr, server_port FROM accounts_sessions WHERE charid = ? LIMIT 1", charId);
    if (rset && rset->rowsCount() && rset->next())
    {
        const auto ip   = rset->get<uint32>("server_addr");
        const auto port = rset->get<uint16>("server_port");
        const auto ipp  = IPP(ip, port);

        // characterCache_.updateCharacter(charId, ipp);

        return ipp;
    }

    return std::nullopt;
}

auto IPCServer::getRouteForCharId(const uint32 charId) -> Maybe<CharacterRoute>
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT sessions.charid, sessions.server_addr, sessions.server_port, "
                                       "COALESCE(stats.zoning, 0) AS zoning "
                                       "FROM accounts_sessions AS sessions "
                                       "LEFT JOIN char_stats AS stats ON sessions.charid = stats.charid "
                                       "WHERE sessions.charid = ? LIMIT 1",
                                       charId);
    if (rset && rset->rowsCount() && rset->next())
    {
        return CharacterRoute{
            .charId   = rset->get<uint32>("charid"),
            .ipp      = IPP(rset->get<uint32>("server_addr"), rset->get<uint16>("server_port")),
            .isZoning = rset->get<uint8>("zoning") != 0,
        };
    }

    return std::nullopt;
}

auto IPCServer::getIPPForCharName(const std::string& charName) -> Maybe<IPP>
{
    TracyZoneScoped;

    // TODO: We know when chars move, we could be caching this info

    if (const auto route = getRouteForCharName(charName))
    {
        return route->ipp;
    }

    return std::nullopt;
}

auto IPCServer::getRouteForCharName(const std::string& charName) -> Maybe<CharacterRoute>
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT chars.charid, server_addr, server_port, char_stats.zoning FROM accounts_sessions "
                                       "LEFT JOIN chars ON accounts_sessions.charid = chars.charid "
                                       "LEFT JOIN char_stats ON accounts_sessions.charid = char_stats.charid "
                                       "WHERE charname = ? LIMIT 1",
                                       charName);
    if (rset && rset->rowsCount() && rset->next())
    {
        return CharacterRoute{
            .charId   = rset->get<uint32>("charid"),
            .ipp      = IPP(rset->get<uint32>("server_addr"), rset->get<uint16>("server_port")),
            .isZoning = rset->get<uint8>("zoning") != 0,
        };
    }

    return std::nullopt;
}

auto IPCServer::getIPPForZoneId(uint16 zoneId) -> Maybe<IPP>
{
    TracyZoneScoped;

    // TODO: Using the cache we can know if a whole process has no active players on it,
    //     : so we could omit forwarding messages to it

    if (const auto it = zoneSettings_.zoneSettingsMap_.find(zoneId); it != zoneSettings_.zoneSettingsMap_.end())
    {
        return it->second.ipp;
    }

    return std::nullopt;
}

auto IPCServer::getIPPsForParty(uint32 partyId) -> std::vector<IPP>
{
    TracyZoneScoped;

    // TODO: We know when chars move, we could be caching this info

    // TODO: Simplify query now that there's alliance versions?
    const auto query = "SELECT server_addr, server_port, MIN(charid) FROM accounts_sessions JOIN accounts_parties USING (charid) "
                       "WHERE IF (allianceid <> 0, allianceid = (SELECT MAX(allianceid) FROM accounts_parties WHERE partyid = ?), "
                       "partyid = ?) GROUP BY server_addr, server_port";

    const auto rset = db::preparedStmt(query, partyId, partyId);
    if (rset && rset->rowsCount())
    {
        std::vector<IPP> ippList;
        while (rset->next())
        {
            const auto ip   = rset->get<uint64>("server_addr");
            const auto port = rset->get<uint64>("server_port");
            ippList.emplace_back(ip, port);
        }

        return ippList;
    }

    return {};
}

auto IPCServer::getIPPsForAlliance(uint32 allianceId) -> std::vector<IPP>
{
    TracyZoneScoped;

    // TODO: We know when chars move, we could be caching this info

    const auto query = "SELECT server_addr, server_port, MIN(charid) FROM accounts_sessions JOIN accounts_parties USING (charid) "
                       "WHERE allianceid = ? "
                       "GROUP BY server_addr, server_port";

    const auto rset = db::preparedStmt(query, allianceId);
    if (rset && rset->rowsCount())
    {
        std::vector<IPP> ippList;
        while (rset->next())
        {
            const auto ip   = rset->get<uint64>("server_addr");
            const auto port = rset->get<uint64>("server_port");
            ippList.emplace_back(ip, port);
        }

        return ippList;
    }

    return {};
}

auto IPCServer::getIPPsForLinkshell(uint32 linkshellId) -> std::vector<IPP>
{
    TracyZoneScoped;

    // TODO: We know when chars move, we could be caching this info

    const auto query = "SELECT server_addr, server_port FROM accounts_sessions "
                       "WHERE linkshellid1 = ? OR linkshellid2 = ? GROUP BY server_addr, server_port";

    const auto rset = db::preparedStmt(query, linkshellId, linkshellId);
    if (rset && rset->rowsCount())
    {
        std::vector<IPP> ippList;
        while (rset->next())
        {
            const auto ip   = rset->get<uint64>("server_addr");
            const auto port = rset->get<uint64>("server_port");
            ippList.emplace_back(ip, port);
        }

        return ippList;
    }

    return {};
}

auto IPCServer::getRoutesForParty(const uint32 partyId) -> std::vector<CharacterRoute>
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT sessions.charid, sessions.server_addr, sessions.server_port, "
                                       "COALESCE(stats.zoning, 0) AS zoning "
                                       "FROM accounts_sessions AS sessions "
                                       "JOIN accounts_parties AS parties ON sessions.charid = parties.charid "
                                       "LEFT JOIN char_stats AS stats ON sessions.charid = stats.charid "
                                       "WHERE parties.partyid = ?",
                                       partyId);

    auto routes = std::vector<CharacterRoute>{};
    if (rset && rset->rowsCount())
    {
        routes.reserve(rset->rowsCount());
        while (rset->next())
        {
            routes.emplace_back(CharacterRoute{
                .charId   = rset->get<uint32>("charid"),
                .ipp      = IPP(rset->get<uint32>("server_addr"), rset->get<uint16>("server_port")),
                .isZoning = rset->get<uint8>("zoning") != 0,
            });
        }
    }

    return routes;
}

auto IPCServer::getRoutesForAlliance(const uint32 allianceId) -> std::vector<CharacterRoute>
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT sessions.charid, sessions.server_addr, sessions.server_port, "
                                       "COALESCE(stats.zoning, 0) AS zoning "
                                       "FROM accounts_sessions AS sessions "
                                       "JOIN accounts_parties AS parties ON sessions.charid = parties.charid "
                                       "LEFT JOIN char_stats AS stats ON sessions.charid = stats.charid "
                                       "WHERE parties.allianceid = ?",
                                       allianceId);

    auto routes = std::vector<CharacterRoute>{};
    if (rset && rset->rowsCount())
    {
        routes.reserve(rset->rowsCount());
        while (rset->next())
        {
            routes.emplace_back(CharacterRoute{
                .charId   = rset->get<uint32>("charid"),
                .ipp      = IPP(rset->get<uint32>("server_addr"), rset->get<uint16>("server_port")),
                .isZoning = rset->get<uint8>("zoning") != 0,
            });
        }
    }

    return routes;
}

auto IPCServer::getRoutesForLinkshell(const uint32 linkshellId) -> std::vector<CharacterRoute>
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT sessions.charid, sessions.server_addr, sessions.server_port, "
                                       "COALESCE(stats.zoning, 0) AS zoning "
                                       "FROM accounts_sessions AS sessions "
                                       "LEFT JOIN char_stats AS stats ON sessions.charid = stats.charid "
                                       "WHERE sessions.linkshellid1 = ? OR sessions.linkshellid2 = ?",
                                       linkshellId,
                                       linkshellId);

    auto routes = std::vector<CharacterRoute>{};
    if (rset && rset->rowsCount())
    {
        routes.reserve(rset->rowsCount());
        while (rset->next())
        {
            routes.emplace_back(CharacterRoute{
                .charId   = rset->get<uint32>("charid"),
                .ipp      = IPP(rset->get<uint32>("server_addr"), rset->get<uint16>("server_port")),
                .isZoning = rset->get<uint8>("zoning") != 0,
            });
        }
    }

    return routes;
}

auto IPCServer::getIPPsForUnity(uint32 unityId) -> std::vector<IPP>
{
    TracyZoneScoped;

    // TODO: We know when chars move, we could be caching this info

    const auto query = "SELECT server_addr, server_port FROM accounts_sessions "
                       "WHERE unitychat = ? GROUP BY server_addr, server_port";

    const auto rset = db::preparedStmt(query, unityId);
    if (rset && rset->rowsCount())
    {
        std::vector<IPP> ippList;
        while (rset->next())
        {
            const auto ip   = rset->get<uint64>("server_addr");
            const auto port = rset->get<uint64>("server_port");
            ippList.emplace_back(ip, port);
        }

        return ippList;
    }

    return {};
}

auto IPCServer::getIPPsForYellZones() -> std::vector<IPP>
{
    TracyZoneScoped;

    return zoneSettings_.yellMapEndpoints_;
}

auto IPCServer::getIPPsForAssistZones() -> std::vector<IPP>
{
    TracyZoneScoped;

    return zoneSettings_.assistMapEndpoints_;
}

auto IPCServer::getIPPsForAllZones() -> std::vector<IPP>
{
    TracyZoneScoped;

    // TODO: Using the cache we can know if a whole process has no active players on it,
    //     : so we could omit forwarding messages to it

    return zoneSettings_.mapEndpoints_;
}

//
// Message routing
//

void IPCServer::rerouteMessageToCharId(uint32 charId, const auto& message)
{
    TracyZoneScoped;

    if (const auto maybeCharIPP = getIPPForCharId(charId))
    {
        const auto charIPP = *maybeCharIPP;
        DebugIPCFmt("Message: -> rerouting to char<{}> on {}", charId, charIPP.toString());
        sendMessage(charIPP, std::move(message));
    }
}

void IPCServer::rerouteMessageToCharName(const std::string& charName, const auto& message)
{
    TracyZoneScoped;

    if (const auto maybeCharIPP = getIPPForCharName(charName))
    {
        const auto charIPP = *maybeCharIPP;
        DebugIPCFmt("Message: -> rerouting to char<{}> on {}", charName, charIPP.toString());
        sendMessage(charIPP, std::move(message));
    }
}

void IPCServer::rerouteMessageToZoneId(uint16 zoneId, const auto& message)
{
    TracyZoneScoped;

    if (const auto maybeZoneIPP = getIPPForZoneId(zoneId))
    {
        const auto zoneIPP = *maybeZoneIPP;
        DebugIPCFmt("Message: -> rerouting to zone<{}> on {}", zoneId, zoneIPP.toString());
        sendMessage(zoneIPP, std::move(message));
    }
}

void IPCServer::rerouteMessageToPartyMembers(uint32 partyId, const auto& message)
{
    TracyZoneScoped;

    for (const auto& ipp : getIPPsForParty(partyId))
    {
        DebugIPCFmt("Message: -> rerouting to party<{}> on {}", partyId, ipp.toString());
        sendMessage(ipp, message);
    }
}

void IPCServer::rerouteMessageToAllianceMembers(uint32 allianceId, const auto& message)
{
    TracyZoneScoped;

    for (const auto& ipp : getIPPsForAlliance(allianceId))
    {
        DebugIPCFmt("Message: -> rerouting to alliance<{}> on {}", allianceId, ipp.toString());
        sendMessage(ipp, message);
    }
}

void IPCServer::rerouteMessageToLinkshellMembers(uint32 linkshellId, const auto& message)
{
    TracyZoneScoped;

    for (const auto& ipp : getIPPsForLinkshell(linkshellId))
    {
        DebugIPCFmt("Message: -> rerouting to linkshell<{}> on {}", linkshellId, ipp.toString());
        sendMessage(ipp, message);
    }
}

void IPCServer::routeTargetedChat(const std::vector<CharacterRoute>& routes, const ipc::ChatMessageTargeted& message)
{
    TracyZoneScoped;

    auto activeRecipients = std::map<IPP, std::vector<uint32>>{};
    auto seenRecipients   = std::unordered_set<uint32>{};

    const auto bufferRecipient = [this, &message](const uint32 recipientId)
    {
        auto bufferedMessage         = message;
        bufferedMessage.recipientIds = { recipientId };
        if (!zoningChatBuffer_.enqueueTargeted(recipientId, bufferedMessage))
        {
            ShowWarningFmt("Zoning chat buffer is full for char ID {}", recipientId);
        }
    };

    for (const auto& route : routes)
    {
        if (!seenRecipients.emplace(route.charId).second)
        {
            continue;
        }

        if (route.charId == message.senderId)
        {
            continue;
        }

        const bool isZoning = route.isZoning || zoningChatBuffer_.isTransitioning(route.charId);
        if (isZoning)
        {
            bufferRecipient(route.charId);
            continue;
        }

        activeRecipients[route.ipp].emplace_back(route.charId);
    }

    // Session-backed membership can temporarily disappear while the old map
    // tears down the character and the destination map rebuilds it. Merge the
    // immutable zone-out snapshot so those recipients are still buffered.
    for (const auto recipientId : zoningChatBuffer_.getTransitioningRecipients(message.targetType, message.groupId))
    {
        if (recipientId == message.senderId || !seenRecipients.emplace(recipientId).second)
        {
            continue;
        }

        bufferRecipient(recipientId);
        DebugIPCFmt("Buffered targeted group chat for snapshot recipient char<{}>", recipientId);
    }

    for (auto& [ipp, recipientIds] : activeRecipients)
    {
        auto routedMessage         = message;
        routedMessage.recipientIds = std::move(recipientIds);
        DebugIPCFmt("Message: -> routing targeted group chat to {} recipient(s) on {}", routedMessage.recipientIds.size(), ipp.toString());
        sendMessage(ipp, routedMessage);
    }
}

void IPCServer::rerouteMessageToUnityMembers(uint32 unityId, const auto& message)
{
    TracyZoneScoped;

    for (const auto& ipp : getIPPsForUnity(unityId))
    {
        DebugIPCFmt("Message: -> rerouting to unity<{}> on {}", unityId, ipp.toString());
        sendMessage(ipp, message);
    }
}

void IPCServer::rerouteMessageToYellZones(const auto& message)
{
    TracyZoneScoped;

    for (const auto& ipp : getIPPsForYellZones())
    {
        DebugIPCFmt("Message: -> rerouting to yell zone on {}", ipp.toString());
        sendMessage(ipp, message);
    }
}

void IPCServer::rerouteMessageToAssistZones(const auto& message)
{
    TracyZoneScoped;

    for (const auto& ipp : getIPPsForAssistZones())
    {
        DebugIPCFmt("Message: -> rerouting to assist zone on {}", ipp.toString());
        sendMessage(ipp, message);
    }
}

void IPCServer::rerouteMessageToAllZones(const auto& message)
{
    TracyZoneScoped;

    for (const auto& ipp : getIPPsForAllZones())
    {
        DebugIPCFmt("Message: -> rerouting to all zones on {}", ipp.toString());
        sendMessage(ipp, message);
    }
}

void IPCServer::handleIncomingMessages()
{
    TracyZoneScoped;

    // TODO: Can we stop more messages appearing on the queue while we're processing?
    IPPMessage message;
    while (zmqRouterWrapper_.incomingQueue_.try_dequeue(message))
    {
        const auto firstByte = message.payload[0];
        const auto msgType   = ipc::toString(static_cast<ipc::MessageType>(firstByte));

        DebugIPCFmt("Incoming {} message from {}", msgType, message.ipp.toString());

        handleMessage(message.ipp, { message.payload.data(), message.payload.size() });
    }

    expireZoningChatBuffers();
}

void IPCServer::discardBufferedMessages(const std::vector<ZoningChatBuffer::BufferedMessage>& messages)
{
    TracyZoneScoped;

    for (const auto& message : messages)
    {
        if (const auto* tell = std::get_if<ipc::ChatMessageTell>(&message))
        {
            rerouteMessageToCharId(tell->senderId, ipc::MessageStandard{
                                                       .recipientId = tell->senderId,
                                                       .message     = MsgStd::TellNotReceivedOffline,
                                                   });
        }
    }
}

void IPCServer::expireZoningChatBuffers()
{
    TracyZoneScoped;

    for (auto& transition : zoningChatBuffer_.expireTransitions())
    {
        if (!transition.messages.empty())
        {
            const auto tellCount = std::count_if(transition.messages.begin(), transition.messages.end(), [](const auto& message)
                                                 {
                                                     return std::holds_alternative<ipc::ChatMessageTell>(message);
                                                 });

            ShowWarningFmt("Zoning chat buffer expired for char ID {} with {} pending message(s), including {} tell(s)",
                           transition.charId,
                           transition.messages.size(),
                           tellCount);
            discardBufferedMessages(transition.messages);
        }
    }
}

void IPCServer::handleMessage_EmptyStruct(const IPP& ipp, const ipc::EmptyStruct& message)
{
    TracyZoneScoped;

    ShowWarningFmt("Received EmptyStruct message from {} - this is probably a bug", ipp.toString());
}

void IPCServer::handleMessage_AccountLogin(const IPP& ipp, const ipc::AccountLogin& message)
{
    TracyZoneScoped;

    DebugIPCFmt("Received AccountLogin message from {} for account {}", ipp.toString(), message.accountId);

    for (const auto& zoneIIP : getIPPsForAllZones())
    {
        DebugIPCFmt("Message: -> rerouting to all zones on {}", ipp.toString());
        sendMessage(zoneIIP, message);
    }
}

void IPCServer::handleMessage_CharZone(const IPP& ipp, const ipc::CharZone& message)
{
    TracyZoneScoped;

    // Update cache
    if (message.destinationZoneId == 0xFFFF)
    {
        characterCache_.removeCharacter(message.charId);
        discardBufferedMessages(zoningChatBuffer_.completeTransition(message.charId));
    }
    else
    {
        if (isAnyZoningChatBufferEnabled())
        {
            zoningChatBuffer_.beginTransition(message.charId, ZoningChatBuffer::MembershipSnapshot{
                                                                  .partyId      = message.partyId,
                                                                  .allianceId   = message.allianceId,
                                                                  .linkshellId1 = message.linkshellId1,
                                                                  .linkshellId2 = message.linkshellId2,
                                                              });
        }

        if (const auto maybeIPP = getIPPForZoneId(message.destinationZoneId))
        {
            characterCache_.updateCharacter(message.charId, *maybeIPP);
            rerouteMessageToZoneId(message.destinationZoneId, message);
        }
    }
}

void IPCServer::handleMessage_ChatZoneReady(const IPP& ipp, const ipc::ChatZoneReady& message)
{
    TracyZoneScoped;

    auto messages = zoningChatBuffer_.completeTransition(message.charId);
    if (messages.empty())
    {
        return;
    }

    DebugIPCFmt("Replaying {} buffered chat message(s) to char<{}> on {}", messages.size(), message.charId, ipp.toString());
    for (const auto& bufferedMessage : messages)
    {
        std::visit([this, &ipp](const auto& queuedMessage)
                   {
                       sendMessage(ipp, queuedMessage);
                   },
                   bufferedMessage);
    }
}

void IPCServer::handleMessage_CharVarUpdate(const IPP& ipp, const ipc::CharVarUpdate& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.charId, message);
}

void IPCServer::handleMessage_ChatMessageTell(const IPP& ipp, const ipc::ChatMessageTell& message)
{
    TracyZoneScoped;

    const auto route = getRouteForCharName(message.recipientName);
    if (!route)
    {
        sendMessage(ipp, ipc::MessageStandard{
                             .recipientId = message.senderId,
                             .message     = MsgStd::TellNotReceivedOffline,
                         });
        return;
    }

    const bool bufferEnabled = settings::get<bool>("main.ENABLE_TELL_ZONING_BUFFER");
    const bool isZoning      = route->isZoning || zoningChatBuffer_.isTransitioning(route->charId);
    if (bufferEnabled && isZoning)
    {
        if (!zoningChatBuffer_.enqueueTell(route->charId, message))
        {
            ShowWarningFmt("Tell zoning buffer is full for char ID {}", route->charId);
            sendMessage(ipp, ipc::MessageStandard{
                                 .recipientId = message.senderId,
                                 .message     = MsgStd::TellNotReceivedOffline,
                             });
        }
        return;
    }

    sendMessage(route->ipp, message);
}

void IPCServer::handleMessage_ChatMessageTellRetry(const IPP& ipp, const ipc::ChatMessageTellRetry& message)
{
    TracyZoneScoped;
    std::ignore = ipp;

    const auto& tell  = message.tell;
    const auto  route = getRouteForCharName(tell.recipientName);

    const bool bufferEnabled = settings::get<bool>("main.ENABLE_TELL_ZONING_BUFFER");
    const bool isZoning      = route && (route->isZoning || zoningChatBuffer_.isTransitioning(route->charId));
    if (bufferEnabled && isZoning && zoningChatBuffer_.enqueueTell(route->charId, tell))
    {
        DebugIPCFmt("Recovered an early zoning tell for char<{}>", route->charId);
        return;
    }

    if (bufferEnabled && isZoning)
    {
        ShowWarningFmt("Tell zoning buffer is full for char ID {}", route->charId);
    }

    rerouteMessageToCharId(tell.senderId, ipc::MessageStandard{
                                              .recipientId = tell.senderId,
                                              .message     = MsgStd::TellNotReceivedOffline,
                                          });
}

void IPCServer::handleMessage_ChatMessageParty(const IPP& ipp, const ipc::ChatMessageParty& message)
{
    TracyZoneScoped;

    if (settings::get<bool>("main.ENABLE_PARTY_ZONING_BUFFER"))
    {
        routeTargetedChat(getRoutesForParty(message.partyId), ipc::ChatMessageTargeted{
                                                                  .groupId     = message.partyId,
                                                                  .senderId    = message.senderId,
                                                                  .senderName  = message.senderName,
                                                                  .message     = message.message,
                                                                  .zoneId      = message.zoneId,
                                                                  .gmLevel     = message.gmLevel,
                                                                  .messageType = message.messageType,
                                                                  .targetType  = ipc::ChatMessageTargetType::Party,
                                                              });
    }
    else
    {
        rerouteMessageToPartyMembers(message.partyId, message);
    }
}

void IPCServer::handleMessage_ChatMessageAlliance(const IPP& ipp, const ipc::ChatMessageAlliance& message)
{
    TracyZoneScoped;

    if (settings::get<bool>("main.ENABLE_PARTY_ZONING_BUFFER"))
    {
        routeTargetedChat(getRoutesForAlliance(message.allianceId), ipc::ChatMessageTargeted{
                                                                        .groupId     = message.allianceId,
                                                                        .senderId    = message.senderId,
                                                                        .senderName  = message.senderName,
                                                                        .message     = message.message,
                                                                        .zoneId      = message.zoneId,
                                                                        .gmLevel     = message.gmLevel,
                                                                        .messageType = message.messageType,
                                                                        .targetType  = ipc::ChatMessageTargetType::Alliance,
                                                                    });
    }
    else
    {
        rerouteMessageToAllianceMembers(message.allianceId, message);
    }
}

void IPCServer::handleMessage_ChatMessageLinkshell(const IPP& ipp, const ipc::ChatMessageLinkshell& message)
{
    TracyZoneScoped;

    if (settings::get<bool>("main.ENABLE_LINKSHELL_ZONING_BUFFER"))
    {
        routeTargetedChat(getRoutesForLinkshell(message.linkshellId), ipc::ChatMessageTargeted{
                                                                          .groupId     = message.linkshellId,
                                                                          .senderId    = message.senderId,
                                                                          .senderName  = message.senderName,
                                                                          .message     = message.message,
                                                                          .zoneId      = message.zoneId,
                                                                          .gmLevel     = message.gmLevel,
                                                                          .messageType = MESSAGE_LINKSHELL,
                                                                          .targetType  = ipc::ChatMessageTargetType::Linkshell,
                                                                      });
    }
    else
    {
        rerouteMessageToLinkshellMembers(message.linkshellId, message);
    }
}

void IPCServer::handleMessage_ChatMessageTargeted(const IPP& ipp, const ipc::ChatMessageTargeted& message)
{
    // Targeted group chat only travels from world to map.
    std::ignore = ipp;
    std::ignore = message;
}

void IPCServer::handleMessage_ChatMessageTargetedRetry(const IPP& ipp, const ipc::ChatMessageTargetedRetry& message)
{
    TracyZoneScoped;
    std::ignore = ipp;

    if (!isTargetedChatBufferEnabled(message.message.targetType))
    {
        return;
    }

    for (const auto recipientId : message.message.recipientIds)
    {
        const auto route             = getRouteForCharId(recipientId);
        const bool isZoning          = route && (route->isZoning || zoningChatBuffer_.isTransitioning(recipientId));
        auto       bufferedMessage   = message.message;
        bufferedMessage.recipientIds = { recipientId };

        if (isZoning && zoningChatBuffer_.enqueueTargeted(recipientId, bufferedMessage))
        {
            DebugIPCFmt("Recovered an early zoning group message for char<{}>", recipientId);
            continue;
        }

        if (isZoning)
        {
            ShowWarningFmt("Zoning chat buffer is full for char ID {}", recipientId);
            continue;
        }

        // A route can change after world releases the transition. Re-resolve
        // it a small number of times; the map only requests a retry before it
        // has delivered the packet, so this cannot duplicate a successful send.
        if (route && bufferedMessage.retryCount < kMaxTargetedChatRetries)
        {
            ++bufferedMessage.retryCount;
            DebugIPCFmt("Rerouting targeted group chat retry {} for char<{}> on {}",
                        bufferedMessage.retryCount,
                        recipientId,
                        route->ipp.toString());
            sendMessage(route->ipp, bufferedMessage);
            continue;
        }

        ShowWarningFmt("Dropping targeted group chat for char<{}> after {} retry attempt(s)", recipientId, bufferedMessage.retryCount);
    }
}

void IPCServer::handleMessage_ChatMessageUnity(const IPP& ipp, const ipc::ChatMessageUnity& message)
{
    TracyZoneScoped;

    rerouteMessageToUnityMembers(message.unityLeaderId, message);
}

void IPCServer::handleMessage_ChatMessageYell(const IPP& ipp, const ipc::ChatMessageYell& message)
{
    TracyZoneScoped;

    rerouteMessageToYellZones(message);
}

void IPCServer::handleMessage_ChatMessageAssist(const IPP& ipp, const ipc::ChatMessageAssist& message)
{
    TracyZoneScoped;

    rerouteMessageToAssistZones(message);
}

void IPCServer::handleMessage_ChatMessageServerMessage(const IPP& ipp, const ipc::ChatMessageServerMessage& message)
{
    TracyZoneScoped;

    rerouteMessageToAllZones(message);
}

void IPCServer::handleMessage_ChatMessageCustom(const IPP& ipp, const ipc::ChatMessageCustom& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.recipientId, message);
}

void IPCServer::handleMessage_PartyInvite(const IPP& ipp, const ipc::PartyInvite& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.inviteeId, message);

    // TODO:
    // worldServer_.partySystem_->handleMessage(message);
}

void IPCServer::handleMessage_PartyInviteResponse(const IPP& ipp, const ipc::PartyInviteResponse& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.inviterId, message);

    // TODO:
    // worldServer_.partySystem_->handleMessage(message);
}

void IPCServer::handleMessage_PartyReload(const IPP& ipp, const ipc::PartyReload& message)
{
    TracyZoneScoped;

    rerouteMessageToPartyMembers(message.partyId, message);

    // TODO:
    // worldServer_.partySystem_->handleMessage(message);
}

void IPCServer::handleMessage_PartyDisband(const IPP& ipp, const ipc::PartyDisband& message)
{
    TracyZoneScoped;

    rerouteMessageToPartyMembers(message.partyId, message);

    // TODO:
    // worldServer_.partySystem_->handleMessage(message);
}

void IPCServer::handleMessage_AllianceReload(const IPP& ipp, const ipc::AllianceReload& message)
{
    TracyZoneScoped;

    rerouteMessageToAllianceMembers(message.allianceId, message);

    // TODO:
    // worldServer_.partySystem_->handleMessage(message);
}

void IPCServer::handleMessage_AllianceDissolve(const IPP& ipp, const ipc::AllianceDissolve& message)
{
    TracyZoneScoped;

    rerouteMessageToAllianceMembers(message.allianceId, message);

    // TODO:
    // worldServer_.partySystem_->handleMessage(message);
}

void IPCServer::handleMessage_PlayerKick(const IPP& ipp, const ipc::PlayerKick& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.victimId, message);

    // TODO:
    // worldServer_.partySystem_->handleMessage(message);
}

void IPCServer::handleMessage_MessageStandard(const IPP& ipp, const ipc::MessageStandard& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.recipientId, message);
}

void IPCServer::handleMessage_MessageSystem(const IPP& ipp, const ipc::MessageSystem& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.recipientId, message);
}

void IPCServer::handleMessage_LinkshellRankChange(const IPP& ipp, const ipc::LinkshellRankChange& message)
{
    TracyZoneScoped;

    rerouteMessageToCharName(message.memberName, message);
}

void IPCServer::handleMessage_LinkshellRemove(const IPP& ipp, const ipc::LinkshellRemove& message)
{
    TracyZoneScoped;

    rerouteMessageToCharName(message.victimName, message);
}

void IPCServer::handleMessage_LinkshellSetMessage(const IPP& ipp, const ipc::LinkshellSetMessage& message)
{
    TracyZoneScoped;

    rerouteMessageToLinkshellMembers(message.linkshellId, message);
}

void IPCServer::handleMessage_LuaFunction(const IPP& ipp, const ipc::LuaFunction& message)
{
    TracyZoneScoped;

    rerouteMessageToZoneId(message.executorZoneId, message);
}

void IPCServer::handleMessage_KillSession(const IPP& ipp, const ipc::KillSession& message)
{
    TracyZoneScoped;

    const auto rset = db::preparedStmt("SELECT pos_prevzone, pos_zone from chars where charid = ? LIMIT 1", message.victimId);

    // Get zone ID from query and try to send to _just_ the previous zone
    if (rset && rset->rowsCount() && rset->next())
    {
        const auto prevZoneID = rset->get<uint32>("pos_prevzone");
        const auto nextZoneID = rset->get<uint32>("pos_zone");

        if (prevZoneID != nextZoneID)
        {
            const auto zoneSettings = zoneSettings_.zoneSettingsMap_.at(prevZoneID);

            DebugIPCFmt("Message: -> rerouting to {}", zoneSettings.ipp.toString());

            sendMessage(zoneSettings.ipp, message);
        }
    }
    else // Otherwise, send to all zones
    {
        for (const auto& ipp : zoneSettings_.mapEndpoints_)
        {
            DebugIPCFmt("Message: -> rerouting to {}", ipp.toString());

            sendMessage(ipp, message);
        }
    }
}

void IPCServer::handleMessage_ConquestEvent(const IPP& ipp, const ipc::ConquestEvent& message)
{
    TracyZoneScoped;

    worldServer_.conquestSystem_->handleMessage(message.type, { ipp, message.payload });
}

void IPCServer::handleMessage_BesiegedEvent(const IPP& ipp, const ipc::BesiegedEvent& message)
{
    TracyZoneScoped;

    worldServer_.besiegedSystem_->handleMessage(message.type, { ipp, message.payload });
}

void IPCServer::handleMessage_CampaignEvent(const IPP& ipp, const ipc::CampaignEvent& message)
{
    TracyZoneScoped;

    worldServer_.campaignSystem_->handleMessage(message.type, { ipp, message.payload });
}

void IPCServer::handleMessage_ColonizationEvent(const IPP& ipp, const ipc::ColonizationEvent& message)
{
    TracyZoneScoped;

    worldServer_.colonizationSystem_->handleMessage(message.type, { ipp, message.payload });
}

void IPCServer::handleMessage_EntityInformationRequest(const IPP& ipp, const ipc::EntityInformationRequest& message)
{
    TracyZoneScoped;

    // enum ENTITYTYPE : uint8
    // {
    //     TYPE_NONE   = 0x00,
    //     TYPE_PC     = 0x01,
    //     TYPE_NPC    = 0x02,
    //     TYPE_MOB    = 0x04,

    if (message.entityType == 0x01)
    {
        rerouteMessageToCharId(message.targetId, message);
    }
    else
    {
        const auto zoneId = (message.targetId >> 12) & 0x0FFF;
        rerouteMessageToZoneId(zoneId, message);
    }
}

void IPCServer::handleMessage_EntityInformationResponse(const IPP& ipp, const ipc::EntityInformationResponse& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.requesterId, message);
}

void IPCServer::handleMessage_SendPlayerToLocation(const IPP& ipp, const ipc::SendPlayerToLocation& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.targetId, message);
}

void IPCServer::handleMessage_AssistChannelEvent(const IPP& ipp, const ipc::AssistChannelEvent& message)
{
    TracyZoneScoped;

    rerouteMessageToCharId(message.receiverId, message);
}

void IPCServer::handleMessage_GMCallRequest(const IPP& ipp, const ipc::GMCallRequest& message)
{
    TracyZoneScoped;

    ShowInfoFmt("GM Call #{} from {} (charId: {}, accId: {}, zone: {}): {}",
                message.callId,
                message.charName,
                message.charId,
                message.accId,
                message.zoneId,
                message.message);

    // TODO: Route this to external clients
}

void IPCServer::handleMessage_GMCallResponse(const IPP& ipp, const ipc::GMCallResponse& message)
{
    TracyZoneScoped;

    // Client can only read up to 1024 characters, drop any extra characters now.
    auto truncatedMessage    = message;
    truncatedMessage.message = truncatedMessage.message.substr(0, 1024);

    db::preparedStmt("UPDATE help_desk "
                     "SET response = ?, responded_at = NOW() "
                     "WHERE id = ?",
                     truncatedMessage.message,
                     truncatedMessage.callId);

    if (const auto maybeCharIPP = getIPPForCharId(truncatedMessage.charId))
    {
        sendMessage(*maybeCharIPP, truncatedMessage);
    }
}

void IPCServer::handleUnknownMessage(const IPP& ipp, const std::span<uint8_t> message)
{
    TracyZoneScoped;

    ShowWarningFmt("Received unknown message from {} with code {} and size {}", ipp.toString(), message[0], message.size());
}
