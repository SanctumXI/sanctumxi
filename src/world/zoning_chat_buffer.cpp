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

#include "zoning_chat_buffer.h"

#include <utility>

void ZoningChatBuffer::beginTransition(const uint32 charId, const timer::time_point now)
{
    auto& transition     = transitions_[charId];
    transition.expiresAt = now + kTransitionTimeout;
}

void ZoningChatBuffer::beginTransition(const uint32 charId, const MembershipSnapshot membership, const timer::time_point now)
{
    auto& transition      = transitions_[charId];
    transition.expiresAt  = now + kTransitionTimeout;
    transition.membership = membership;
}

auto ZoningChatBuffer::isTransitioning(const uint32 charId) const -> bool
{
    return transitions_.contains(charId);
}

auto ZoningChatBuffer::getTransitioningRecipients(const ipc::ChatMessageTargetType targetType, const uint32 groupId) const -> std::vector<uint32>
{
    auto recipients = std::vector<uint32>{};
    if (groupId == 0)
    {
        return recipients;
    }

    for (const auto& [charId, transition] : transitions_)
    {
        bool isMember = false;
        switch (targetType)
        {
            case ipc::ChatMessageTargetType::Party:
                isMember = transition.membership.partyId == groupId;
                break;
            case ipc::ChatMessageTargetType::Alliance:
                isMember = transition.membership.allianceId == groupId;
                break;
            case ipc::ChatMessageTargetType::Linkshell:
                isMember = transition.membership.linkshellId1 == groupId || transition.membership.linkshellId2 == groupId;
                break;
        }

        if (isMember)
        {
            recipients.emplace_back(charId);
        }
    }

    return recipients;
}

auto ZoningChatBuffer::enqueueTell(const uint32 charId, const ipc::ChatMessageTell& message, const timer::time_point now) -> bool
{
    return enqueue(charId, message, now);
}

auto ZoningChatBuffer::enqueueTargeted(const uint32 charId, const ipc::ChatMessageTargeted& message, const timer::time_point now) -> bool
{
    return enqueue(charId, message, now);
}

auto ZoningChatBuffer::enqueue(const uint32 charId, BufferedMessage message, const timer::time_point now) -> bool
{
    if (!isTransitioning(charId))
    {
        beginTransition(charId, now);
    }

    auto& transition = transitions_.at(charId);
    if (transition.messages.size() >= kMaxMessagesPerChar)
    {
        return false;
    }

    transition.messages.emplace_back(std::move(message));
    return true;
}

auto ZoningChatBuffer::completeTransition(const uint32 charId) -> std::vector<BufferedMessage>
{
    const auto transition = transitions_.find(charId);
    if (transition == transitions_.end())
    {
        return {};
    }

    auto messages = std::vector<BufferedMessage>{};
    messages.reserve(transition->second.messages.size());
    while (!transition->second.messages.empty())
    {
        messages.emplace_back(std::move(transition->second.messages.front()));
        transition->second.messages.pop_front();
    }

    transitions_.erase(transition);
    return messages;
}

auto ZoningChatBuffer::expireTransitions(const timer::time_point now) -> std::vector<ExpiredTransition>
{
    auto expired = std::vector<ExpiredTransition>{};

    for (auto transition = transitions_.begin(); transition != transitions_.end();)
    {
        if (transition->second.expiresAt > now)
        {
            ++transition;
            continue;
        }

        auto batch   = ExpiredTransition{};
        batch.charId = transition->first;
        batch.messages.reserve(transition->second.messages.size());
        while (!transition->second.messages.empty())
        {
            batch.messages.emplace_back(std::move(transition->second.messages.front()));
            transition->second.messages.pop_front();
        }

        expired.emplace_back(std::move(batch));
        transition = transitions_.erase(transition);
    }

    return expired;
}
