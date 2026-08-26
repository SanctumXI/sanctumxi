#include "map/entities/battle_entity.h"
#include "map/spell.h"
#include "map/status_effect_container.h"
#include "map/utils/moduleutils.h"

#include <algorithm>

namespace
{
constexpr EFFECT forbiddenSeal = static_cast<EFFECT>(514);

bool canUseForbiddenSeal(CBattleEntity* PCaster, CSpell* PSpell)
{
    return PCaster && PSpell &&
           PCaster->objtype == TYPE_PC &&
           PCaster->health.hp > 0 &&
           PSpell->hasMPCost() &&
           PCaster->StatusEffectContainer->HasStatusEffect(forbiddenSeal);
}
} // namespace

class ForbiddenSealModule final : public CPPModule
{
    void OnInit() override
    {
    }

    auto OnSpellCostCheck(CBattleEntity* PCaster, CSpell* PSpell) -> bool override
    {
        return canUseForbiddenSeal(PCaster, PSpell);
    }

    auto OnSpellCostSpend(CBattleEntity* PCaster, CSpell* PSpell, int32 cost) -> bool override
    {
        if (cost <= 0 || !canUseForbiddenSeal(PCaster, PSpell))
        {
            return false;
        }

        PCaster->addHP(-std::min<int32>(cost, PCaster->health.hp - 1));
        PCaster->StatusEffectContainer->DelStatusEffect(forbiddenSeal);
        return true;
    }
};

REGISTER_CPP_MODULE(ForbiddenSealModule);
