/*
===========================================================================

  Copyright (c) 2024 LandSandBoat Dev Teams

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

#pragma once

#include "cbasetypes.h"

#include "common/regional_event.h"

#include "map/enums/chat_message_type.h"
#include "map/enums/msg_std.h"
#include "map/enums/party_kind.h"

#include <map>
#include <string>
#include <vector>

namespace ipc
{

struct EmptyStruct
{
};

struct AccountLogin
{
    uint32 accountId{};
};

struct CharZone
{
    uint32 charId{};
    uint16 destinationZoneId{};

    // Snapshot the social groups before the old map destroys its character
    // object. World uses these only while the character is zoning, when the
    // live session rows and destination-map objects may be temporarily empty.
    uint32 partyId{};
    uint32 allianceId{};
    uint32 linkshellId1{};
    uint32 linkshellId2{};
};

// Sent by a map process after the client confirms that it has entered its new
// zone. World uses this to release chat held during the map-server handoff.
struct ChatZoneReady
{
    uint32 charId{};
};

struct CharVarUpdate
{
    uint32      charId{};
    int32       value{};
    uint32      expiry{};
    std::string varName{};
};

struct ChatMessageTell
{
    uint32      senderId{};
    std::string senderName{};
    std::string recipientName{};
    std::string message{};
    uint16      zoneId{};
    uint8       gmLevel{};
};

// Returned to world when a routed tell reaches a map process during the
// recipient's handoff window and cannot be delivered there.
struct ChatMessageTellRetry
{
    ChatMessageTell tell{};
};

struct ChatMessageParty
{
    uint32            partyId{};
    uint32            senderId{};
    std::string       senderName{};
    std::string       message{};
    uint16            zoneId{};
    uint8             gmLevel{};
    CHAT_MESSAGE_TYPE messageType{ MESSAGE_PARTY };
};

struct ChatMessageAlliance
{
    uint32            allianceId{};
    uint32            senderId{};
    std::string       senderName{};
    std::string       message{};
    uint16            zoneId{};
    uint8             gmLevel{};
    CHAT_MESSAGE_TYPE messageType{ MESSAGE_PARTY };
};

struct ChatMessageLinkshell
{
    uint32      linkshellId{};
    uint32      senderId{};
    std::string senderName{};
    std::string message{};
    uint16      zoneId{};
    uint8       gmLevel{};
};

enum class ChatMessageTargetType : uint8
{
    Party,
    Alliance,
    Linkshell,
};

// Delivers group chat to an explicit set of characters on one map process.
// Explicit recipients let world omit zoning members from the live fan-out and
// later replay exactly one buffered copy to each of them.
struct ChatMessageTargeted
{
    std::vector<uint32>   recipientIds{};
    uint32                groupId{};
    uint32                senderId{};
    std::string           senderName{};
    std::string           message{};
    uint16                zoneId{};
    uint8                 gmLevel{};
    CHAT_MESSAGE_TYPE     messageType{ MESSAGE_PARTY };
    ChatMessageTargetType targetType{ ChatMessageTargetType::Party };
    uint8                 retryCount{};
};

// Returned to world when an explicitly targeted recipient starts zoning after
// world selected their map route but before that map can deliver the message.
struct ChatMessageTargetedRetry
{
    ChatMessageTargeted message{};
};

struct ChatMessageUnity
{
    uint32            unityLeaderId{};
    uint32            senderId{};
    std::string       senderName{};
    std::string       message{};
    uint16            zoneId{};
    uint8             gmLevel{};
    CHAT_MESSAGE_TYPE messageType{ MESSAGE_UNITY };
};

struct ChatMessageYell
{
    uint32            senderId{};
    std::string       senderName{};
    std::string       message{};
    uint16            zoneId{};
    uint8             gmLevel{};
    CHAT_MESSAGE_TYPE messageType{ MESSAGE_YELL };
};

struct ChatMessageAssist
{
    uint32            senderId{};
    std::string       senderName{};
    std::string       message{};
    uint8             mentorRank{ 0 };
    uint8             masteryRank{ 1 };
    uint8             gmLevel{};
    CHAT_MESSAGE_TYPE messageType{ MESSAGE_NA_ASSIST };
};

// NOTE: Remember some external tools like announce.py rely on this struct layout.
// If you change it, please update the tools too.
struct ChatMessageServerMessage
{
    uint32            senderId{};
    std::string       senderName{};
    std::string       message{};
    uint16            zoneId{};
    uint8             gmLevel{};
    CHAT_MESSAGE_TYPE messageType{ MESSAGE_SYSTEM_1 };
    bool              skipSender{};
};

struct ChatMessageCustom
{
    uint32            recipientId{};
    std::string       senderName{};
    std::string       message{};
    CHAT_MESSAGE_TYPE messageType{};
};

struct PartyInvite
{
    uint32      inviteeId{};
    uint16      inviteeTargId{};
    uint32      inviterId{};
    uint16      inviterTargId{};
    std::string inviterName{};
    PartyKind   inviteType{};
};

struct PartyInviteResponse
{
    uint32 inviteeId{};
    uint16 inviteeTargId{};
    uint32 inviterId{};
    uint16 inviterTargId{};
    uint8  inviteAnswer{};
};

struct PartyReload
{
    uint32 partyId{};
};

struct PartyDisband
{
    uint32 partyId{};
};

struct AllianceReload
{
    uint32 allianceId{};
};

struct AllianceDissolve
{
    uint32 allianceId{};
};

struct PlayerKick
{
    uint32 victimId{};
};

struct MessageStandard
{
    uint32      recipientId{};
    MsgStd      message{};
    uint32      param0{};
    uint32      param1{};
    std::string string2{};
};

struct MessageSystem
{
    uint32 recipientId{};
    MsgStd message{};
    uint32 param0{};
    uint32 param1{};
};

struct LinkshellRankChange
{
    uint32      requesterId{};
    uint8       requesterRank{};
    std::string memberName{};
    uint32      linkshellId{};
    uint8       newRank{};
};

struct LinkshellRemove
{
    uint32      requesterId{};
    uint8       requesterRank{};
    std::string victimName{};
    uint32      linkshellId{};
};

struct LinkshellSetMessage
{
    uint32      linkshellId{};
    std::string linkshellName{};
    std::string poster{};
    std::string message{};
    uint32      postTime{};
};

struct LuaFunction
{
    uint16      requesterZoneId{};
    uint16      executorZoneId{};
    std::string funcString{};
};

struct KillSession
{
    uint32 victimId{};
};

struct ConquestEvent
{
    ConquestMessage    type{};
    std::vector<uint8> payload{};
};

struct BesiegedEvent
{
    BesiegedMessage    type{};
    std::vector<uint8> payload{};
};

struct CampaignEvent
{
    CampaignMessage    type{};
    std::vector<uint8> payload{};
};

struct ColonizationEvent
{
    ColonizationMessage type{};
    std::vector<uint8>  payload{};
};

struct EntityInformationRequest
{
    uint32 requesterId{};
    uint32 targetId{};
    uint8  entityType{};
    bool   warp{};
    bool   spawnedOnly{};
};

struct EntityInformationResponse
{
    uint32 requesterId{};
    uint32 targetId{};
    uint8  entityType{};
    bool   warp{};

    uint16 zoneId{};
    float  x{};
    float  y{};
    float  z{};
    uint8  rot{};
    uint32 moghouseId{};
};

struct SendPlayerToLocation
{
    uint32 targetId{};
    uint16 zoneId{};
    float  x{};
    float  y{};
    float  z{};
    uint8  rot{};
    uint32 moghouseId{};
};

struct AssistChannelEvent
{
    uint32 senderId{};
    uint32 receiverId{};
    uint8  action{}; // GP_CLI_COMMAND_ASSIST_CHANNEL_KIND
};

struct GMCallRequest
{
    uint32                             callId{};
    uint32                             charId{};
    std::string                        charName{};
    uint32                             accId{};
    uint16                             zoneId{};
    float                              posX{};
    float                              posY{};
    float                              posZ{};
    std::string                        message{};
    std::map<std::string, std::string> parameters{};
};

struct GMCallResponse
{
    uint32      callId{};
    uint32      charId{};
    std::string message{}; // Up to 1024 characters
};

} // namespace ipc
