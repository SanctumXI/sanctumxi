#include "common/timer.h"
#include "map/alliance.h"
#include "map/entities/char_entity.h"
#include "map/packets/basic.h"
#include "map/party.h"
#include "map/status_effect.h"
#include "map/status_effect_container.h"
#include "map/utils/moduleutils.h"
#include "map/zone.h"

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <limits>
#include <tuple>
#include <unordered_map>
#include <vector>

namespace
{
using namespace std::chrono_literals;

constexpr uint16 kHandshakePacketId = 0x076;
constexpr uint16 kSyncPacketId      = 0x063;
constexpr uint32 kProtocolMagic     = 0x52544353; // "SCTR"
constexpr uint8  kProtocolVersion   = 1;
constexpr uint32 kNoTimer           = 0xFFFFFFFF;
constexpr uint8  kAllianceFlag      = 0x01;
constexpr uint8  kHiddenTimerFlag   = 0x01;
constexpr size_t kPacketHeaderSize  = 20;
constexpr size_t kRecordSize        = 20;
constexpr size_t kRecordsPerPacket  = 24;
constexpr auto   kPollInterval      = 1s;
constexpr auto   kHeartbeatInterval = 15s;
constexpr auto   kSubscriptionTtl   = 120s;
constexpr auto   kCacheTtl          = 5min;

// Scouter opts in by placing the magic/version at offsets 0x05/0x09 of an
// otherwise valid 0x076 request. Responses use a reserved 0x063 subtype that
// the addon consumes before the retail client, with 20-byte records starting
// at 0x14. A zero status ID is a member sentinel for empty status lists.

struct StatusRecord
{
    uint32 memberId{};
    uint16 statusId{};
    uint16 iconId{};
    uint32 remainingMs{ kNoTimer };
    uint32 subId{};
    uint16 tier{};
    uint8  partySlot{};
    uint8  flags{};
    uint64 expiryKey{ std::numeric_limits<uint64>::max() };
};

struct GroupKey
{
    uintptr_t pointer{};
    uint16    zoneId{};
    bool      alliance{};

    bool operator==(const GroupKey&) const = default;
};

struct GroupKeyHash
{
    size_t operator()(const GroupKey& key) const
    {
        auto value = static_cast<uint64>(key.pointer);
        value ^= static_cast<uint64>(key.zoneId) << 32;
        value ^= key.alliance ? 0x9E3779B97F4A7C15ULL : 0;
        return std::hash<uint64>{}(value);
    }
};

struct GroupState
{
    uint64            hash{};
    bool              initialized{};
    timer::time_point lastBroadcast{};
    timer::time_point lastTouched{};
};

struct Subscription
{
    timer::time_point lastHandshake{};
};

struct GroupBatch
{
    CCharEntity*              representative{};
    std::vector<CCharEntity*> viewers{};
};

GroupKey getGroupKey(CCharEntity* PChar)
{
    if (PChar->PParty && PChar->PParty->m_PAlliance)
    {
        return {
            reinterpret_cast<uintptr_t>(PChar->PParty->m_PAlliance),
            static_cast<uint16>(PChar->getZone()),
            true,
        };
    }

    const auto pointer = PChar->PParty
                             ? reinterpret_cast<uintptr_t>(PChar->PParty)
                             : static_cast<uintptr_t>(PChar->id);
    return { pointer, static_cast<uint16>(PChar->getZone()), false };
}

uint8 getViewerPartySlot(CCharEntity* PChar)
{
    if (!PChar->PParty || !PChar->PParty->m_PAlliance)
    {
        return 0;
    }

    const auto& parties = PChar->PParty->m_PAlliance->partyList;
    for (size_t index = 0; index < parties.size(); ++index)
    {
        if (parties[index] == PChar->PParty)
        {
            return static_cast<uint8>(index);
        }
    }
    return 0;
}

void addMemberEffects(std::vector<StatusRecord>& records, CCharEntity* PMember, const uint8 partySlot, const timer::time_point now)
{
    records.emplace_back(StatusRecord{
        .memberId  = PMember->id,
        .partySlot = partySlot,
    });

    uint8 visibleCount = 0;
    PMember->StatusEffectContainer->ForEachEffect(
        [&](CStatusEffect* PEffect)
        {
            if (!PEffect || PEffect->deleted || PEffect->GetIcon() == 0 || visibleCount >= 32)
            {
                return;
            }

            StatusRecord record{
                .memberId  = PMember->id,
                .statusId  = static_cast<uint16>(PEffect->GetStatusID()),
                .iconId    = PEffect->GetIcon(),
                .subId     = PEffect->GetSubID(),
                .tier      = PEffect->GetTier(),
                .partySlot = partySlot,
                .flags     = static_cast<uint8>(PEffect->HasEffectFlag(EFFECTFLAG_HIDE_TIMER) ? kHiddenTimerFlag : 0),
            };

            const auto duration = PEffect->GetDuration();
            if (duration > timer::duration::zero() && (record.flags & kHiddenTimerFlag) == 0)
            {
                const auto expiresAt = PEffect->GetStartTime() + duration;
                const auto remaining = expiresAt - now;
                if (remaining <= timer::duration::zero())
                {
                    return;
                }

                const auto milliseconds = timer::count_milliseconds(remaining);
                record.remainingMs      = static_cast<uint32>(std::min<int64>(
                    milliseconds,
                    static_cast<int64>(kNoTimer - 1)));
                record.expiryKey        = static_cast<uint64>(timer::count_milliseconds(expiresAt.time_since_epoch()));
            }

            records.emplace_back(record);
            ++visibleCount;
        });
}

std::vector<StatusRecord> buildSnapshot(CCharEntity* PViewer, const timer::time_point now)
{
    std::vector<StatusRecord> records;
    auto                      addParty = [&](CParty* PParty, const uint8 partySlot)
    {
        if (!PParty)
        {
            return;
        }

        for (auto* PMemberEntity : PParty->members)
        {
            if (!PMemberEntity || PMemberEntity->objtype != TYPE_PC)
            {
                continue;
            }

            auto* PMember = static_cast<CCharEntity*>(PMemberEntity);
            if (PMember->getZone() == PViewer->getZone() && PMember->status != STATUS_TYPE::DISAPPEAR)
            {
                addMemberEffects(records, PMember, partySlot, now);
            }
        }
    };

    if (PViewer->PParty && PViewer->PParty->m_PAlliance)
    {
        const auto& parties = PViewer->PParty->m_PAlliance->partyList;
        for (size_t index = 0; index < parties.size(); ++index)
        {
            addParty(parties[index], static_cast<uint8>(index));
        }
    }
    else if (PViewer->PParty)
    {
        addParty(PViewer->PParty, 0);
    }
    else
    {
        addMemberEffects(records, PViewer, 0, now);
    }

    std::ranges::sort(
        records,
        [](const StatusRecord& left, const StatusRecord& right)
        {
            return std::tie(left.partySlot, left.memberId, left.statusId, left.iconId, left.subId, left.tier, left.expiryKey) < std::tie(right.partySlot, right.memberId, right.statusId, right.iconId, right.subId, right.tier, right.expiryKey);
        });
    return records;
}

uint64 snapshotHash(const std::vector<StatusRecord>& records)
{
    uint64 hash = 1469598103934665603ULL;
    auto   mix  = [&](const auto value)
    {
        const auto* bytes = reinterpret_cast<const uint8*>(&value);
        for (size_t index = 0; index < sizeof(value); ++index)
        {
            hash ^= bytes[index];
            hash *= 1099511628211ULL;
        }
    };

    for (const auto& record : records)
    {
        mix(record.memberId);
        mix(record.statusId);
        mix(record.iconId);
        mix(record.subId);
        mix(record.tier);
        mix(record.partySlot);
        mix(record.flags);
        mix(record.expiryKey);
    }
    return hash;
}
} // namespace

class ScouterStatusSyncModule : public CPPModule
{
public:
    void OnInit() override
    {
        ShowInfo("Scouter status sync module loaded.\n");
    }

    auto OnIncomingPacket(MapSession*, CCharEntity* PChar, CBasicPacket& packet) -> bool override
    {
        if (!PChar || packet.getType() != kHandshakePacketId || packet.getSize() < 12)
        {
            return false;
        }

        if (packet.ref<uint8>(0x04) != 0 || packet.ref<uint32>(0x05) != kProtocolMagic)
        {
            return false;
        }

        if (packet.ref<uint8>(0x09) == kProtocolVersion)
        {
            const auto now            = timer::now();
            subscriptions_[PChar->id] = { now };
            sendSnapshot(PChar, buildSnapshot(PChar, now), nextSequence());
        }
        return true;
    }

    void OnCharZoneOut(CCharEntity* PChar) override
    {
        if (PChar)
        {
            subscriptions_.erase(PChar->id);
        }
    }

    void OnZoneTick(CZone* PZone) override
    {
        if (!PZone)
        {
            return;
        }

        const auto now    = timer::now();
        const auto zoneId = static_cast<uint16>(PZone->GetID());
        if (const auto it = nextZonePoll_.find(zoneId); it != nextZonePoll_.end() && now < it->second)
        {
            return;
        }
        nextZonePoll_[zoneId] = now + kPollInterval;

        std::unordered_map<GroupKey, GroupBatch, GroupKeyHash> batches;
        PZone->ForEachChar(
            [&](CCharEntity* PChar)
            {
                const auto subscription = subscriptions_.find(PChar->id);
                if (subscription == subscriptions_.end() || now - subscription->second.lastHandshake > kSubscriptionTtl)
                {
                    return;
                }

                const auto key       = getGroupKey(PChar);
                auto&      batch     = batches[key];
                batch.representative = batch.representative ? batch.representative : PChar;
                batch.viewers.emplace_back(PChar);
            });

        for (auto& [key, batch] : batches)
        {
            const auto records = buildSnapshot(batch.representative, now);
            const auto hash    = snapshotHash(records);
            auto&      state   = groupStates_[key];
            state.lastTouched  = now;

            const bool changed   = !state.initialized || state.hash != hash;
            const bool heartbeat = !state.initialized || now - state.lastBroadcast >= kHeartbeatInterval;
            if (!changed && !heartbeat)
            {
                continue;
            }

            state.hash          = hash;
            state.initialized   = true;
            state.lastBroadcast = now;
            const auto sequence = nextSequence();
            for (auto* PViewer : batch.viewers)
            {
                sendSnapshot(PViewer, records, sequence);
            }
        }

        cleanup(now);
    }

private:
    std::unordered_map<uint32, Subscription>               subscriptions_;
    std::unordered_map<uint16, timer::time_point>          nextZonePoll_;
    std::unordered_map<GroupKey, GroupState, GroupKeyHash> groupStates_;
    timer::time_point                                      nextCleanup_{};
    uint16                                                 sequence_{};

    uint16 nextSequence()
    {
        ++sequence_;
        return sequence_;
    }

    void cleanup(const timer::time_point now)
    {
        if (now < nextCleanup_)
        {
            return;
        }
        nextCleanup_ = now + 1min;

        std::erase_if(
            subscriptions_,
            [&](const auto& entry)
            {
                return now - entry.second.lastHandshake > kSubscriptionTtl;
            });
        std::erase_if(
            groupStates_,
            [&](const auto& entry)
            {
                return now - entry.second.lastTouched > kCacheTtl;
            });
    }

    void sendSnapshot(CCharEntity* PViewer, const std::vector<StatusRecord>& records, const uint16 sequence)
    {
        const size_t chunkCount      = std::max<size_t>(1, (records.size() + kRecordsPerPacket - 1) / kRecordsPerPacket);
        const uint8  flags           = PViewer->PParty && PViewer->PParty->m_PAlliance ? kAllianceFlag : 0;
        const uint16 viewerPartySlot = getViewerPartySlot(PViewer);

        for (size_t chunkIndex = 0; chunkIndex < chunkCount; ++chunkIndex)
        {
            const size_t first  = chunkIndex * kRecordsPerPacket;
            const size_t count  = std::min(kRecordsPerPacket, records.size() - first);
            auto         packet = std::make_unique<CBasicPacket>();
            packet->setType(kSyncPacketId);
            packet->setSize(kPacketHeaderSize + count * kRecordSize);
            packet->ref<uint32>(0x04) = kProtocolMagic;
            packet->ref<uint8>(0x08)  = kProtocolVersion;
            packet->ref<uint8>(0x09)  = flags;
            packet->ref<uint16>(0x0A) = sequence;
            packet->ref<uint16>(0x0C) = static_cast<uint16>(chunkIndex);
            packet->ref<uint16>(0x0E) = static_cast<uint16>(chunkCount);
            packet->ref<uint16>(0x10) = static_cast<uint16>(count);
            packet->ref<uint16>(0x12) = viewerPartySlot;

            for (size_t index = 0; index < count; ++index)
            {
                const auto&  record                = records[first + index];
                const size_t offset                = kPacketHeaderSize + index * kRecordSize;
                packet->ref<uint32>(offset + 0x00) = record.memberId;
                packet->ref<uint16>(offset + 0x04) = record.statusId;
                packet->ref<uint16>(offset + 0x06) = record.iconId;
                packet->ref<uint32>(offset + 0x08) = record.remainingMs;
                packet->ref<uint32>(offset + 0x0C) = record.subId;
                packet->ref<uint16>(offset + 0x10) = record.tier;
                packet->ref<uint8>(offset + 0x12)  = record.partySlot;
                packet->ref<uint8>(offset + 0x13)  = record.flags;
            }
            PViewer->pushPacket(std::move(packet));
        }
    }
};

REGISTER_CPP_MODULE(ScouterStatusSyncModule);
