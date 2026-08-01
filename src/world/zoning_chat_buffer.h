/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

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

#include "common/ipc_structs.h"
#include "common/timer.h"

#include <chrono>
#include <cstddef>
#include <deque>
#include <unordered_map>
#include <variant>
#include <vector>

class ZoningChatBuffer
{
public:
    using BufferedMessage = std::variant<ipc::ChatMessageTell, ipc::ChatMessageTargeted>;

    struct MembershipSnapshot
    {
        uint32 partyId{};
        uint32 allianceId{};
        uint32 linkshellId1{};
        uint32 linkshellId2{};
    };

    struct ExpiredTransition
    {
        uint32                       charId{};
        std::vector<BufferedMessage> messages{};
    };

    static constexpr auto   kTransitionTimeout  = std::chrono::minutes(2);
    static constexpr size_t kMaxMessagesPerChar = 250;

    void beginTransition(uint32 charId, timer::time_point now = timer::now());
    void beginTransition(uint32 charId, MembershipSnapshot membership, timer::time_point now = timer::now());
    auto isTransitioning(uint32 charId) const -> bool;
    auto getTransitioningRecipients(ipc::ChatMessageTargetType targetType, uint32 groupId) const -> std::vector<uint32>;

    // Creates a transition lazily when the persistent zoning flag reveals a
    // handoff before the corresponding CharZone IPC message reaches world.
    auto enqueueTell(uint32 charId, const ipc::ChatMessageTell& message, timer::time_point now = timer::now()) -> bool;
    auto enqueueTargeted(uint32 charId, const ipc::ChatMessageTargeted& message, timer::time_point now = timer::now()) -> bool;

    auto completeTransition(uint32 charId) -> std::vector<BufferedMessage>;
    auto expireTransitions(timer::time_point now = timer::now()) -> std::vector<ExpiredTransition>;

private:
    auto enqueue(uint32 charId, BufferedMessage message, timer::time_point now) -> bool;

    struct Transition
    {
        timer::time_point           expiresAt{};
        MembershipSnapshot          membership{};
        std::deque<BufferedMessage> messages{};
    };

    std::unordered_map<uint32, Transition> transitions_{};
};
