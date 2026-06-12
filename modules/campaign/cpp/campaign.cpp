/************************************************************************
* Campaign
*************************************************************************
* Lua util functions for Campaign
************************************************************************/
#include <tuple>

#include "map/utils/moduleutils.h"
#include "common/sql.h"
#include "campaign_system.h"
#include "campaign_handler.h"
#include "map.h"
#include "map/utils/zoneutils.h"
#include "packets/campaign_map.h"
#include "utils/charutils.h"

class CampaignModule : public CPPModule
{
    std::map<uint8, std::string> control_map;

    void OnInit() override
    {
        control_map[2] = "influence_sandoria";
        control_map[4] = "influence_bastok";
        control_map[6] = "influence_windurst";
        control_map[8] = "influence_beastman";

        TracyZoneScoped;

        lua["CampaignGetControl"] = [this](uint16 zoneID) -> uint8
        {
            TracyZoneScoped;

            if (sql->Query("SELECT nation FROM `campaign_map` WHERE zoneid = %u;", zoneID) != SQL_ERROR && sql->NumRows() > 0 && sql->NextRow() != SQL_ERROR)
            {
                return sql->GetUIntData(0);
            }

            return 8; // Beastman
        };
        // Battle Status 
        lua["GetBattle_Status"] = [this](uint16 zoneid) -> uint8 //done
        {
            TracyZoneScoped;

            if (sql->Query("SELECT isbattle FROM `campaign_map` WHERE zoneid = %u;", zoneid) != SQL_ERROR && sql->NumRows() > 0 && sql->NextRow() != SQL_ERROR)
            {
                return sql->GetUIntData(0);
            }

            return 0; //isbattle
        };

        lua["SetBattleStatus"] = [this](uint16 amount, uint16 zoneID) -> void //done
        {
            TracyZoneScoped;
            sql->Query("UPDATE campaign_map SET isbattle = %u WHERE zoneid = %u", amount, zoneID);      
        };
        // Campaign Influence 
        lua["GetInfluence_Sandoria"] = [this](uint16 zoneid) -> uint8 //done
        {
            TracyZoneScoped;

            if (sql->Query("SELECT influence_sandoria FROM `campaign_map` WHERE zoneid = %u;", zoneid) != SQL_ERROR && sql->NumRows() > 0 && sql->NextRow() != SQL_ERROR)
            {
                return sql->GetUIntData(0);
            }

            return 0;
        };

        lua["SetInfluence_Sandoria"] = [this](uint16 amount, uint16 zoneID) -> void //done
        {
            TracyZoneScoped;
            sql->Query("UPDATE campaign_map SET influence_sandoria = %u WHERE zoneid = %u", amount, zoneID);      
        };

		lua["GetInfluence_Bastok"] = [this](uint16 zoneid) -> uint8 //done
        {
            TracyZoneScoped;

            if (sql->Query("SELECT influence_bastok FROM `campaign_map` WHERE zoneid = %u;", zoneid) != SQL_ERROR && sql->NumRows() > 0 && sql->NextRow() != SQL_ERROR)
            {
                return sql->GetUIntData(0);
            }

            return 0; 
        };

        lua["SetInfluence_Bastok"] = [this](uint16 amount, uint16 zoneID) -> void 
        {
            TracyZoneScoped;
            sql->Query("UPDATE campaign_map SET influence_bastok = %u WHERE zoneid = %u", amount, zoneID);      
        };

		lua["GetInfluence_Windurst"] = [this](uint16 zoneid) -> uint8 //done
        {
            TracyZoneScoped;

            if (sql->Query("SELECT influence_windurst FROM `campaign_map` WHERE zoneid = %u;", zoneid) != SQL_ERROR && sql->NumRows() > 0 && sql->NextRow() != SQL_ERROR)
            {
                return sql->GetUIntData(0);
            }

            return 0; 
        };

        lua["SetInfluence_Windurst"] = [this](uint16 amount, uint16 zoneID) -> void 
        {
            TracyZoneScoped;
            sql->Query("UPDATE campaign_map SET influence_windurst = %u WHERE zoneid = %u", amount, zoneID);      
        };

		lua["GetInfluence_Beastman"] = [this](uint16 zoneid) -> uint8 //done
        {
            TracyZoneScoped;

            if (sql->Query("SELECT influence_beastman FROM `campaign_map` WHERE zoneid = %u;", zoneid) != SQL_ERROR && sql->NumRows() > 0 && sql->NextRow() != SQL_ERROR)
            {
                return sql->GetUIntData(0);
            }

            return 0; 
        };
        lua["SetInfluence_Beastman"] = [this](uint16 amount, uint16 zoneID) -> void 
        {
            TracyZoneScoped;
            sql->Query("UPDATE campaign_map SET influence_beastman = %u WHERE zoneid = %u", amount, zoneID);      
        };

        lua["CampaignAddInfluence"] = [this](uint16 zoneID, uint8 faction, uint16 amount) -> void
        {
            TracyZoneScoped;
            sql->Query("UPDATE campaign_map SET %s = %s + $u WHERE zoneid = %u", control_map[faction], control_map[faction], amount, zoneID);

        };

        lua["CampaignUpdateControl"] = [this](uint16 zoneID) -> void
        {
            TracyZoneScoped;

            const char* updateCampaign =
                "UPDATE campaign_map SET nation = (\
                SELECT CASE GREATEST(influence_sandoria, influence_bastok, influence_windurst, influence_beastman) \
                WHEN influence_sandoria THEN 2   \
                WHEN influence_bastok   THEN 4   \
                WHEN influence_windurst THEN 6   \
                WHEN influence_beastman THEN 8)) \
                WHERE zoneid = %u";

            sql->Query(updateCampaign, zoneID);
        };
    }
};

REGISTER_CPP_MODULE(CampaignModule);
