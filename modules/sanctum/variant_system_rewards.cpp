#include "map/entities/char_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/charutils.h"
#include "map/utils/moduleutils.h"

class VariantSystemRewardsModule final : public CPPModule
{
    void OnInit() override
    {
        auto xiTable = lua["xi"].get_or_create<sol::table>();
        auto table   = xiTable["variantSystemRewards"].get_or_create<sol::table>();

        table.set_function("addExpSilent", [](CLuaBaseEntity* entity, uint32 exp)
        {
            if (entity == nullptr)
            {
                return false;
            }

            auto* player = dynamic_cast<CCharEntity*>(entity->GetBaseEntity());

            if (player == nullptr)
            {
                return false;
            }

            charutils::AddExperiencePoints(
                false,
                player,
                player,
                exp,
                EMobDifficulty::TooWeak,
                false,
                false);

            return true;
        });
    }
};

REGISTER_CPP_MODULE(VariantSystemRewardsModule);
