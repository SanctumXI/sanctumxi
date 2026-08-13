#include "map/conquest_system.h"
#include "map/entities/char_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/moduleutils.h"

namespace
{

constexpr int16       NonOwnerBonus = 5;
constexpr const char* BonusMarker   = "[Steel]ConquestBonus";

void clearBonus(CCharEntity* PChar)
{
    if (PChar->GetLocalVar(BonusMarker) == NonOwnerBonus)
    {
        PChar->delModifier(Mod::CONQUEST_BONUS, NonOwnerBonus);
        PChar->SetLocalVar(BonusMarker, 0);
    }
}

void refreshBonus(CCharEntity* PChar)
{
    clearBonus(PChar);

    const auto region = PChar->loc.zone->GetRegionID();
    if (region >= REGION_TYPE::RONFAURE &&
        region <= REGION_TYPE::TAVNAZIA &&
        PChar->profile.nation != conquest::GetRegionOwner(region))
    {
        PChar->addModifier(Mod::CONQUEST_BONUS, NonOwnerBonus);
        PChar->SetLocalVar(BonusMarker, NonOwnerBonus);
    }
}

} // namespace

class ConquestChangesModule final : public CPPModule
{
    void OnInit() override
    {
        auto xiTable = lua["xi"].get_or_create<sol::table>();
        auto table   = xiTable["steelConquest"].get_or_create<sol::table>();
        table.set_function("refresh", [](CLuaBaseEntity* entity)
        {
            if (!entity)
            {
                return;
            }

            if (auto* PChar = dynamic_cast<CCharEntity*>(entity->GetBaseEntity()))
            {
                refreshBonus(PChar);
            }
        });
    }

    void OnCharZoneIn(CCharEntity* PChar) override
    {
        refreshBonus(PChar);
    }

    void OnCharZoneOut(CCharEntity* PChar) override
    {
        clearBonus(PChar);
    }
};

REGISTER_CPP_MODULE(ConquestChangesModule);
