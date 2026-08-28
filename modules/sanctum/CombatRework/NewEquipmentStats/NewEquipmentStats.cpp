#include "map/entities/battle_entity.h"
#include "map/entities/char_entity.h"
#include "map/spell.h"
#include "map/status_effect.h"
#include "map/utils/moduleutils.h"
#include "map/utils/zoneutils.h"

#include <algorithm>
#include <chrono>

namespace
{
using namespace std::chrono_literals;

constexpr int16 skillchainTpPerPoint = 10;

auto getPlayerStatOwner(CBattleEntity* POrigin) -> CCharEntity*
{
    if (!POrigin)
    {
        return nullptr;
    }

    if (auto* PChar = dynamic_cast<CCharEntity*>(POrigin))
    {
        return PChar;
    }

    return POrigin->PMaster && POrigin->PMaster->objtype == TYPE_PC ? static_cast<CCharEntity*>(POrigin->PMaster) : nullptr;
}

auto isPlayerAlly(CBattleEntity* PTarget) -> bool
{
    return PTarget &&
           (PTarget->objtype == TYPE_PC ||
            PTarget->objtype == TYPE_PET ||
            PTarget->objtype == TYPE_TRUST ||
            (PTarget->PMaster && PTarget->PMaster->objtype == TYPE_PC));
}

// Everything we can check without looking up the origin entity. This runs for
// every effect on the server, so keep it ahead of that lookup.
auto isEligibleBuff(CBattleEntity* PTarget, CStatusEffect* PStatusEffect) -> bool
{
    if (!PStatusEffect || !isPlayerAlly(PTarget) ||
        PStatusEffect->GetOriginID() == 0 ||
        PStatusEffect->GetDuration() <= 0s ||
        PStatusEffect->GetIcon() == 0)
    {
        return false;
    }

    const auto sourceType = PStatusEffect->GetSourceType();
    if (sourceType == SOURCE_EQUIPPED_ITEM || sourceType == SOURCE_TEMPORARY_ITEM || sourceType == SOURCE_FOOD)
    {
        return false;
    }

    constexpr uint32 excludedFlags =
        EFFECTFLAG_ERASABLE |
        EFFECTFLAG_WALTZABLE |
        EFFECTFLAG_PREVENT_ACTION |
        EFFECTFLAG_FOOD |
        EFFECTFLAG_SYNTH_SUPPORT |
        EFFECTFLAG_CONFRONTATION |
        EFFECTFLAG_INFLUENCE |
        EFFECTFLAG_AURA |
        EFFECTFLAG_ALWAYS_EXPIRING;

    if (PStatusEffect->GetEffectFlags() & excludedFlags)
    {
        return false;
    }

    // Bad effects you put on yourself or your own pet that the flags above miss.
    // Add to this list, don't assume the flags cover a new one.
    switch (PStatusEffect->GetStatusID())
    {
        case EFFECT_KO:
        case EFFECT_WEAKNESS:
        case EFFECT_BUST:
        case EFFECT_SKILLCHAIN:
        case EFFECT_OVERLOAD: // Applied to the player's own automaton, origin is the player or the pet.
            return false;
        default:
            return true;
    }
}

void reduceRecast(CBattleEntity* PEntity, timer::duration& recast, timer::duration* PChargeTime = nullptr)
{
    if (!PEntity || PEntity->objtype != TYPE_PC || recast <= 0s)
    {
        return;
    }

    const auto reduction = std::chrono::seconds(std::max<int16>(0, PEntity->getMod(Mod::RECAST_RATE)));
    if (reduction <= 0s)
    {
        return;
    }

    if (PChargeTime && *PChargeTime > 0s)
    {
        const auto chargeCount = std::max<int64>(1, (recast.count() + PChargeTime->count() - 1) / PChargeTime->count());
        *PChargeTime           = std::max<timer::duration>(1s, *PChargeTime - reduction);
        recast                 = *PChargeTime * chargeCount;
        return;
    }

    recast = std::max<timer::duration>(0s, recast - reduction);
}
} // namespace

class NewEquipmentStatsModule final : public CPPModule
{
    void OnInit() override
    {
    }

    void OnMagicBurst(CBattleEntity* PCaster, CSpell* PSpell) override
    {
        if (!PCaster || !PSpell || PCaster->objtype != TYPE_PC)
        {
            return;
        }

        const auto percent = std::max<int16>(0, PCaster->getMod(Mod::MAGIC_BURST_MP));
        const auto restore = static_cast<int32>(PSpell->getMPCost()) * percent / 100;
        if (restore > 0)
        {
            PCaster->addMP(restore);
        }
    }

    void OnSkillchain(CBattleEntity* PAttacker) override
    {
        if (!PAttacker || PAttacker->objtype != TYPE_PC)
        {
            return;
        }

        const auto points = std::max<int16>(0, PAttacker->getMod(Mod::SKILLCHAIN_TP));
        if (points > 0)
        {
            PAttacker->addTP(points * skillchainTpPerPoint);
        }
    }

    void OnStatusEffectDuration(CBattleEntity* PTarget, CStatusEffect* PStatusEffect) override
    {
        if (!isEligibleBuff(PTarget, PStatusEffect))
        {
            return;
        }

        auto* POrigin = dynamic_cast<CBattleEntity*>(zoneutils::GetEntity(PStatusEffect->GetOriginID()));
        auto* POwner  = getPlayerStatOwner(POrigin);
        if (!POwner || PTarget->allegiance != POrigin->allegiance)
        {
            return;
        }

        const auto bonusSeconds = std::max<int16>(0, POwner->getMod(Mod::BUFF_DURATION));
        if (bonusSeconds > 0)
        {
            PStatusEffect->SetDuration(PStatusEffect->GetDuration() + std::chrono::seconds(bonusSeconds));
        }
    }

    void OnSpellRecast(CBattleEntity* PCaster, timer::duration& recast) override
    {
        reduceRecast(PCaster, recast);
    }

    void OnAbilityRecast(CBattleEntity* PUser, timer::duration& recast, timer::duration& chargeTime) override
    {
        reduceRecast(PUser, recast, &chargeTime);
    }
};

REGISTER_CPP_MODULE(NewEquipmentStatsModule);
