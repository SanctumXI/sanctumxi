/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

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

#include "common/logging.h"
#include "common/macros.h"
#include "common/settings.h"
#include "common/timer.h"
#include "common/utils.h"
#include "common/vana_time.h"

#include <algorithm>
#include <array>
#include <chrono>
#include <initializer_list>

#include "lua/luautils.h"

#include "ai/ai_container.h"
#include "ai/states/attack_state.h"
#include "ai/states/item_state.h"
#include "ai/states/range_state.h"

#include "packets/char_status.h"
#include "packets/char_sync.h"
#include "packets/s2c/0x009_message.h"
#include "packets/s2c/0x00b_logout.h"
#include "packets/s2c/0x01b_job_info.h"
#include "packets/s2c/0x01d_item_same.h"
#include "packets/s2c/0x01e_item_num.h"
#include "packets/s2c/0x01f_item_list.h"
#include "packets/s2c/0x020_item_attr.h"
#include "packets/s2c/0x026_item_subcontainer.h"
#include "packets/s2c/0x02d_battle_message2.h"
#include "packets/s2c/0x04f_equip_clear.h"
#include "packets/s2c/0x050_equip_list.h"
#include "packets/s2c/0x051_grap_list.h"
#include "packets/s2c/0x055_scenarioitem.h"
#include "packets/s2c/0x061_clistatus.h"
#include "packets/s2c/0x062_clistatus2.h"
#include "packets/s2c/0x0ac_command_data.h"
#include "packets/s2c/0x0e0_group_comlink.h"
#include "packets/s2c/0x119_abil_recast.h"

#include "ability.h"
#include "alliance.h"
#include "conquest_system.h"
#include "grades.h"
#include "ipc_client.h"
#include "item_container.h"
#include "items.h"
#include "latent_effect_container.h"
#include "linkshell.h"
#include "map_networking.h"
#include "mob_modifier.h"
#include "recast_container.h"
#include "roe.h"
#include "spell.h"
#include "status_effect_container.h"
#include "trade_container.h"
#include "trait.h"
#include "treasure_pool.h"
#include "unitychat.h"
#include "universal_container.h"
#include "weapon_skill.h"

#include "entities/automatonentity.h"
#include "entities/charentity.h"
#include "entities/mobentity.h"
#include "entities/petentity.h"

#include "battleutils.h"
#include "blueutils.h"
#include "charutils.h"
#include "enums/item_lockflg.h"
#include "itemutils.h"
#include "job_points.h"
#include "map_engine.h"
#include "petutils.h"
#include "puppetutils.h"
#include "synthutils.h"
#include "zoneutils.h"

#include "enums/key_items.h"
#include "enums/quest_log.h"
#include "items/item_furnishing.h"
#include "items/item_linkshell.h"
#include "packets/s2c/0x029_battle_message.h"
#include "packets/s2c/0x044_extended_job_blu.h"
#include "packets/s2c/0x044_extended_job_mon.h"
#include "packets/s2c/0x044_extended_job_pup.h"
#include "packets/s2c/0x056_mission.h"
#include "packets/s2c/0x056_mission_other.h"
#include "packets/s2c/0x056_mission_tvr.h"
#include "packets/s2c/0x05e_conquest.h"
#include "packets/s2c/0x063_miscdata_job_points.h"
#include "packets/s2c/0x063_miscdata_merits.h"
#include "packets/s2c/0x063_miscdata_monstrosity.h"
#include "packets/s2c/0x063_miscdata_unity.h"
#include "packets/s2c/0x075_battlefield.h"
#include "packets/s2c/0x0df_group_attr.h"
#include "packets/s2c/0x110_unity.h"
#include "packets/s2c/0x111_roe_activelog.h"
#include "packets/s2c/0x112_roe_log.h"

/************************************************************************
 *                                                                       *
 *  Experience tables                                                    *
 *                                                                       *
 ************************************************************************/

// Number of rows in the exp table
static constexpr int32                               ExpTableRowCount = 60;
std::array<std::array<uint16, 20>, ExpTableRowCount> g_ExpTable;
std::array<uint16, 100>                              g_ExpPerLevel;

std::vector<std::pair<uint16, EMobDifficulty>> ExpToDifficultyTable = {};
// Eventually loaded as something like...
/*
    //  { EXP value, check result }
    { 400, EMobDifficulty::IncrediblyTough },
    { 350, EMobDifficulty::VeryTough },
    { 220, EMobDifficulty::Tough },
    { 200, EMobDifficulty::EvenMatch },
    { 160, EMobDifficulty::DecentChallenge },
    { 60, EMobDifficulty::EasyPrey },
*/

std::pair<uint16, uint8> IncrediblyEasyPreyCheck = { 1, 56 };
// { EXP value, mob level }
// { 1, 56 }
// Must gain more than 1 exp but less than the lowest of ExpToDifficultyTable and greater than or equal to mob level

namespace
{

// Key items granting an increase to the rate of skillups
const std::set skillupIncreaseKeyItems = {
    KeyItem::RHAPSODY_IN_WHITE,
    KeyItem::RHAPSODY_IN_CRIMSON,
    KeyItem::RHAPSODY_IN_FUCHSIA
};

// Key items granting an increase to earned experience points
const std::set experienceBonusKeyItems = {
    KeyItem::RHAPSODY_IN_WHITE,
    KeyItem::RHAPSODY_IN_UMBER,
    KeyItem::RHAPSODY_IN_AZURE,
    KeyItem::RHAPSODY_IN_CRIMSON,
    KeyItem::RHAPSODY_IN_EMERALD,
    KeyItem::RHAPSODY_IN_MAUVE,
};

// Key items granting an increase to earned capacity points
const std::set capacityBonusKeyItems = {
    KeyItem::RHAPSODY_IN_FUCHSIA,
    KeyItem::RHAPSODY_IN_PUCE,
    KeyItem::RHAPSODY_IN_OCHRE,
};

// Key items reducing the time for traverser stones
const std::set traverserStoneReductionKeyItems = {
    KeyItem::AZURE_ABYSSITE_OF_CELERITY,
    KeyItem::CRIMSON_ABYSSITE_OF_CELERITY,
    KeyItem::IVORY_ABYSSITE_OF_CELERITY
};

constexpr double RacialSkillUpModifierLower   = 0.85;
constexpr double RacialSkillUpModifierNeutral = 0.95;
constexpr double RacialSkillUpModifierHigher  = 1.05;

auto getRacialSkillUpModifier(const CCharEntity* PChar, SKILLTYPE skillId) -> double
{
    const auto isSkill = [skillId](std::initializer_list<SKILLTYPE> skills)
    {
        return std::find(skills.begin(), skills.end(), skillId) != skills.end();
    };

    switch (static_cast<CharRace>(PChar->look.race))
    {
        case CharRace::HumeMale:
        case CharRace::HumeFemale:
            if (isSkill({ SKILL_SWORD, SKILL_GREAT_SWORD, SKILL_MARKSMANSHIP, SKILL_SHIELD, SKILL_ENHANCING_MAGIC, SKILL_ENFEEBLING_MAGIC, SKILL_BLUE_MAGIC }))
            {
                return RacialSkillUpModifierHigher;
            }
            if (isSkill({ SKILL_HAND_TO_HAND, SKILL_GREAT_KATANA, SKILL_ARCHERY, SKILL_GUARD, SKILL_SINGING, SKILL_NINJUTSU, SKILL_SUMMONING_MAGIC }))
            {
                return RacialSkillUpModifierLower;
            }
            break;
        case CharRace::ElvaanMale:
        case CharRace::ElvaanFemale:
            if (isSkill({ SKILL_SWORD, SKILL_GREAT_SWORD, SKILL_POLEARM, SKILL_PARRY, SKILL_SHIELD, SKILL_DIVINE_MAGIC, SKILL_HEALING_MAGIC }))
            {
                return RacialSkillUpModifierHigher;
            }
            if (isSkill({ SKILL_DAGGER, SKILL_KATANA, SKILL_MARKSMANSHIP, SKILL_THROWING, SKILL_EVASION, SKILL_ELEMENTAL_MAGIC, SKILL_DARK_MAGIC }))
            {
                return RacialSkillUpModifierLower;
            }
            break;
        case CharRace::TarutaruMale:
        case CharRace::TarutaruFemale:
            if (isSkill({ SKILL_STAFF, SKILL_ELEMENTAL_MAGIC, SKILL_DARK_MAGIC, SKILL_SINGING, SKILL_STRING_INSTRUMENT, SKILL_WIND_INSTRUMENT, SKILL_SUMMONING_MAGIC }))
            {
                return RacialSkillUpModifierHigher;
            }
            if (isSkill({ SKILL_GREAT_AXE, SKILL_SCYTHE, SKILL_POLEARM, SKILL_GREAT_KATANA, SKILL_ARCHERY, SKILL_GUARD, SKILL_SHIELD }))
            {
                return RacialSkillUpModifierLower;
            }
            break;
        case CharRace::Mithra:
            if (isSkill({ SKILL_DAGGER, SKILL_KATANA, SKILL_GREAT_KATANA, SKILL_ARCHERY, SKILL_THROWING, SKILL_EVASION, SKILL_NINJUTSU }))
            {
                return RacialSkillUpModifierHigher;
            }
            if (isSkill({ SKILL_GREAT_SWORD, SKILL_AXE, SKILL_SCYTHE, SKILL_CLUB, SKILL_DIVINE_MAGIC, SKILL_HEALING_MAGIC, SKILL_STRING_INSTRUMENT }))
            {
                return RacialSkillUpModifierLower;
            }
            break;
        case CharRace::Galka:
            if (isSkill({ SKILL_HAND_TO_HAND, SKILL_AXE, SKILL_GREAT_AXE, SKILL_SCYTHE, SKILL_CLUB, SKILL_GUARD, SKILL_SHIELD }))
            {
                return RacialSkillUpModifierHigher;
            }
            if (isSkill({ SKILL_SWORD, SKILL_STAFF, SKILL_PARRY, SKILL_ENHANCING_MAGIC, SKILL_ENFEEBLING_MAGIC, SKILL_WIND_INSTRUMENT, SKILL_BLUE_MAGIC }))
            {
                return RacialSkillUpModifierLower;
            }
            break;
        default:
            break;
    }

    return RacialSkillUpModifierNeutral;
}

} // namespace

namespace charutils
{

/************************************************************************
 *                                                                       *
 *  Calculation of stats of characters                                   *
 *                                                                       *
 ************************************************************************/

void CalculateStats(CCharEntity* PChar)
{
    float raceStat  = 0; // The final HP number for a race-based level.
    float jobStat   = 0; // Estimate HP level for the level based on the primary profession.
    float sJobStat  = 0; // HP final number for a level based on a secondary profession.
    int32 bonusStat = 0; // HP bonus number that is added subject to some conditions.

    int32 baseValueColumn   = 0; // Column number with base number HP
    int32 scaleTo60Column   = 1; // Column number with modifier up to 60 levels
    int32 scaleOver30Column = 2; // Column number with modifier after level 30
    int32 scaleOver60Column = 3; // Column number with modifier after level 60
    int32 scaleOver75Column = 4; // Column number with modifier after level 75
    int32 scaleOver60       = 2; // Column number with modifier for MP calculation after level 60
    int32 scaleOver75       = 3; // The speaker number with the modifier to calculate the stats after the 75th level

    uint8 grade = 0;

    uint8      mlvl        = PChar->GetMLevel();
    uint8      slvl        = PChar->GetSLevel();
    JOBTYPE    mjob        = PChar->GetMJob();
    JOBTYPE    sjob        = PChar->GetSJob();
    MERIT_TYPE statMerit[] = { MERIT_STR, MERIT_DEX, MERIT_VIT, MERIT_AGI, MERIT_INT, MERIT_MND, MERIT_CHR };

    // We have to make sure we don't leave the job as JOB_MON - we CANNOT generate stats for it.
    if (mjob == JOB_MON || sjob == JOB_MON)
    {
        mjob = JOB_WAR;
        sjob = JOB_WAR;
    }

    // NOTE: Monstrosity (MON) is treated as its own job, but each species is it's own
    //     : combination of main/sub job for stats, traits and abilities.
    if (PChar->m_PMonstrosity != nullptr)
    {
        mjob = PChar->m_PMonstrosity->MainJob;
        sjob = PChar->m_PMonstrosity->SubJob;
        mlvl = PChar->m_PMonstrosity->levels[PChar->m_PMonstrosity->MonstrosityId];
        slvl = mlvl;
    }

    uint8 race = 0; // Hume

    switch (static_cast<CharRace>(PChar->look.race))
    {
        case CharRace::HumeMale:
        case CharRace::HumeFemale:
            race = 0;
            break;
        case CharRace::ElvaanMale:
        case CharRace::ElvaanFemale:
            race = 1;
            break;
        case CharRace::TarutaruMale:
        case CharRace::TarutaruFemale:
            race = 2;
            break;
        case CharRace::Mithra:
            race = 3;
            break;
        case CharRace::Galka:
            race = 4;
            break;
        default:
            race = 0;
            break;
    }

    // HP Calculation from Main Job

    int32 mainLevelOver30     = std::clamp(mlvl - 30, 0, 30); // Calculation of the condition + 1HP each LVL after level 30
    int32 mainLevelUpTo60     = (mlvl < 60 ? mlvl - 1 : 59);  // The first time spent up to level 60 (is also used for MP)
    int32 mainLevelOver60To75 = std::clamp(mlvl - 60, 0, 15); // The second calculation mode after level 60
    int32 mainLevelOver75     = (mlvl < 75 ? 0 : mlvl - 75);  // Third Calculation Mode after level 75

    // Calculation of the bonus amount of HP

    int32 mainLevelOver10           = (mlvl < 10 ? 0 : mlvl - 10);  // + 2hp at each level after 10
    int32 mainLevelOver50andUnder60 = std::clamp(mlvl - 50, 0, 10); // + 2hp at each level between 50 to 60 level
    int32 mainLevelOver60           = (mlvl < 60 ? 0 : mlvl - 60);

    // HP calculation of an additional profession

    int32 subLevelOver10 = std::clamp(slvl - 10, 0, 20); // + 1HP for each level after 10 (/ 2)
    int32 subLevelOver30 = (slvl < 30 ? 0 : slvl - 30);  // + 1HP for each level after 30

    // Calculate Racestat Jobstat Bonusstat Sjobstat
    // Calculation of race

    grade = grade::GetRaceGrades(race, 0);

    raceStat = grade::GetHPScale(grade, baseValueColumn) + (grade::GetHPScale(grade, scaleTo60Column) * mainLevelUpTo60) +
               (grade::GetHPScale(grade, scaleOver30Column) * mainLevelOver30) + (grade::GetHPScale(grade, scaleOver60Column) * mainLevelOver60To75) +
               (grade::GetHPScale(grade, scaleOver75Column) * mainLevelOver75);

    // Calculation on Main Job
    grade = grade::GetJobGrade(mjob, 0);

    jobStat = grade::GetHPScale(grade, baseValueColumn) + (grade::GetHPScale(grade, scaleTo60Column) * mainLevelUpTo60) +
              (grade::GetHPScale(grade, scaleOver30Column) * mainLevelOver30) + (grade::GetHPScale(grade, scaleOver60Column) * mainLevelOver60To75) +
              (grade::GetHPScale(grade, scaleOver75Column) * mainLevelOver75);

    // Calculation of bonus HP.
    bonusStat = (mainLevelOver10 + mainLevelOver50andUnder60) * 2;

    // Calculation on Support Job
    if (slvl > 0)
    {
        grade = grade::GetJobGrade(sjob, 0);

        sJobStat = grade::GetHPScale(grade, baseValueColumn) + (grade::GetHPScale(grade, scaleTo60Column) * (slvl - 1)) +
                   (grade::GetHPScale(grade, scaleOver30Column) * subLevelOver30) + subLevelOver30 + subLevelOver10;
        sJobStat = sJobStat / 2;
    }

    uint16 MeritBonus   = PChar->PMeritPoints->GetMeritValue(MERIT_MAX_HP, PChar);
    PChar->health.maxhp = (int16)(raceStat + jobStat + bonusStat + sJobStat + MeritBonus);

    // The beginning of the MP

    raceStat = 0;
    jobStat  = 0;
    sJobStat = 0;

    // Calculation of the MP race.
    grade = grade::GetRaceGrades(race, 1);

    // If Main Job has no MP rating, we calculate a racial bonus based on the level of the subjob level (provided that he has a MP rating)
    if (grade::GetJobGrade(mjob, 1) == 0)
    {
        if (grade::GetJobGrade(sjob, 1) != 0 && slvl > 0) // TODO: In this expression, an error
        {
            raceStat =
                (grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column) * (slvl - 1)) / settings::get<float>("map.SJ_MP_DIVISOR"); // TODO: Here is a mistake
        }
    }
    else
    {
        // Calculation of a normal racial bonus
        raceStat = grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column) * mainLevelUpTo60 +
                   grade::GetMPScale(grade, scaleOver60) * mainLevelOver60;
    }

    // Main Job
    grade = grade::GetJobGrade(mjob, 1);
    if (grade > 0)
    {
        jobStat = grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column) * mainLevelUpTo60 +
                  grade::GetMPScale(grade, scaleOver60) * mainLevelOver60;
    }

    // Subjob
    if (slvl > 0)
    {
        grade    = grade::GetJobGrade(sjob, 1);
        sJobStat = (grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column) * (slvl - 1)) / settings::get<float>("map.SJ_MP_DIVISOR");
    }

    MeritBonus          = PChar->PMeritPoints->GetMeritValue(MERIT_MAX_MP, PChar);
    PChar->health.maxmp = (int16)(raceStat + jobStat + sJobStat + MeritBonus); // MP calculation result

    // Start calculating Stats

    uint8 counter = 0;

    for (uint8 StatIndex = 2; StatIndex <= 8; ++StatIndex)
    {
        // Calculation of race
        grade    = grade::GetRaceGrades(race, StatIndex);
        raceStat = grade::GetStatScale(grade, 0) + grade::GetStatScale(grade, scaleTo60Column) * mainLevelUpTo60;

        if (mainLevelOver60 > 0)
        {
            raceStat += grade::GetStatScale(grade, scaleOver60) * mainLevelOver60;

            if (mainLevelOver75 > 0)
            {
                raceStat += grade::GetStatScale(grade, scaleOver75) * mainLevelOver75 - (mlvl >= 75 ? 0.01f : 0);
            }
        }

        // Calculation by profession
        grade   = grade::GetJobGrade(mjob, StatIndex);
        jobStat = grade::GetStatScale(grade, 0) + grade::GetStatScale(grade, scaleTo60Column) * mainLevelUpTo60;

        if (mainLevelOver60 > 0)
        {
            jobStat += grade::GetStatScale(grade, scaleOver60) * mainLevelOver60;

            if (mainLevelOver75 > 0)
            {
                jobStat += grade::GetStatScale(grade, scaleOver75) * mainLevelOver75 - (mlvl >= 75 ? 0.01f : 0);
            }
        }

        // Calculation for an additional profession
        if (slvl > 0)
        {
            grade    = grade::GetJobGrade(sjob, StatIndex);
            sJobStat = (grade::GetStatScale(grade, 0) + grade::GetStatScale(grade, scaleTo60Column) * (slvl - 1)) / 2;
        }
        else
        {
            sJobStat = 0;
        }

        // get each merit bonus stat, str,dex,vit and so on...
        MeritBonus = PChar->PMeritPoints->GetMeritValue(statMerit[StatIndex - 2], PChar);

        // Value output
        ref<uint16>(&PChar->stats, counter) = (uint16)(raceStat + jobStat + sJobStat + MeritBonus);
        counter += 2;
    }
}

/************************************************************************
 *                                                                       *
 *  The preliminary version of the character loading. Function will be   *
 *  optimized after determining all the necessary data and tables        *
 *                                                                       *
 ************************************************************************/

auto LoadChar(Scheduler& scheduler, MapConfig config, const uint32 charId) -> std::unique_ptr<CCharEntity>
{
    TracyZoneScoped;

    std::unique_ptr<CCharEntity> charEntity = std::make_unique<CCharEntity>();
    auto*                        PChar      = charEntity.get();
    PChar->id                               = charId;

    uint8  meritPoints = 0;
    uint16 limitPoints = 0;
    int32  HP          = 0;
    int32  MP          = 0;

    // TODO: extract into LoadFromCharsSQL
    const char* fmtQuery = "SELECT "
                           "charname, "
                           "nation, "
                           "pos_zone, "
                           "pos_prevzone, "
                           "pos_prevzonelineid, "
                           "pos_rot, "
                           "pos_x, "
                           "pos_y, "
                           "pos_z, "
                           "moghouse, "
                           "boundary, "
                           "accid, "
                           "home_zone, "
                           "home_rot, "
                           "home_x, "
                           "home_y, "
                           "home_z, "
                           "missions, "
                           "assault, "
                           "campaign, "
                           "eminence, "
                           "quests, "
                           "keyitems, "
                           "abilities, "
                           "weaponskills, "
                           "titles, "
                           "zones, "
                           "playtime, "
                           "gmlevel, "
                           "languages, "
                           "job_master, "
                           "campaign_allegiance, "
                           "isstylelocked, "
                           "settings, "
                           "chatfilters_1, "
                           "chatfilters_2, "
                           "moghancement, "
                           "UNIX_TIMESTAMP(`lastupdate`) AS lastonline "
                           "FROM chars "
                           "WHERE charid = ?";

    auto rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->targid = 0x400;
        PChar->SetName(rset->get<std::string>("charname").c_str());

        PChar->loc.destination  = rset->get<uint16>("pos_zone");
        PChar->loc.prevzone     = rset->get<uint16>("pos_prevzone");
        PChar->m_PrevZonelineID = rset->get<uint32>("pos_prevzonelineid");

        PChar->loc.p.rotation = rset->get<uint8>("pos_rot");
        PChar->loc.p.x        = rset->get<float>("pos_x");
        PChar->loc.p.y        = rset->get<float>("pos_y");
        PChar->loc.p.z        = rset->get<float>("pos_z");
        PChar->m_moghouseID   = rset->get<uint32>("moghouse");
        PChar->loc.boundary   = rset->get<uint16>("boundary");
        PChar->accid          = rset->get<uint32>("accid");

        PChar->profile.home_point.destination = rset->get<uint16>("home_zone");
        PChar->profile.home_point.p.rotation  = rset->get<uint8>("home_rot");
        PChar->profile.home_point.p.x         = rset->get<float>("home_x");
        PChar->profile.home_point.p.y         = rset->get<float>("home_y");
        PChar->profile.home_point.p.z         = rset->get<float>("home_z");

        PChar->profile.nation = rset->get<uint8>("nation");

        db::extractFromBlob(rset, "quests", PChar->m_questLog);
        db::extractFromBlob(rset, "keyitems", PChar->keys);
        db::extractFromBlob(rset, "abilities", PChar->m_LearnedAbilities);
        db::extractFromBlob(rset, "weaponskills", PChar->m_LearnedWeaponskills);
        db::extractFromBlob(rset, "titles", PChar->m_TitleList);
        db::extractFromBlob(rset, "zones", PChar->m_ZonesVisitedList);
        db::extractFromBlob(rset, "missions", PChar->m_missionLog);
        db::extractFromBlob(rset, "assault", PChar->m_assaultLog);
        db::extractFromBlob(rset, "campaign", PChar->m_campaignLog);
        db::extractFromBlob(rset, "eminence", PChar->m_eminenceLog);

        PChar->SetPlayTime(std::chrono::seconds(rset->get<uint32>("playtime")));
        PChar->profile.campaign_allegiance = rset->get<uint8>("campaign_allegiance");
        PChar->setStyleLocked(rset->get<uint32>("isstylelocked") == 1);
        PChar->SetMoghancement(rset->get<uint16>("moghancement"));
        PChar->lastOnline      = earth_time::time_point(std::chrono::seconds(rset->get<uint32>("lastonline")));
        PChar->search.language = rset->get<uint8>("languages");

        PChar->m_GMlevel          = rset->get<uint8>("gmlevel");
        PChar->m_jobMasterDisplay = rset->get<uint32>("job_master") > 0;

        const auto playerSettings = rset->get<uint32>("settings");
        const auto MessageFilter  = rset->get<uint32>("chatfilters_1");
        const auto MessageFilter2 = rset->get<uint32>("chatfilters_2");

        std::memcpy(&PChar->playerConfig, &playerSettings, sizeof(uint32_t));
        std::memcpy(&PChar->playerConfig.MessageFilter, &MessageFilter, sizeof(uint32_t));
        std::memcpy(&PChar->playerConfig.MessageFilter2, &MessageFilter2, sizeof(uint32_t));
    }

    // TODO: Rename LoadFromCharSpellsSQL
    LoadSpells(PChar);

    // TODO: LoadFromCharProfileSQL
    fmtQuery = "SELECT "
               "rank_points,"
               "rank_sandoria,"
               "rank_bastok,"
               "rank_windurst,"
               "fame_sandoria,"
               "fame_bastok,"
               "fame_windurst,"
               "fame_norg, "
               "fame_jeuno, "
               "fame_aby_konschtat, "
               "fame_aby_tahrongi, "
               "fame_aby_latheine, "
               "fame_aby_misareaux, "
               "fame_aby_vunkerl, "
               "fame_aby_attohwa, "
               "fame_aby_altepa, "
               "fame_aby_grauberg, "
               "fame_aby_uleguerand, "
               "fame_adoulin,"
               "unity_leader "
               "FROM char_profile "
               "WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->profile.rankpoints = rset->get<uint16>("rank_points");

        PChar->profile.rank[0] = rset->get<uint8>("rank_sandoria");
        PChar->profile.rank[1] = rset->get<uint8>("rank_bastok");
        PChar->profile.rank[2] = rset->get<uint8>("rank_windurst");

        PChar->profile.fame[0]      = rset->get<uint16>("fame_sandoria");
        PChar->profile.fame[1]      = rset->get<uint16>("fame_bastok");
        PChar->profile.fame[2]      = rset->get<uint16>("fame_windurst");
        PChar->profile.fame[3]      = rset->get<uint16>("fame_norg");
        PChar->profile.fame[4]      = rset->get<uint16>("fame_jeuno");
        PChar->profile.fame[5]      = rset->get<uint16>("fame_aby_konschtat");
        PChar->profile.fame[6]      = rset->get<uint16>("fame_aby_tahrongi");
        PChar->profile.fame[7]      = rset->get<uint16>("fame_aby_latheine");
        PChar->profile.fame[8]      = rset->get<uint16>("fame_aby_misareaux");
        PChar->profile.fame[9]      = rset->get<uint16>("fame_aby_vunkerl");
        PChar->profile.fame[10]     = rset->get<uint16>("fame_aby_attohwa");
        PChar->profile.fame[11]     = rset->get<uint16>("fame_aby_altepa");
        PChar->profile.fame[12]     = rset->get<uint16>("fame_aby_grauberg");
        PChar->profile.fame[13]     = rset->get<uint16>("fame_aby_uleguerand");
        PChar->profile.fame[14]     = rset->get<uint16>("fame_adoulin");
        PChar->profile.unity_leader = rset->get<uint8>("unity_leader");
    }

    roeutils::onCharLoad(PChar);

    // TODO: LoadFromCharStorageSQL
    fmtQuery = "SELECT "
               "inventory,"
               "safe,"
               "locker,"
               "satchel,"
               "sack,"
               "`case`,"
               "wardrobe,"
               "wardrobe2,"
               "wardrobe3,"
               "wardrobe4,"
               "wardrobe5,"
               "wardrobe6,"
               "wardrobe7,"
               "wardrobe8 "
               "FROM char_storage "
               "WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->getStorage(LOC_INVENTORY)->AddBuff(rset->get<uint8>("inventory"));
        PChar->getStorage(LOC_MOGSAFE)->AddBuff(rset->get<uint8>("safe"));
        PChar->getStorage(LOC_MOGSAFE2)->AddBuff(rset->get<uint8>("safe"));
        PChar->getStorage(LOC_TEMPITEMS)->AddBuff(50);
        PChar->getStorage(LOC_MOGLOCKER)->AddBuff(rset->get<uint8>("locker"));
        PChar->getStorage(LOC_MOGSATCHEL)->AddBuff(rset->get<uint8>("satchel"));
        PChar->getStorage(LOC_MOGSACK)->AddBuff(rset->get<uint8>("sack"));
        PChar->getStorage(LOC_MOGCASE)->AddBuff(rset->get<uint8>("case"));

        PChar->getStorage(LOC_WARDROBE)->AddBuff(rset->get<uint8>("wardrobe"));
        PChar->getStorage(LOC_WARDROBE2)->AddBuff(rset->get<uint8>("wardrobe2"));
        PChar->getStorage(LOC_WARDROBE3)->AddBuff(rset->get<uint8>("wardrobe3"));
        PChar->getStorage(LOC_WARDROBE4)->AddBuff(rset->get<uint8>("wardrobe4"));

        PChar->getStorage(LOC_WARDROBE5)->AddBuff(rset->get<uint8>("wardrobe5"));
        PChar->getStorage(LOC_WARDROBE6)->AddBuff(rset->get<uint8>("wardrobe6"));
        PChar->getStorage(LOC_WARDROBE7)->AddBuff(rset->get<uint8>("wardrobe7"));
        PChar->getStorage(LOC_WARDROBE8)->AddBuff(rset->get<uint8>("wardrobe8"));

        // NOTE: Not from the db, hard-coded to 10!
        PChar->getStorage(LOC_RECYCLEBIN)->AddBuff(10);
    }

    // TODO: LoadFromCharLookSQL
    fmtQuery = "SELECT face, race, size, head, body, hands, legs, feet, main, sub, ranged "
               "FROM char_look "
               "WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->look.face = rset->get<uint8>("face");
        PChar->look.race = rset->get<uint8>("race");
        PChar->look.size = rset->get<uint8>("size");

        PChar->look.head   = rset->get<uint16>("head");
        PChar->look.body   = rset->get<uint16>("body");
        PChar->look.hands  = rset->get<uint16>("hands");
        PChar->look.legs   = rset->get<uint16>("legs");
        PChar->look.feet   = rset->get<uint16>("feet");
        PChar->look.main   = rset->get<uint16>("main");
        PChar->look.sub    = rset->get<uint16>("sub");
        PChar->look.ranged = rset->get<uint16>("ranged");

        std::memcpy(&PChar->mainlook, &PChar->look, sizeof(PChar->look));
    }

    // Model size doesn't matter here per caps, only race
    // From the packets, size is 4/3/8 as integer
    // For distance purposes, these are divided by 10
    switch (static_cast<CharRace>(PChar->look.race))
    {
        case CharRace::HumeMale:
        case CharRace::HumeFemale:
            PChar->modelHitboxSize = 4.0f / 10.0f;
            break;
        case CharRace::ElvaanMale:
        case CharRace::ElvaanFemale:
            PChar->modelHitboxSize = 4.0f / 10.0f;
            break;
        case CharRace::TarutaruMale:
        case CharRace::TarutaruFemale:
            PChar->modelHitboxSize = 3.0f / 10.0f;
            break;
        case CharRace::Mithra:
            PChar->modelHitboxSize = 4.0f / 10.0f;
            break;
        case CharRace::Galka:
            PChar->modelHitboxSize = 8.0f / 10.0f;
            break;
        default:
            PChar->modelHitboxSize = 4.0f / 10.0f;
            break;
    }

    // LoadFromCharStyleSQL
    fmtQuery = "SELECT head, body, hands, legs, feet, main, sub, ranged FROM char_style WHERE charid = ?";
    rset     = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->styleItems[SLOT_HEAD]   = rset->get<uint16>("head");
        PChar->styleItems[SLOT_BODY]   = rset->get<uint16>("body");
        PChar->styleItems[SLOT_HANDS]  = rset->get<uint16>("hands");
        PChar->styleItems[SLOT_LEGS]   = rset->get<uint16>("legs");
        PChar->styleItems[SLOT_FEET]   = rset->get<uint16>("feet");
        PChar->styleItems[SLOT_MAIN]   = rset->get<uint16>("main");
        PChar->styleItems[SLOT_SUB]    = rset->get<uint16>("sub");
        PChar->styleItems[SLOT_RANGED] = rset->get<uint16>("ranged");
    }

    // LoadFromCharJobsSQL
    fmtQuery = "SELECT unlocked, genkai, war, mnk, whm, blm, rdm, thf, pld, drk, bst, brd, rng, sam, nin, drg, smn, blu, cor, pup, dnc, sch, geo, run "
               "FROM char_jobs "
               "WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->jobs.unlocked = rset->get<uint32>("unlocked");
        PChar->jobs.genkai   = rset->get<uint8>("genkai");

        PChar->jobs.job[JOB_WAR] = rset->get<uint8>("war");
        PChar->jobs.job[JOB_MNK] = rset->get<uint8>("mnk");
        PChar->jobs.job[JOB_WHM] = rset->get<uint8>("whm");
        PChar->jobs.job[JOB_BLM] = rset->get<uint8>("blm");
        PChar->jobs.job[JOB_RDM] = rset->get<uint8>("rdm");
        PChar->jobs.job[JOB_THF] = rset->get<uint8>("thf");
        PChar->jobs.job[JOB_PLD] = rset->get<uint8>("pld");
        PChar->jobs.job[JOB_DRK] = rset->get<uint8>("drk");
        PChar->jobs.job[JOB_BST] = rset->get<uint8>("bst");
        PChar->jobs.job[JOB_BRD] = rset->get<uint8>("brd");
        PChar->jobs.job[JOB_RNG] = rset->get<uint8>("rng");
        PChar->jobs.job[JOB_SAM] = rset->get<uint8>("sam");
        PChar->jobs.job[JOB_NIN] = rset->get<uint8>("nin");
        PChar->jobs.job[JOB_DRG] = rset->get<uint8>("drg");
        PChar->jobs.job[JOB_SMN] = rset->get<uint8>("smn");
        PChar->jobs.job[JOB_BLU] = rset->get<uint8>("blu");
        PChar->jobs.job[JOB_COR] = rset->get<uint8>("cor");
        PChar->jobs.job[JOB_PUP] = rset->get<uint8>("pup");
        PChar->jobs.job[JOB_DNC] = rset->get<uint8>("dnc");
        PChar->jobs.job[JOB_SCH] = rset->get<uint8>("sch");
        PChar->jobs.job[JOB_GEO] = rset->get<uint8>("geo");
        PChar->jobs.job[JOB_RUN] = rset->get<uint8>("run");
    }

    // LoadFromCharExpSQL
    fmtQuery = "SELECT mode, war, mnk, whm, blm, rdm, thf, pld, drk, bst, brd, rng, sam, nin, drg, smn, blu, cor, pup, dnc, sch, geo, run, merits, limits "
               "FROM char_exp "
               "WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->MeritMode = rset->get<uint8>("mode");

        PChar->jobs.exp[JOB_WAR] = rset->get<uint16>("war");
        PChar->jobs.exp[JOB_MNK] = rset->get<uint16>("mnk");
        PChar->jobs.exp[JOB_WHM] = rset->get<uint16>("whm");
        PChar->jobs.exp[JOB_BLM] = rset->get<uint16>("blm");
        PChar->jobs.exp[JOB_RDM] = rset->get<uint16>("rdm");
        PChar->jobs.exp[JOB_THF] = rset->get<uint16>("thf");
        PChar->jobs.exp[JOB_PLD] = rset->get<uint16>("pld");
        PChar->jobs.exp[JOB_DRK] = rset->get<uint16>("drk");
        PChar->jobs.exp[JOB_BST] = rset->get<uint16>("bst");
        PChar->jobs.exp[JOB_BRD] = rset->get<uint16>("brd");
        PChar->jobs.exp[JOB_RNG] = rset->get<uint16>("rng");
        PChar->jobs.exp[JOB_SAM] = rset->get<uint16>("sam");
        PChar->jobs.exp[JOB_NIN] = rset->get<uint16>("nin");
        PChar->jobs.exp[JOB_DRG] = rset->get<uint16>("drg");
        PChar->jobs.exp[JOB_SMN] = rset->get<uint16>("smn");
        PChar->jobs.exp[JOB_BLU] = rset->get<uint16>("blu");
        PChar->jobs.exp[JOB_COR] = rset->get<uint16>("cor");
        PChar->jobs.exp[JOB_PUP] = rset->get<uint16>("pup");
        PChar->jobs.exp[JOB_DNC] = rset->get<uint16>("dnc");
        PChar->jobs.exp[JOB_SCH] = rset->get<uint16>("sch");
        PChar->jobs.exp[JOB_GEO] = rset->get<uint16>("geo");
        PChar->jobs.exp[JOB_RUN] = rset->get<uint16>("run");

        meritPoints = rset->get<uint8>("merits");
        limitPoints = rset->get<uint16>("limits");
    }

    // TODO: LoadFromCharStatsSQL
    fmtQuery = "SELECT mjob, sjob, hp, mp, mhflag, title, bazaar_message, zoning, "
               "pet_id, pet_type, pet_hp, pet_mp, pet_level "
               "FROM char_stats WHERE charid = ?";

    uint8 zoning = 0;
    rset         = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->SetMJob(rset->get<uint8>("mjob"));
        PChar->SetSJob(rset->get<uint8>("sjob"));

        HP = rset->get<int32>("hp");
        MP = rset->get<int32>("mp");

        PChar->profile.mhflag = rset->get<uint16>("mhflag");
        PChar->profile.title  = rset->get<uint16>("title");

        std::array<uint8, 512> bazaarMessageArray{};
        db::extractFromBlob(rset, "bazaar_message", bazaarMessageArray);
        const char* bazaarMessageStr = reinterpret_cast<const char*>(bazaarMessageArray.data());
        if (bazaarMessageStr != nullptr)
        {
            PChar->bazaar.message.insert(0, bazaarMessageStr);
        }
        else
        {
            PChar->bazaar.message = '\0';
        }

        zoning = rset->get<uint8>("zoning");

        // Determine if the pet should be respawned.
        int16 petHP = rset->get<int16>("pet_hp");
        if (petHP)
        {
            PChar->petZoningInfo.petHP        = petHP;
            PChar->petZoningInfo.petID        = rset->get<uint8>("pet_id");
            PChar->petZoningInfo.petMP        = rset->get<int16>("pet_mp");
            PChar->petZoningInfo.petType      = rset->get<PET_TYPE>("pet_type");
            PChar->petZoningInfo.petLevel     = rset->get<uint8>("pet_level");
            PChar->petZoningInfo.respawnPet   = true;
            auto jugTimestamp                 = static_cast<uint32>(PChar->getCharVar("jugpet-spawn-time"));
            PChar->petZoningInfo.jugSpawnTime = timer::from_utc(earth_time::time_point(std::chrono::seconds(jugTimestamp)));
            PChar->petZoningInfo.jugDuration  = std::chrono::seconds(PChar->getCharVar("jugpet-duration-seconds"));

            // clear the charvars used for jug state
            PChar->clearCharVarsWithPrefix("jugpet-");
        }
    }

    db::preparedStmt("UPDATE char_stats SET zoning = 0 WHERE charid = ? LIMIT 1", PChar->id);

    if (zoning == 2)
    {
        ShowDebug("Player <%s> logging in to zone <%u>", PChar->name.c_str(), PChar->getZone());

        // Set this value so we can not process some effects until the player is fully in-game.
        // This is cleared in the player global, onGameIn function.
        PChar->SetLocalVar("gameLogin", 1);
    }

    PChar->SetMLevel(PChar->jobs.job[PChar->GetMJob()]);
    PChar->SetSLevel(PChar->jobs.job[PChar->GetSJob()]);

    // TODO: LoadFromCharRecastSQL
    fmtQuery = "SELECT id, time, recast FROM char_recast WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount())
    {
        while (rset->next())
        {
            auto            now        = timer::now();
            auto            cast_time  = timer::from_utc(earth_time::time_point(std::chrono::seconds(rset->get<uint32>("time"))));
            auto            recast     = std::chrono::seconds(rset->get<uint32>("recast"));
            timer::duration chargeTime = 0s;
            uint8           maxCharges = 0;
            Charge_t*       charge     = ability::GetCharge(PChar, rset->get<uint32>("id"));
            if (charge != nullptr)
            {
                chargeTime = charge->chargeTime;
                maxCharges = charge->maxCharges;
            }
            if (now < cast_time + recast)
            {
                PChar->PRecastContainer->Load(RECAST_ABILITY, rset->get<Recast>("id"), (cast_time + recast - now), chargeTime, maxCharges);
            }
        }
    }

    // TODO: LoadFromCharSkillsSQL
    fmtQuery = "SELECT skillid, value, rank "
               "FROM char_skills "
               "WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount())
    {
        while (rset->next())
        {
            uint8 SkillID = rset->get<uint8>("skillid");
            if (SkillID < MAX_SKILLTYPE)
            {
                PChar->RealSkills.skill[SkillID] = rset->get<uint16>("value");
                if (SkillID >= SKILL_FISHING)
                {
                    PChar->RealSkills.rank[SkillID] = rset->get<uint8>("rank");
                }
            }
        }
    }

    // LoadFromCharUnlocksSQL
    fmtQuery = "SELECT outpost_sandy, outpost_bastok, outpost_windy, runic_portal, maw, "
               "campaign_sandy, campaign_bastok, campaign_windy, homepoints, survivals, "
               "abyssea_conflux, waypoints, eschan_portals, claimed_deeds, unique_event "
               "FROM char_unlocks "
               "WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->teleport.outpostSandy   = rset->get<uint32>("outpost_sandy");
        PChar->teleport.outpostBastok  = rset->get<uint32>("outpost_bastok");
        PChar->teleport.outpostWindy   = rset->get<uint32>("outpost_windy");
        PChar->teleport.runicPortal    = rset->get<uint32>("runic_portal");
        PChar->teleport.pastMaw        = rset->get<uint32>("maw");
        PChar->teleport.campaignSandy  = rset->get<uint32>("campaign_sandy");
        PChar->teleport.campaignBastok = rset->get<uint32>("campaign_bastok");
        PChar->teleport.campaignWindy  = rset->get<uint32>("campaign_windy");

        db::extractFromBlob(rset, "homepoints", PChar->teleport.homepoint);
        db::extractFromBlob(rset, "survivals", PChar->teleport.survival);
        db::extractFromBlob(rset, "abyssea_conflux", PChar->teleport.abysseaConflux);
        db::extractFromBlob(rset, "waypoints", PChar->teleport.waypoints);
        db::extractFromBlob(rset, "eschan_portals", PChar->teleport.eschanPortal);
        db::extractFromBlob(rset, "claimed_deeds", PChar->m_claimedDeeds);
        db::extractFromBlob(rset, "unique_event", PChar->m_uniqueEvents);
    }

    // TODO: Remove raw new's
    PChar->PMeritPoints = std::make_unique<CMeritPoints>(PChar);
    PChar->PMeritPoints->SetMeritPoints(meritPoints);
    PChar->PMeritPoints->SetLimitPoints(limitPoints);
    PChar->PJobPoints = std::make_unique<CJobPoints>(PChar);

    rset = db::preparedStmt("SELECT field_chocobo FROM char_pet WHERE charid = ?", PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        PChar->m_FieldChocobo = rset->get<uint32>("field_chocobo");
    }

    // TODO: LoadCharFlagsFromSQL
    fmtQuery = "SELECT gmModeEnabled, gmHiddenEnabled FROM char_flags WHERE charid = ?";

    rset = db::preparedStmt(fmtQuery, PChar->id);
    if (rset && rset->rowsCount() && rset->next())
    {
        bool gmEnabled = rset->get<uint32>("gmModeEnabled");
        bool gmHidden  = rset->get<uint32>("gmHiddenEnabled");

        if (gmEnabled)
        {
            // + 3 because visible GM level starts at 3 (0 is none, 1-2 are special icons)
            PChar->visibleGmLevel = std::min(PChar->m_GMlevel + 3, 7);
        }

        PChar->m_isGMHidden = gmHidden;
    }

    monstrosity::TryPopulateMonstrosityData(PChar);

    charutils::LoadInventory(PChar);

    CalculateStats(PChar);
    jobpointutils::RefreshGiftMods(PChar);

    // This must come after refreshing gift modifiers, but before loading job traits.
    blueutils::LoadSetSpells(PChar);

    BuildingCharSkillsTable(PChar);
    BuildingCharAbilityTable(PChar);
    BuildingCharTraitsTable(PChar);

    // Order matters as this uses merits and JP gifts.
    puppetutils::LoadAutomaton(PChar);

    PChar->animation = (HP == 0 ? ANIMATION_DEATH : ANIMATION_NONE);

    PChar->StatusEffectContainer->LoadStatusEffects();

    charutils::LoadEquip(PChar);
    charutils::EmptyRecycleBin(PChar);
    bool canRestore  = zoneutils::IsResidentialArea(PChar) && HP > 0;
    PChar->health.hp = canRestore ? PChar->GetMaxHP() : HP;
    PChar->health.mp = canRestore ? PChar->GetMaxMP() : MP;
    PChar->UpdateHealth();

    // Lazy loading: ensure initial zone is loaded synchronously before OnZoneIn
    // TODO: Hoist his block out of LoadChar() so we're guaranteeing that a char's zone exists
    //     : before we try to put them in it.
    if (zoneutils::IsLazyLoadingEnabled() && !zoneutils::GetZone(PChar->loc.destination))
    {
        // TODO: Remove this usage of blockOnMain, it's here to help with xi_test
        scheduler.blockOnMainThread(zoneutils::LoadZones(scheduler, config, { PChar->loc.destination }));
    }

    luautils::OnZoneIn(PChar);
    luautils::OnGameIn(PChar, zoning == 1);

    PChar->status = STATUS_TYPE::DISAPPEAR;

    return charEntity;
}

void LoadSpells(CCharEntity* PChar)
{
    TracyZoneScoped;

    // disable all spells
    PChar->m_SpellList.reset();

    // Compile a list of all enabled expansions
    std::vector<std::string> enabledExpansions;
    for (const auto& expansion : { "COP", "TOAU", "WOTG", "ACP", "AMK", "ASA", "ABYSSEA", "SOA", "ROV", "TVR", "VOIDWATCH" })
    {
        if (luautils::IsContentEnabled(expansion))
        {
            enabledExpansions.push_back(fmt::format("\"{}\"", expansion));
        }
    }

    std::string condition = "spell_list.content_tag IS NULL";

    if (!enabledExpansions.empty())
    {
        condition = fmt::format("spell_list.content_tag IN ({}) OR spell_list.content_tag IS NULL", fmt::join(enabledExpansions, ","));
    }

    // Select all player spells from enabled expansions
    //
    // NOTE: We normally don't want to build a prepared statement with fmt::format,
    //     : but this query is entirely internal, so it's OK.
    auto query = fmt::format("SELECT char_spells.spellid "
                             "FROM char_spells "
                             "JOIN spell_list "
                             "ON spell_list.spellid = char_spells.spellid "
                             "WHERE charid = ? AND ({})",
                             condition);

    auto rset = db::preparedStmt(query, PChar->id);
    if (rset && rset->rowsCount())
    {
        while (rset->next())
        {
            uint16 spellId = rset->get<uint16>("spellid");
            if (spell::GetSpell(static_cast<SpellID>(spellId)) != nullptr)
            {
                PChar->m_SpellList.set(spellId);
            }
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Download Character inventory                                         *
 *                                                                       *
 ************************************************************************/

void LoadInventory(CCharEntity* PChar)
{
    TracyZoneScoped;

    const char* query = "SELECT "
                        "itemid, "
                        "location, "
                        "slot, "
                        "quantity, "
                        "bazaar, "
                        "signature, "
                        "extra "
                        "FROM char_inventory "
                        "WHERE charid = ? "
                        "ORDER BY FIELD(location,0,1,9,2,3,4,5,6,7,8,10,11,12)";

    auto rset = db::preparedStmt(query, PChar->id);
    if (rset && rset->rowsCount())
    {
        while (rset->next())
        {
            auto PItem = xi::items::spawn(rset->get<uint16>("itemid"));
            if (PItem != nullptr)
            {
                PItem->setLocationID(rset->get<uint8>("location"));
                PItem->setSlotID(rset->get<uint8>("slot"));
                PItem->setQuantity(rset->get<uint32>("quantity"));
                PItem->setCharPrice(rset->get<uint32>("bazaar"));

                db::extractFromBlob(rset, "extra", PItem->m_extra);

                if (PItem->getCharPrice() != 0)
                {
                    PItem->setSubType(ITEM_LOCKED);
                }

                if (PItem->isType(ITEM_LINKSHELL))
                {
                    auto* PLink = static_cast<CItemLinkshell*>(PItem.get());
                    if (PLink->GetLSType() == 0)
                    {
                        PLink->SetLSType((LSTYPE)(PItem->getID() - 0x200));
                    }
                    PItem->setSignature(rset->get<std::string>("signature"));
                }
                else if (PItem->hasFlag(ItemFlag::Inscribable))
                {
                    PItem->setSignature(rset->get<std::string>("signature"));
                }

                if (auto* PItemUsable = dynamic_cast<CItemUsable*>(PItem.get()))
                {
                    uint32 useTime = 0;
                    std::memcpy(&useTime, PItemUsable->m_extra + 0x04, sizeof(useTime));
                    if (useTime != 0)
                    {
                        PItemUsable->setLastUseTime(timer::now() - std::chrono::seconds(earth_time::vanadiel_timestamp() - useTime));
                    }
                }

                if (PItem->isType(ITEM_FURNISHING) && (PItem->getLocationID() == LOC_MOGSAFE || PItem->getLocationID() == LOC_MOGSAFE2))
                {
                    if (static_cast<CItemFurnishing*>(PItem.get())->isInstalled()) // Check if furniture (furnishing) item is actually installed
                    {
                        PChar->getStorage(LOC_STORAGE)->AddBuff(static_cast<CItemFurnishing*>(PItem.get())->getStorage());
                    }
                }
                const uint8 locID  = PItem->getLocationID();
                const uint8 slotID = PItem->getSlotID();
                PChar->getStorage(locID)->InsertItem(std::move(PItem), slotID);
            }
        }
    }

    // apply augments
    // loop over each container
    for (uint8 i = 0; i < CONTAINER_ID::MAX_CONTAINER_ID; ++i)
    {
        CItemContainer* PItemContainer = PChar->getStorage(i);

        if (PItemContainer != nullptr)
        {
            // now find each item in the container
            for (uint8 y = 0; y < MAX_CONTAINER_SIZE; ++y)
            {
                CItem* PItem = PItemContainer->GetItem(y);

                // check if the item is valid and can have an augment applied to it
                if (PItem != nullptr && ((PItem->isType(ITEM_EQUIPMENT) || PItem->isType(ITEM_WEAPON)) && !PItem->isSubType(ITEM_CHARGED)))
                {
                    // check if there are any valid augments to be applied to the item
                    for (uint8 j = 0; j < 4; ++j)
                    {
                        // found a match, apply the augment
                        if (((CItemEquipment*)PItem)->getAugment(j) != 0)
                        {
                            ((CItemEquipment*)PItem)->ApplyAugment(j);
                        }
                    }
                }
            }
        }
    }
}

void LoadEquip(CCharEntity* PChar)
{
    TracyZoneScoped;

    const char* Query = "SELECT "
                        "slotid,"
                        "equipslotid,"
                        "containerid "
                        "FROM char_equip "
                        "WHERE charid = ?";

    auto rset = db::preparedStmt(Query, PChar->id);
    if (rset)
    {
        // equipSlotData[equipSlotId] = { slotId, containerId }
        std::map<uint8, std::pair<uint8, uint8>> equipSlotData;

        // NOTE: This data is stored in the above map since if the item has an augment, another db
        // query will occur, which will destroy the current query results.
        while (rset->next())
        {
            uint8 equipSlotId          = rset->get<uint8>("equipslotid");
            uint8 slotId               = rset->get<uint8>("slotid");
            uint8 containerId          = rset->get<uint8>("containerid");
            equipSlotData[equipSlotId] = { slotId, containerId };
        }

        CItemLinkshell* PLinkshell1   = nullptr;
        CItemLinkshell* PLinkshell2   = nullptr;
        bool            hasMainWeapon = false;

        for (const auto& [equipSlotId, inventoryLoc] : equipSlotData)
        {
            if (equipSlotId < 16)
            {
                if (equipSlotId == SLOT_MAIN)
                {
                    hasMainWeapon = true;
                }

                EquipItem(PChar, inventoryLoc.first, equipSlotId, inventoryLoc.second);
            }
            else
            {
                CItem* PItem = PChar->getStorage(inventoryLoc.second)->GetItem(inventoryLoc.first);

                if ((PItem != nullptr) && PItem->isType(ITEM_LINKSHELL))
                {
                    PItem->setSubType(ITEM_LOCKED);
                    if (!PChar->bindEquip(equipSlotId, PItem))
                    {
                        continue;
                    }

                    if (equipSlotId == SLOT_LINK1)
                    {
                        PLinkshell1 = (CItemLinkshell*)PItem;
                    }
                    else if (equipSlotId == SLOT_LINK2)
                    {
                        PLinkshell2 = (CItemLinkshell*)PItem;
                    }
                }
            }
        }

        // If no weapon is equipped, equip the appropriate unarmed weapon item
        if (!hasMainWeapon)
        {
            CheckUnarmedWeapon(PChar);
        }

        if (PLinkshell1)
        {
            rset = db::preparedStmt("SELECT broken FROM linkshells WHERE linkshellid = ? LIMIT 1", PLinkshell1->GetLSID());
            if (rset && rset->rowsCount() && rset->next() && rset->get<uint32>("broken") == 1)
            { // if the linkshell has been broken, unequip
                uint8 SlotID     = PLinkshell1->getSlotID();
                uint8 LocationID = PLinkshell1->getLocationID();
                PLinkshell1->setSubType(ITEM_UNLOCKED);
                PChar->clearEquip(SLOT_LINK1);
                db::preparedStmt("DELETE char_equip FROM char_equip WHERE charid = ? AND slotid = ? AND containerid = ? LIMIT 1",
                                 PChar->id,
                                 SlotID,
                                 LocationID);
            }
            else
            {
                linkshell::AddOnlineMember(PChar, PLinkshell1, 1);
            }
        }

        if (PLinkshell2)
        {
            rset = db::preparedStmt("SELECT broken FROM linkshells WHERE linkshellid = ? LIMIT 1", PLinkshell2->GetLSID());
            if (rset && rset->rowsCount() && rset->next() && rset->get<uint32>("broken") == 1)
            { // if the linkshell has been broken, unequip
                uint8 SlotID     = PLinkshell2->getSlotID();
                uint8 LocationID = PLinkshell2->getLocationID();
                PLinkshell2->setSubType(ITEM_UNLOCKED);
                PChar->clearEquip(SLOT_LINK2);
                db::preparedStmt("DELETE char_equip FROM char_equip WHERE charid = ? AND slotid = ? AND containerid = ? LIMIT 1",
                                 PChar->id,
                                 SlotID,
                                 LocationID);
            }
            else
            {
                linkshell::AddOnlineMember(PChar, PLinkshell2, 2);
            }
        }
    }
    else
    {
        ShowError("Loading error from char_equip");
    }

    // Fill in the unarmed psuedo-weapons if no item was equipped
    if (PChar->m_Weapons[SLOT_MAIN] == nullptr)
    {
        CheckUnarmedWeapon(PChar);
    }
}

/************************************************************************
 *                                                                       *
 *  Send lists of current / completed quests and missions.               *
 *                                                                       *
 ************************************************************************/

void SendQuestMissionLog(CCharEntity* PChar)
{
    // Actual verified retail order.
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Sandoria);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Bastok);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Windurst);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Jeuno);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::OtherAreas);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Outlands);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::AhtUrghan);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::CrystalWar);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Sandoria);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Bastok);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Windurst);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Jeuno);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::OtherAreas);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Outlands);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::AhtUrghan);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::CrystalWar);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::Nations);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::ToAU_WoTG);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::Campaign1);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::Campaign2);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Abyssea);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Abyssea);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Adoulin);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Adoulin);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Coalition);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Coalition);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::MISSION>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_MISSION::TVR>(PChar);
}

void SendPartialMissionLog(CCharEntity* PChar, const MissionLog log, const bool completed)
{
    switch (log)
    {
        case MissionLog::Sandoria:
        case MissionLog::Bastok:
        case MissionLog::Windurst:
        case MissionLog::Zilart:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::Nations)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::MISSION>(PChar);
            break;
        }
        case MissionLog::ToAU:
        case MissionLog::WoTG:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::ToAU_WoTG)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::AhtUrghan);
            break;
        }
        case MissionLog::Assault:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::AhtUrghan)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::AhtUrghan);
            break;
        }
        case MissionLog::Campaign:
        {
            if (completed)
            {
                PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::Campaign1);
                PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, MissionComplete::Campaign2);
            }
            else
            {
                // Not a typo...
                PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::AhtUrghan);
            }
            break;
        }
        case MissionLog::CoP:
        case MissionLog::ACP:
        case MissionLog::AMK:
        case MissionLog::ASA:
        case MissionLog::SoA:
        case MissionLog::RoV:
        {
            // These expansions store both completed and in-progress in the same structure
            PChar->pushPacket<GP_SERV_COMMAND_MISSION::MISSION>(PChar);
            break;
        }
    }
}

void SendPartialQuestLog(CCharEntity* PChar, const QuestLog log, const bool completed)
{
    switch (log)
    {
        case QuestLog::Sandoria:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Sandoria)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Sandoria);
            break;
        }
        case QuestLog::Bastok:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Bastok)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Bastok);
            break;
        }
        case QuestLog::Windurst:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Windurst)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Windurst);
            break;
        }
        case QuestLog::Jeuno:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Jeuno)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Jeuno);
            break;
        }
        case QuestLog::OtherAreas:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::OtherAreas)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::OtherAreas);
            break;
        }
        case QuestLog::Outlands:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Outlands)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Outlands);
            break;
        }
        case QuestLog::AhtUrghan:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::AhtUrghan)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::AhtUrghan);
            break;
        }
        case QuestLog::CrystalWar:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::CrystalWar)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::CrystalWar);
            break;
        }
        case QuestLog::Abyssea:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Abyssea)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Abyssea);
            break;
        }
        case QuestLog::Adoulin:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Adoulin)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Adoulin);
            break;
        }
        case QuestLog::Coalition:
        {
            completed ? PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestComplete::Coalition)
                      : PChar->pushPacket<GP_SERV_COMMAND_MISSION::OTHER>(PChar, QuestOffer::Coalition);
            break;
        }
    }
}

void SendRecordsOfEminenceLog(CCharEntity* PChar)
{
    // Send spark updates
    PChar->pushPacket<GP_SERV_COMMAND_UNITY>(PChar);

    if (settings::get<bool>("main.ENABLE_ROE"))
    {
        // Current RoE quests
        PChar->pushPacket<GP_SERV_COMMAND_ROE_ACTIVELOG>(PChar);

        // Players logging in to a new timed record get one-time message
        if (PChar->m_eminenceCache.notifyTimedRecord)
        {
            PChar->m_eminenceCache.notifyTimedRecord = false;
            PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, roeutils::GetActiveTimedRecord(), 0, MsgBasic::ROETimed);
        }

        // 4-part Eminence Completion bitmap
        for (int i = 0; i < 4; i++)
        {
            PChar->pushPacket<GP_SERV_COMMAND_ROE_LOG>(PChar, i);
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Send lists of character key items                                    *
 *                                                                       *
 ************************************************************************/

void SendKeyItems(CCharEntity* PChar)
{
    for (uint8 table = 0; table < PChar->keys.tables.size(); table++)
    {
        PChar->pushPacket<GP_SERV_COMMAND_SCENARIOITEM>(PChar, table);
    }
}

/************************************************************************
 *                                                                       *
 *  Send the character all its inventory                                 *
 *                                                                       *
 ************************************************************************/

void SendInventory(CCharEntity* PChar)
{
    auto pushContainer = [&](auto LocationID)
    {
        CItemContainer* container = PChar->getStorage(LocationID);
        if (container == nullptr)
        {
            return;
        }

        uint8 size = container->GetSize();
        for (uint8 slotID = 0; slotID <= size; ++slotID)
        {
            CItem* PItem = PChar->getStorage(LocationID)->GetItem(slotID);
            if (PItem != nullptr)
            {
                PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PItem, LocationID, slotID);
            }
        }

        // Mark this container as synced and send ITEM_SAME with updated flags
        PChar->inventorySyncState().markSynced(LocationID);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(LocationID, PChar);
    };

    // Send important items first
    // Note: it's possible that non-essential inventory items are sent in response to another packet

    // Container order based on retail capture
    for (auto&& containerID : { LOC_INVENTORY, LOC_MOGSAFE, LOC_MOGSAFE2, LOC_STORAGE, LOC_RECYCLEBIN, LOC_WARDROBE, LOC_WARDROBE2, LOC_WARDROBE3, LOC_WARDROBE4, LOC_WARDROBE5, LOC_WARDROBE6, LOC_WARDROBE7, LOC_WARDROBE8, LOC_TEMPITEMS, LOC_MOGLOCKER, LOC_MOGSATCHEL, LOC_MOGSACK, LOC_MOGCASE })
    {
        pushContainer(containerID);
    }

    for (int32 i = 0; i < 16; ++i)
    {
        CItem* PItem = PChar->getEquip((SLOTTYPE)i);
        if (PItem != nullptr)
        {
            PItem->setSubType(ITEM_LOCKED);
            PChar->pushPacket<GP_SERV_COMMAND_ITEM_LIST>(PItem, ItemLockFlg::NoDrop);
        }
    }

    CItem* PItem = PChar->getEquip(SLOT_LINK1);
    if (PItem != nullptr)
    {
        PItem->setSubType(ITEM_LOCKED);
        auto eloc1 = PChar->equipLocation(SLOT_LINK1);

        PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PItem, *eloc1);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_LIST>(PItem, ItemLockFlg::Linkshell);
        PChar->pushPacket<GP_SERV_COMMAND_GROUP_COMLINK>(PChar, 1);
    }

    PItem = PChar->getEquip(SLOT_LINK2);
    if (PItem != nullptr)
    {
        PItem->setSubType(ITEM_LOCKED);
        auto eloc2 = PChar->equipLocation(SLOT_LINK2);

        PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PItem, *eloc2);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_LIST>(PItem, ItemLockFlg::Linkshell);
        PChar->pushPacket<GP_SERV_COMMAND_GROUP_COMLINK>(PChar, 2);
    }

    PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(PChar);
}

// Sends all 64 Unity ranking packets to the client (0x063 type 0x07)
// Packet sequence:
//   - PreviousWeek (resultSet 0x00): 32 packets (types 0x00-0x1F)
//   - CurrentWeek  (resultSet 0x01): 32 packets (types 0x00-0x1F)
// Client buffers all packets and marks data ready when complete.
// Sent on zone-in and when Unity menu is opened.
// TODO: Some of it needs further research to determine exact values.
void SendUnityPackets(CCharEntity* PChar)
{
    // Query database for unity system data
    const auto rset = db::preparedStmt("SELECT leader, members_current, points_current, members_prev, points_prev "
                                       "FROM unity_system");

    std::pair<int32, double> unity_current[11];
    std::pair<int32, double> unity_previous[11];

    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        auto unity_leader = rset->get<int>("leader") - 1;
        if (unity_leader >= 0 && unity_leader < 11)
        {
            unity_current[unity_leader].first   = rset->get<int32>("members_current");
            unity_current[unity_leader].second  = rset->get<double>("points_current");
            unity_previous[unity_leader].first  = rset->get<int32>("members_prev");
            unity_previous[unity_leader].second = rset->get<double>("points_prev");
        }
    }

    // Previous week (full results)
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::BASE>(UNITY_RESULTSET::PreviousWeek, UNITY_DATATYPE::Base);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::MEMBERS>(UNITY_RESULTSET::PreviousWeek, unity_previous);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::POINTS>(UNITY_RESULTSET::PreviousWeek, unity_previous);
    // Types 0x03-0x0F (empty/flag packets)
    for (int i = 3; i < 0x10; i++)
    {
        PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::BASE>(UNITY_RESULTSET::PreviousWeek, static_cast<UNITY_DATATYPE>(i));
    }
    // Types 0x10-0x1F for PreviousWeek (mostly 0x0008 flags from retail captures)
    for (int i = 0x10; i < 0x20; i++)
    {
        PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::PreviousWeek, i, 0x0008);
    }

    // Current week (partial results)
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::BASE>(UNITY_RESULTSET::CurrentWeek, UNITY_DATATYPE::Base);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::MEMBERS>(UNITY_RESULTSET::CurrentWeek, unity_current);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::POINTS>(UNITY_RESULTSET::CurrentWeek, unity_current);
    // Types 0x03-0x0F (empty/flag packets)
    for (int i = 3; i < 0x10; i++)
    {
        PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::BASE>(UNITY_RESULTSET::CurrentWeek, static_cast<UNITY_DATATYPE>(i));
    }
    // Types 0x10-0x1F for CurrentWeek with appropriate values
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x10, 0x2007);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x11, 0x2CC2);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x12, 0x6867); // ASCII 'gh'
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x13, 0x6E6F); // ASCII 'on'
    // Type 0x14: Personal ranking points (TODO: calculate from player's Unity contributions)
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::PERSONAL>(UNITY_RESULTSET::CurrentWeek, 0);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x15, 0x3605);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x16, 0x2007);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x17, 0x6C6C); // ASCII 'll'
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x18, 0x616E); // ASCII 'na'
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x19, 0x6767); // ASCII 'gg'
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x1A, 0x0000);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x1B, 0x2007);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x1C, 0x2007);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x1D, 0x0022);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x1E, 0x0004);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::UNITY::DATA>(UNITY_RESULTSET::CurrentWeek, 0x1F, 0x2007);
}

// Send relevant 0x044 packets for extended job information (BLU spells, Automaton, Monstrosity)
void SendExtendedJobPackets(CCharEntity* PChar)
{
    if (PChar->m_PMonstrosity)
    {
        PChar->pushPacket<GP_SERV_COMMAND_EXTENDED_JOB::MON>(PChar);
    }
    else
    {
        switch (PChar->GetMJob())
        {
            case JOB_PUP:
            {
                PChar->pushPacket<GP_SERV_COMMAND_EXTENDED_JOB::PUP>(PChar, true);
                break;
            }
            case JOB_BLU:
            {
                PChar->pushPacket<GP_SERV_COMMAND_EXTENDED_JOB::BLU>(PChar, true);
                break;
            }
            default:
                // TODO: Retail actually sends a packet in this case but content is unknown/unused
                break;
        }

        switch (PChar->GetSJob())
        {
            case JOB_PUP:
            {
                PChar->pushPacket<GP_SERV_COMMAND_EXTENDED_JOB::PUP>(PChar, false);
                break;
            }
            case JOB_BLU:
            {
                PChar->pushPacket<GP_SERV_COMMAND_EXTENDED_JOB::BLU>(PChar, false);
                break;
            }
            default:
                // TODO: Retail actually sends a packet in this case but content is unknown/unused
                break;
        }
    }
}

// Server sends a specific set of packets when certain player information change.
void SendLocalPlayerPackets(CCharEntity* PChar)
{
    PChar->pushPacket<GP_SERV_COMMAND_GROUP_ATTR>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_CLISTATUS>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_CLISTATUS2>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_ABIL_RECAST>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::MERITS>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::MONSTROSITY1>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::JOB_POINTS>(PChar);
}

/************************************************************************
 *                                                                       *
 *  Add a new item to the character in the selected container            *
 *                                                                       *
 ************************************************************************/

uint8 AddItem(CCharEntity* PChar, uint8 LocationID, uint16 ItemID, uint32 quantity, bool silence)
{
    if (PChar->getStorage(LocationID)->GetFreeSlotsCount() == 0 || quantity == 0)
    {
        return ERROR_SLOTID;
    }

    auto PItem = xi::items::spawn(ItemID);
    if (PItem == nullptr)
    {
        ShowWarning("AddItem: Item <%i> is not found in a database", ItemID);
        return ERROR_SLOTID;
    }

    PItem->setQuantity(quantity);
    return AddItem(PChar, LocationID, std::move(PItem), silence);
}

/************************************************************************
 *                                                                       *
 *  Add a new item to the character in the selected container            *
 *                                                                       *
 ************************************************************************/

auto AddItem(CCharEntity* PChar, uint8 LocationID, std::unique_ptr<CItem> PItem, bool silence) -> uint8
{
    if (PItem->isType(ITEM_CURRENCY))
    {
        UpdateItem(PChar, LocationID, 0, PItem->getQuantity());
        return 0;
    }

    if (PItem->hasFlag(ItemFlag::Rare) && HasItem(PChar, PItem->getID()))
    {
        if (!silence)
        {
            PChar->pushPacket<GP_SERV_COMMAND_MESSAGE>(PChar, PItem->getID(), 0, MsgStd::ItemEx);
        }
        return ERROR_SLOTID;
    }

    auto* PStorage = PChar->getStorage(LocationID);
    uint8 SlotID   = PStorage->InsertItem(std::move(PItem));
    if (SlotID == ERROR_SLOTID)
    {
        ShowDebug("AddItem: Location %i is full", LocationID);
        return SlotID;
    }

    auto* PInserted = PStorage->GetItem(SlotID);

    const char* Query = "INSERT INTO char_inventory("
                        "charid, "
                        "location, "
                        "slot, "
                        "itemId, "
                        "quantity, "
                        "signature, "
                        "extra) "
                        "VALUES(?, ?, ?, ?, ?, ?, ?) "
                        "LIMIT 1";

    if (!db::preparedStmt(Query, PChar->id, LocationID, SlotID, PInserted->getID(), PInserted->getQuantity(), PInserted->getSignature(), PInserted->m_extra))
    {
        ShowError("AddItem: Cannot insert item to database");
        PStorage->RemoveItem(SlotID);
        return ERROR_SLOTID;
    }

    PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PInserted, static_cast<CONTAINER_ID>(LocationID), SlotID);
    PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(PChar);

    return SlotID;
}

/************************************************************************
 *                                                                       *
 *  Check the availability of the item from the character                *
 *                                                                       *
 ************************************************************************/

bool HasItem(CCharEntity* PChar, uint16 ItemID)
{
    if (ItemID == 0)
    {
        return false;
    }
    for (uint8 LocID = 0; LocID < CONTAINER_ID::MAX_CONTAINER_ID; ++LocID)
    {
        if (PChar->getStorage(LocID)->SearchItem(ItemID) != ERROR_SLOTID)
        {
            return true;
        }
    }
    return false;
}

uint32 getItemCount(CCharEntity* PChar, uint16 ItemID)
{
    if (ItemID == 0)
    {
        return 0;
    }

    uint32 itemCount = 0;
    for (uint8 LocID = 0; LocID < CONTAINER_ID::MAX_CONTAINER_ID; ++LocID)
    {
        CItemContainer* PItemContainer = PChar->getStorage(LocID);
        // clang-format off
            PItemContainer->ForEachItem([&ItemID, &itemCount](CItem* PItem)
            {
                if (PItem->getID() == ItemID)
                {
                    itemCount += PItem->getQuantity();
                }
            });
        // clang-format on
    }

    return itemCount;
}

void UpdateSubJob(CCharEntity* PChar)
{
    jobpointutils::RefreshGiftMods(PChar);
    charutils::BuildingCharSkillsTable(PChar);
    charutils::CalculateStats(PChar);
    charutils::CheckValidEquipment(PChar);
    PChar->PRecastContainer->ChangeJob();
    charutils::BuildingCharAbilityTable(PChar);
    charutils::BuildingCharTraitsTable(PChar);

    PChar->UpdateHealth();
    PChar->health.hp = PChar->GetMaxHP();
    PChar->health.mp = PChar->GetMaxMP();

    charutils::SaveCharStats(PChar);
    charutils::SaveCharJob(PChar, PChar->GetMJob());
    charutils::SaveCharExp(PChar, PChar->GetMJob());
    PChar->updatemask |= UPDATE_HP;

    PChar->pushPacket<GP_SERV_COMMAND_JOB_INFO>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_CLISTATUS>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_CLISTATUS2>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_ABIL_RECAST>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_COMMAND_DATA>(PChar);
    PChar->pushPacket<CCharStatusPacket>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::MERITS>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::MONSTROSITY1>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_MISCDATA::MONSTROSITY2>(PChar);
    PChar->pushPacket<CCharSyncPacket>(PChar);
}

/************************************************************************
 *                                                                       *
 *  Move the object to the specified cells or the first empty            *
 *                                                                       *
 ************************************************************************/

uint8 MoveItem(CCharEntity* PChar, uint8 LocationID, uint8 SlotID, uint8 NewSlotID)
{
    CItemContainer* PItemContainer = PChar->getStorage(LocationID);

    if (PItemContainer->GetFreeSlotsCount() == 0)
    {
        ShowError("charutils::MoveItem: item can't be moved");
        return ERROR_SLOTID;
    }

    if (NewSlotID != ERROR_SLOTID && PItemContainer->GetItem(NewSlotID) != nullptr)
    {
        ShowError("charutils::MoveItem: item can't be moved");
        return ERROR_SLOTID;
    }

    auto PMoving = PItemContainer->RemoveItem(SlotID);
    if (PMoving == nullptr)
    {
        ShowError("charutils::MoveItem: item can't be moved");
        return ERROR_SLOTID;
    }

    NewSlotID = (NewSlotID == ERROR_SLOTID)
                    ? PItemContainer->InsertItem(std::move(PMoving))
                    : PItemContainer->InsertItem(std::move(PMoving), NewSlotID);

    if (NewSlotID == ERROR_SLOTID)
    {
        ShowError("charutils::MoveItem: item can't be moved");
        return ERROR_SLOTID;
    }

    const auto rset = db::preparedStmt("UPDATE char_inventory "
                                       "SET slot = ? "
                                       "WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
                                       NewSlotID,
                                       PChar->id,
                                       LocationID,
                                       SlotID);

    if (!rset || !rset->rowsAffected())
    {
        PItemContainer->MoveItemTo(NewSlotID, *PItemContainer, SlotID);
        ShowError("charutils::MoveItem: item can't be moved");
        return ERROR_SLOTID;
    }

    PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(nullptr, static_cast<CONTAINER_ID>(LocationID), SlotID, PItemContainer->GetItem(NewSlotID));
    PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PItemContainer->GetItem(NewSlotID), static_cast<CONTAINER_ID>(LocationID), NewSlotID);
    return NewSlotID;
}

/************************************************************************
 *                                                                       *
 *  Update the number of items in the specified container and slot       *
 *                                                                       *
 ************************************************************************/

uint32 UpdateItem(CCharEntity* PChar, uint8 LocationID, uint8 slotID, int32 quantity, bool force)
{
    CItem* PItem = PChar->getStorage(LocationID)->GetItem(slotID);

    if (PItem == nullptr)
    {
        ShowDebug("UpdateItem: No item in slot %u", slotID);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(nullptr, static_cast<CONTAINER_ID>(LocationID), slotID);
        return 0;
    }

    uint16 ItemID = PItem->getID();

if (quantity < 0)
    {
        if (static_cast<uint32>(-quantity) > PItem->getQuantity())
        {
            ShowDebug("UpdateItem: %s trying to remove invalid quantity %d of itemID %u", PChar->getName(), quantity, ItemID);
            return 0;
        }
    }
    else if (PItem->getQuantity() - PItem->getReserve() + quantity > PItem->getStackSize())
    {
        ShowDebug("UpdateItem: %s trying to add invalid quantity %d of itemID %u", PChar->getName(), quantity, ItemID);
        return 0;
    }

    auto* PState = dynamic_cast<CItemState*>(PChar->PAI->GetCurrentState());
    if (PState)
    {
        CItem* item = PState->GetItem();

        if (item && item->getSlotID() == PItem->getSlotID() && item->getLocationID() == PItem->getLocationID() && !force)
        {
            return 0;
        }
    }

    uint32 newQuantity = PItem->getQuantity() + quantity;

    if (newQuantity > PItem->getStackSize())
    {
        newQuantity = PItem->getStackSize();
    }

    if (newQuantity > 0 || PItem->isType(ITEM_CURRENCY))
    {
        db::preparedStmt("UPDATE char_inventory "
                         "SET quantity = ? "
                         "WHERE charid = ? AND location = ? AND slot = ?",
                         newQuantity,
                         PChar->id,
                         LocationID,
                         slotID);
        PItem->setQuantity(newQuantity);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_NUM>(static_cast<CONTAINER_ID>(LocationID), slotID, newQuantity);
    }
    else if (newQuantity == 0)
    {
        db::preparedStmt("DELETE FROM char_inventory "
                         "WHERE charid = ? AND location = ? AND slot = ?",
                         PChar->id,
                         LocationID,
                         slotID);
        // Hold the extracted item alive until end of scope
        auto PRemoved = PChar->getStorage(LocationID)->RemoveItem(slotID);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(nullptr, static_cast<CONTAINER_ID>(LocationID), slotID);

        if (PChar->getStyleLocked() && !HasItem(PChar, ItemID))
        {
            if (PItem->isType(ITEM_WEAPON))
            {
                if (PChar->styleItems[SLOT_MAIN] == ItemID)
                {
                    charutils::UpdateWeaponStyle(PChar, SLOT_MAIN, (CItemWeapon*)PChar->getEquip(SLOT_MAIN));
                }
                else if (PChar->styleItems[SLOT_SUB] == ItemID)
                {
                    charutils::UpdateWeaponStyle(PChar, SLOT_SUB, (CItemWeapon*)PChar->getEquip(SLOT_SUB));
                }
            }
            else if (PItem->isType(ITEM_EQUIPMENT))
            {
                auto equipSlotID = ((CItemEquipment*)PItem)->getSlotType();
                if (PChar->styleItems[equipSlotID] == ItemID)
                {
                    switch (equipSlotID)
                    {
                        case SLOT_HEAD:
                        case SLOT_BODY:
                        case SLOT_HANDS:
                        case SLOT_LEGS:
                        case SLOT_FEET:
                            charutils::UpdateArmorStyle(PChar, equipSlotID);
                            break;
                    }
                }
            }
        }
        luautils::OnItemDrop(PChar, PItem);
    }
    return ItemID;
}

// A wrapper around UpdateItem, with some packets
void DropItem(CCharEntity* PChar, uint8 container, uint8 slotID, int32 quantity, uint16 ItemID)
{
    if (charutils::UpdateItem(PChar, container, slotID, -quantity) != 0)
    {
        ShowInfo("Player %s DROPPING itemID: %s (%u) quantity: %u", PChar->getName(), xi::items::lookup(ItemID)->getName(), ItemID, quantity);
        PChar->pushPacket<GP_SERV_COMMAND_MESSAGE>(nullptr, ItemID, quantity, MsgStd::ThrowAway);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(PChar);
    }
}

/************************************************************************
 *                                                                       *
 *  Check the possibility of trade between characters                    *
 *                                                                       *
 ************************************************************************/

bool CanTrade(CCharEntity* PChar, CCharEntity* PTarget)
{
    if (PChar->m_PMonstrosity != nullptr || PTarget->m_PMonstrosity != nullptr)
    {
        return false;
    }

    if (PTarget->getStorage(LOC_INVENTORY)->GetFreeSlotsCount() < PChar->UContainer->GetItemsCount())
    {
        ShowDebug("Unable to trade, %s doesn't have enough inventory space", PTarget->getName());
        return false;
    }

    for (uint8 slotid = 0; slotid <= 8; ++slotid)
    {
        CItem* PItem = PChar->UContainer->GetItem(slotid);

        if (PItem != nullptr && PItem->hasFlag(ItemFlag::Rare))
        {
            if (HasItem(PTarget, PItem->getID()))
            {
                ShowDebug("Unable to trade, %s has the rare item already (%s)", PTarget->getName(), PItem->getName());
                return false;
            }
        }
    }

    return true;
}

/************************************************************************
 *                                                                       *
 *  Do the exchange between characters                                   *
 *                                                                       *
 ************************************************************************/

void DoTrade(CCharEntity* PChar, CCharEntity* PTarget)
{
    ShowDebug("%s->%s trade item movement started", PChar->getName(), PTarget->getName());
    for (uint8 slotid = 0; slotid <= 8; ++slotid)
    {
        CItem* PItem = PChar->UContainer->GetItem(slotid);

        if (PItem != nullptr)
        {
            if (PItem->getStackSize() == 1 && PItem->getReserve() == 1)
            {
                auto PNewItem = xi::items::clone(*PItem);
                ShowDebug("Adding %s to %s inventory stacksize 1", PNewItem->getName(), PTarget->getName());
                PNewItem->setReserve(0);
                AddItem(PTarget, LOC_INVENTORY, std::move(PNewItem));
            }
            else
            {
                ShowDebug("Adding %s to %s inventory", PItem->getName(), PTarget->getName());
                AddItem(PTarget, LOC_INVENTORY, PItem->getID(), PItem->getReserve());
            }
            ShowDebug("Removing %s from %s's inventory", PItem->getName(), PChar->getName());
            auto amount = PItem->getReserve();
            PItem->setReserve(0);
            UpdateItem(PChar, LOC_INVENTORY, PItem->getSlotID(), (int32)(0 - amount));
            PChar->UContainer->ClearSlot(slotid);
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Remove equipped item from character without updating the external    *
 *  species (used as an auxiliary function in a bundle with others)      *
 *                                                                       *
 ************************************************************************/

void UnequipItem(CCharEntity* PChar, uint8 equipSlotID, Recalculate recalculate)
{
    if (PChar == nullptr)
    {
        ShowWarning("PChar was null.");
        return;
    }

    if (equipSlotID > 15)
    {
        ShowWarning("Invalid slot ID. Must be between 0 and 15.");
        return;
    }

    CItem* PItem = PChar->getEquip((SLOTTYPE)equipSlotID);

    if ((PItem != nullptr) && PItem->isType(ITEM_EQUIPMENT))
    {
        // if removeSlotLookID is available it should be prioritized as it will encompass a larger set of slots
        auto removeSlotLookID = ((CItemEquipment*)PItem)->getRemoveSlotLookId();
        auto removeSlotID     = removeSlotLookID > 0 ? removeSlotLookID : ((CItemEquipment*)PItem)->getRemoveSlotId();

        // When unequipping an item, revert all associated look slots to either default or the item which is equipped
        for (auto i = 0u; i < sizeof(removeSlotID) * 8; ++i)
        {
            if (removeSlotID & (1 << i))
            {
                if (i >= SLOT_HEAD && i <= SLOT_FEET)
                {
                    int             itemLook     = 0;
                    CItemEquipment* equippedItem = PChar->getEquip((SLOTTYPE)i);
                    if (equippedItem)
                    {
                        itemLook = equippedItem->getModelId();
                    }

                    switch (i)
                    {
                        case SLOT_HEAD:
                            PChar->look.head = itemLook;
                            break;
                        case SLOT_BODY:
                            PChar->look.body = itemLook;
                            break;
                        case SLOT_HANDS:
                            PChar->look.hands = itemLook;
                            break;
                        case SLOT_LEGS:
                            PChar->look.legs = itemLook;
                            break;
                        case SLOT_FEET:
                            PChar->look.feet = itemLook;
                            break;
                    }
                }
            }
        }

        // Call the LUA event before actually "unequipping" the item so the script can do stuff with it first
        if (((CItemEquipment*)PItem)->getScriptType() & SCRIPT_EQUIP || ((CItemEquipment*)PItem)->isType(ITEM_USABLE))
        {
            luautils::OnItemCheck(PChar, PItem, ITEMCHECK::UNEQUIP, nullptr);
        }

        // todo: issues as item 0 reference is being handled as a real equipment piece
        //      thought to be source of nin bug
        PChar->clearEquip(equipSlotID);

        if (((CItemEquipment*)PItem)->getScriptType() & SCRIPT_EQUIP)
        {
            PChar->m_EquipFlag = 0;
            for (uint8 i = 0; i < 16; ++i)
            {
                CItem* PSlotItem = PChar->getEquip(static_cast<SLOTTYPE>(i));

                if ((PSlotItem != nullptr) && PSlotItem->isType(ITEM_EQUIPMENT))
                {
                    PChar->m_EquipFlag |= (static_cast<CItemEquipment*>(PSlotItem))->getScriptType();
                }
            }
        }

        if (PItem->isSubType(ITEM_CHARGED))
        {
            PChar->PRecastContainer->Del(RECAST_ITEM, static_cast<Recast>(PItem->getSlotID() << 8 | PItem->getLocationID())); // Also remove item from the Recast List no matter what bag its in
        }
        PItem->setSubType(ITEM_UNLOCKED);

        if (equipSlotID == SLOT_SUB)
        {
            // Removed sub item, if main hand is empty, then possibly eligible for H2H weapon
            if (!PChar->getEquip(SLOT_MAIN) || !PChar->getEquip(SLOT_MAIN)->isType(ITEM_EQUIPMENT))
            {
                CheckUnarmedWeapon(PChar);
            }
            PChar->m_dualWield = false;
        }
        PChar->delEquipModifiers(&((CItemEquipment*)PItem)->modList, ((CItemEquipment*)PItem)->getReqLvl(), equipSlotID);
        PChar->PLatentEffectContainer->DelLatentEffects(((CItemEquipment*)PItem)->getReqLvl(), equipSlotID);
        PChar->delPetModifiers(&((CItemEquipment*)PItem)->petModList);

        switch (equipSlotID)
        {
            case SLOT_HEAD:
                PChar->look.head = 0;
                break;
            case SLOT_BODY:
                PChar->look.body = 0;
                break;
            case SLOT_HANDS:
                PChar->look.hands = 0;
                break;
            case SLOT_LEGS:
                PChar->look.legs = 0;
                break;
            case SLOT_FEET:
                PChar->look.feet = 0;
                break;
            case SLOT_SUB:
            {
                PChar->look.sub            = 0;
                PChar->m_Weapons[SLOT_SUB] = xi::items::unarmed(); // << equips "nothing" in the sub slot to prevent multi attack exploit
                PChar->health.tp           = 0;
                PChar->StatusEffectContainer->DelStatusEffect(EFFECT_AFTERMATH);
                BuildingCharWeaponSkills(PChar);
                UpdateWeaponStyle(PChar, equipSlotID, nullptr);
            }
            break;
            case SLOT_AMMO:
            {
                if (!PChar->getEquip(SLOT_RANGED))
                {
                    PChar->look.ranged = 0;
                }
                PChar->m_Weapons[SLOT_AMMO] = nullptr;
                UpdateWeaponStyle(PChar, equipSlotID, nullptr);
            }
            break;
            case SLOT_RANGED:
            {
                if (!PChar->getEquip(SLOT_RANGED))
                {
                    PChar->look.ranged = 0;
                }
                PChar->m_Weapons[SLOT_RANGED] = nullptr;
                if (((CItemWeapon*)PItem)->getSkillType() != SKILL_STRING_INSTRUMENT && ((CItemWeapon*)PItem)->getSkillType() != SKILL_WIND_INSTRUMENT)
                {
                    PChar->health.tp = 0;
                    PChar->StatusEffectContainer->DelStatusEffect(EFFECT_AFTERMATH);
                }
                BuildingCharWeaponSkills(PChar);
                UpdateWeaponStyle(PChar, equipSlotID, nullptr);
            }
            break;
            case SLOT_MAIN:
            {
                if (PItem->isType(ITEM_WEAPON))
                {
                    CItemEquipment* PSub = PChar->getEquip(SLOT_SUB);

                    if (static_cast<CItemWeapon*>(PItem)->getSkillType() == SKILL_HAND_TO_HAND)
                    {
                        PChar->look.sub = 0;
                    }
                    else if (!PSub)
                    {
                        PChar->look.sub = 0;
                    }
                }

                if (PChar->PAI->IsEngaged())
                {
                    auto* state = dynamic_cast<CAttackState*>(PChar->PAI->GetCurrentState());
                    if (state)
                    {
                        state->ResetAttackTimer();
                    }
                }

                // If main hand is empty, figure out which UnarmedItem to give the player.
                if (!PChar->getEquip(SLOT_MAIN) || !PChar->getEquip(SLOT_MAIN)->isType(ITEM_EQUIPMENT))
                {
                    CheckUnarmedWeapon(PChar);
                }

                PChar->health.tp = 0;
                PChar->StatusEffectContainer->DelStatusEffect(EFFECT_AFTERMATH);
                BuildingCharWeaponSkills(PChar);
                UpdateWeaponStyle(PChar, equipSlotID, nullptr);
            }
            break;
        }

        luautils::OnItemUnequip(PChar, PItem);

        PChar->inventorySyncState().queueEquipChange(LOC_INVENTORY, 0, static_cast<SLOTTYPE>(equipSlotID), PItem, Equipping::No);

        if (recalculate)
        {
            charutils::BuildingCharSkillsTable(PChar);
            PChar->UpdateHealth();
            PChar->updatemask |= UPDATE_HP;
            PChar->updatemask |= UPDATE_LOOK;
        }
    }
}

bool hasSlotEquipped(CCharEntity* PChar, uint8 equipSlotID)
{
    CItem* PItem = PChar->getEquip((SLOTTYPE)equipSlotID);
    return PItem != nullptr && PItem->isType(ITEM_EQUIPMENT);
}

void RemoveSub(CCharEntity* PChar)
{
    CItemEquipment* PItem = PChar->getEquip(SLOT_SUB);

    if (PItem != nullptr && PItem->isType(ITEM_EQUIPMENT))
    {
        UnequipItem(PChar, SLOT_SUB);
    }
}

/************************************************************************
 *                                                                       *
 *  Try to equip the subject in compliance with all conditions           *
 *                                                                       *
 ************************************************************************/

bool EquipArmor(CCharEntity* PChar, uint8 slotID, uint8 equipSlotID, uint8 containerID)
{
    CItemEquipment* PItem   = dynamic_cast<CItemEquipment*>(PChar->getStorage(containerID)->GetItem(slotID));
    CItemEquipment* oldItem = PChar->getEquip((SLOTTYPE)equipSlotID);

    if (PItem == nullptr)
    {
        ShowDebug("No item in inventory slot %u", slotID);
        return false;
    }

    if ((PChar->m_EquipBlock & (1 << equipSlotID)) || !(PItem->getJobs() & (1 << (PChar->GetMJob() - 1))) ||
        (PItem->getSuperiorLevel() > PChar->getMod(Mod::SUPERIOR_LEVEL)) ||
        (PItem->getReqLvl() > (settings::get<bool>("map.DISABLE_GEAR_SCALING") ? PChar->GetMLevel() : PChar->jobs.job[PChar->GetMJob()])) ||
        !PItem->isEquippableByRace(PChar->look.race))
    {
        return false;
    }

    if (equipSlotID == SLOT_MAIN)
    {
        if (!(slotID == PItem->getSlotID() && oldItem && (oldItem->isType(ITEM_WEAPON) && PItem->isType(ITEM_WEAPON)) &&
              (static_cast<CItemWeapon*>(PItem)->isTwoHanded() && static_cast<CItemWeapon*>(oldItem)->isTwoHanded())))
        {
            CItemEquipment* PSubItem = PChar->getEquip(SLOT_SUB);

            if (PSubItem != nullptr && PSubItem->isType(ITEM_EQUIPMENT) && (!PSubItem->IsShield()))
            {
                RemoveSub(PChar);
            }
        }
    }

    UnequipItem(PChar, equipSlotID, Recalculate::No);

    // When equipping PItem - Remove all equip in slots which are also restricted by PItem
    // e.g. Equipping a Black Cloak should remove head equipment
    if (PItem->getEquipSlotId() & (1 << equipSlotID))
    {
        auto removeSlotID = PItem->getRemoveSlotId();

        for (auto i = 0u; i < sizeof(removeSlotID) * 8; ++i)
        {
            if (removeSlotID & (1 << i))
            {
                UnequipItem(PChar, i, Recalculate::No);
                if (i >= SLOT_HEAD && i <= SLOT_FEET)
                {
                    switch (i)
                    {
                        case SLOT_HEAD:
                            PChar->look.head = PItem->getModelId();
                            break;
                        case SLOT_BODY:
                            PChar->look.body = PItem->getModelId();
                            break;
                        case SLOT_HANDS:
                            PChar->look.hands = PItem->getModelId();
                            break;
                        case SLOT_LEGS:
                            PChar->look.legs = PItem->getModelId();
                            break;
                        case SLOT_FEET:
                            PChar->look.feet = PItem->getModelId();
                            break;
                    }
                }
            }
        }

        // When equipping PItem into a slot - Remove equip in other slots which may have restricted equip in this slot
        // e.g. Equipping head equipment should result in the removal of an equipped Black Cloak
        for (uint8 i = 0; i < SLOT_BACK; ++i)
        {
            CItemEquipment* armor = PChar->getEquip((SLOTTYPE)i);
            if (armor && armor->isType(ITEM_EQUIPMENT) && armor->getRemoveSlotId() & PItem->getEquipSlotId())
            {
                UnequipItem(PChar, i, Recalculate::No);
            }
        }

        switch (equipSlotID)
        {
            case SLOT_MAIN:
            {
                if (PItem->isType(ITEM_WEAPON))
                {
                    switch (static_cast<CItemWeapon*>(PItem)->getSkillType())
                    {
                        case SKILL_HAND_TO_HAND:
                        case SKILL_GREAT_SWORD:
                        case SKILL_GREAT_AXE:
                        case SKILL_SCYTHE:
                        case SKILL_POLEARM:
                        case SKILL_GREAT_KATANA:
                        case SKILL_STAFF:
                        {
                            CItemEquipment* sub = PChar->getEquip(SLOT_SUB);
                            if (sub != nullptr && sub->isType(ITEM_EQUIPMENT))
                            {
                                if (sub->isType(ITEM_WEAPON))
                                {
                                    CItemWeapon* PWeapon = static_cast<CItemWeapon*>(sub);
                                    if (PWeapon->getSkillType() != SKILL_NONE || static_cast<CItemWeapon*>(PItem)->getSkillType() == SKILL_HAND_TO_HAND)
                                    {
                                        UnequipItem(PChar, SLOT_SUB, Recalculate::No);
                                    }
                                }
                                else
                                {
                                    UnequipItem(PChar, SLOT_SUB, Recalculate::No);
                                }
                            }
                            if (static_cast<CItemWeapon*>(PItem)->getSkillType() == SKILL_HAND_TO_HAND)
                            {
                                PChar->look.sub = PItem->getModelId() + 0x1000;
                            }
                        }
                        break;
                    }
                    if (PChar->PAI->IsEngaged())
                    {
                        auto* state = dynamic_cast<CAttackState*>(PChar->PAI->GetCurrentState());
                        if (state)
                        {
                            state->ResetAttackTimer();
                        }
                    }
                    PChar->m_Weapons[SLOT_MAIN] = PItem;
                }
                PChar->look.main = PItem->getModelId();
                UpdateWeaponStyle(PChar, equipSlotID, (CItemWeapon*)PItem);
            }
            break;
            case SLOT_SUB:
            {
                CItemWeapon* weapon = dynamic_cast<CItemWeapon*>(PChar->getEquip(SLOT_MAIN));
                // NULL weapon can be unarmed weapon that just got unequipped
                if (!weapon)
                {
                    if (PItem->IsShield())
                    {
                        PChar->look.sub = PItem->getModelId();
                        UpdateWeaponStyle(PChar, equipSlotID, PItem);
                        break;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    switch (weapon->getSkillType())
                    {
                        case SKILL_HAND_TO_HAND:
                        {
                            if (!PItem->isType(ITEM_WEAPON))
                            {
                                UnequipItem(PChar, SLOT_MAIN, Recalculate::No);
                            }
                            break;
                        }
                        case SKILL_DAGGER:
                        case SKILL_SWORD:
                        case SKILL_AXE:
                        case SKILL_KATANA:
                        case SKILL_CLUB:
                        {
                            CItemWeapon* PNewItemWeapon = dynamic_cast<CItemWeapon*>(PItem);
                            bool         isWeapon       = PItem->isType(ITEM_WEAPON);

                            if (isWeapon && (!charutils::hasTrait(PChar, TRAIT_DUAL_WIELD) || (PNewItemWeapon && PNewItemWeapon->getSkillType() == SKILL_NONE)))
                            {
                                return false;
                            }
                            PChar->m_Weapons[SLOT_SUB] = PItem;
                            // only set m_dualWield if equipping a weapon (not for example a shield)
                            if (isWeapon)
                            {
                                PChar->m_dualWield = true;
                            }
                        }
                        break;
                        default:
                        {
                            if (!PItem->isType(ITEM_WEAPON))
                            {
                                UnequipItem(PChar, SLOT_MAIN, Recalculate::No);
                            }
                            else if (static_cast<CItemWeapon*>(PItem)->getSkillType() != SKILL_NONE)
                            {
                                // allow Grips to be equipped
                                return false;
                            }
                        }
                    }
                }
                PChar->look.sub = PItem->getModelId();
                UpdateWeaponStyle(PChar, equipSlotID, PItem);
            }
            break;
            case SLOT_RANGED:
            {
                if (PItem->isType(ITEM_WEAPON))
                {
                    CItemWeapon* weapon = dynamic_cast<CItemWeapon*>(PChar->getEquip(SLOT_AMMO));
                    if (weapon)
                    {
                        // If the subtype of the ranged weapon is not compatible with the ammo, unequip it, except for Archery where Longbow and Shortbow both use arrows
                        if (static_cast<CItemWeapon*>(PItem)->getSkillType() != weapon->getSkillType() ||
                            (weapon->getSkillType() != SKILL_ARCHERY && static_cast<CItemWeapon*>(PItem)->getSubSkillType() != weapon->getSubSkillType()))
                        {
                            UnequipItem(PChar, SLOT_AMMO, Recalculate::No);
                        }
                    }
                    PChar->m_Weapons[SLOT_RANGED] = PItem;
                }
                PChar->look.ranged = PItem->getModelId();
                UpdateWeaponStyle(PChar, equipSlotID, PItem);
            }
            break;
            case SLOT_AMMO:
            {
                if (PItem->isType(ITEM_WEAPON))
                {
                    CItemWeapon* weapon = dynamic_cast<CItemWeapon*>(PChar->getEquip(SLOT_RANGED));
                    if (weapon)
                    {
                        // If the subtype of the ammo is not compatible with the ranged weapon, unequip it, except for Archery where Longbow and Shortbow both use arrows
                        if (static_cast<CItemWeapon*>(PItem)->getSkillType() != weapon->getSkillType() ||
                            (weapon->getSkillType() != SKILL_ARCHERY && static_cast<CItemWeapon*>(PItem)->getSubSkillType() != weapon->getSubSkillType()))
                        {
                            UnequipItem(PChar, SLOT_RANGED, Recalculate::No);
                        }
                    }
                    if (!PChar->getEquip(SLOT_RANGED))
                    {
                        PChar->look.ranged = PItem->getModelId();
                    }
                    PChar->m_Weapons[SLOT_AMMO] = PItem;
                    UpdateWeaponStyle(PChar, equipSlotID, PItem);
                }
            }
            break;
            case SLOT_HEAD:
            {
                PChar->look.head = PItem->getModelId();
            }
            break;
            case SLOT_BODY:
            {
                PChar->look.body = PItem->getModelId();
            }
            break;
            case SLOT_HANDS:
            {
                PChar->look.hands = PItem->getModelId();
            }
            break;
            case SLOT_LEGS:
            {
                PChar->look.legs = PItem->getModelId();
            }
            break;
            case SLOT_FEET:
            {
                PChar->look.feet = PItem->getModelId();
            }
            break;
        }

        if (!PChar->bindEquip(equipSlotID, PItem))
        {
            return false;
        }

        // Changed visible equipment
        if (equipSlotID >= SLOT_HEAD && equipSlotID <= SLOT_FEET)
        {
            UpdateRemovedSlotsLook(PChar);
        }
    }
    else
    {
        ShowWarning("Item %i is not equipable in equip slot %i", PItem->getID(), equipSlotID);
        return false;
    }
    return true;
}

auto canEquipItemOnAnyJob(CCharEntity* PChar, const CItemEquipment* PItem) -> bool
{
    if (PItem == nullptr)
    {
        return true;
    }

    for (uint8 i = 1; i < MAX_JOBTYPE; i++)
    {
        if (PItem->getJobs() & (1 << (i - 1)) && PItem->getReqLvl() <= PChar->jobs.job[i])
        {
            // TODO: Check for Su level for the player's job, and apply to the condition.
            return true;
        }
    }
    return false;
}

auto hasValidStyle(CCharEntity* PChar, const CItemEquipment* PItem, const CItemEquipment* AItem) -> bool
{
    if (AItem && PItem)
    {
        // Shield special case
        if (AItem->IsShield() && PItem->IsShield())
        {
            return HasItem(PChar, AItem->getID()) && canEquipItemOnAnyJob(PChar, AItem);
        }

        const auto* PWeapon = dynamic_cast<const CItemWeapon*>(PItem);
        const auto* AWeapon = dynamic_cast<const CItemWeapon*>(AItem);

        // Marvelous Cheer special case
        // It is not technically a Wind Instrument, but it can lockstyle one.
        if (PWeapon && AItem->getID() == MARVELOUS_CHEER && PWeapon->getSkillType() == SKILL_WIND_INSTRUMENT)
        {
            return HasItem(PChar, AItem->getID());
        }

        if (PWeapon && AWeapon && PWeapon->getSkillType() == AWeapon->getSkillType())
        {
            return HasItem(PChar, AItem->getID()) && canEquipItemOnAnyJob(PChar, AItem);
        }
    }
    return false;
}

void SetStyleLock(CCharEntity* PChar, bool isStyleLocked)
{
    if (isStyleLocked)
    {
        for (uint8 i = 0; i < SLOT_LINK1; i++)
        {
            auto* PItem          = PChar->getEquip((SLOTTYPE)i);
            PChar->styleItems[i] = (PItem == nullptr) ? 0 : PItem->getID();
        }
        std::memcpy(&PChar->mainlook, &PChar->look, sizeof(PChar->look));
    }
    else
    {
        for (unsigned short& styleItem : PChar->styleItems)
        {
            styleItem = 0;
        }
    }

    if (PChar->getStyleLocked() != isStyleLocked)
    {
        PChar->pushPacket<GP_SERV_COMMAND_MESSAGE>(isStyleLocked ? MsgStd::StyleLockOn : MsgStd::StyleLockOff);
    }
    PChar->setStyleLocked(isStyleLocked);
}

void UpdateWeaponStyle(CCharEntity* PChar, uint8 equipSlotID, CItemEquipment* PItem)
{
    if (!PChar->getStyleLocked())
    {
        return;
    }

    const CItemEquipment* appearance      = xi::items::lookup<CItemEquipment>(PChar->styleItems[equipSlotID]);
    uint16                appearanceModel = 0;
    if (appearance)
    {
        appearanceModel = appearance->getModelId();
    }

    switch (equipSlotID)
    {
        case SLOT_MAIN:
            if (hasValidStyle(PChar, PItem, appearance))
            {
                PChar->mainlook.main = appearanceModel;
            }
            else
            {
                PChar->mainlook.main = PChar->look.main;
            }

            if (PItem == nullptr)
            {
                PChar->mainlook.sub = PChar->look.sub;
            }
            else
            {
                CItemWeapon* PWeapon = dynamic_cast<CItemWeapon*>(PItem);
                if (PWeapon)
                {
                    switch (PWeapon->getSkillType())
                    {
                        case SKILL_HAND_TO_HAND:
                            PChar->mainlook.sub = appearanceModel + 0x1000;
                            break;
                        case SKILL_GREAT_SWORD:
                        case SKILL_GREAT_AXE:
                        case SKILL_SCYTHE:
                        case SKILL_POLEARM:
                        case SKILL_GREAT_KATANA:
                        case SKILL_STAFF:
                            PChar->mainlook.sub = PChar->look.sub;
                            break;
                    }
                }
            }
            break;
        case SLOT_SUB:
            if (hasValidStyle(PChar, PItem, appearance))
            {
                PChar->mainlook.sub = appearanceModel;
            }
            else
            {
                PChar->mainlook.sub = PChar->look.sub;
            }
            break;
        case SLOT_RANGED:
            if (hasValidStyle(PChar, PItem, appearance))
            {
                PChar->mainlook.ranged = appearanceModel;
            }
            else
            {
                PChar->mainlook.ranged = PChar->look.ranged;
            }

            break;
        default:
            break;
    }
}

void UpdateArmorStyle(CCharEntity* PChar, uint8 equipSlotID)
{
    if (!PChar->getStyleLocked())
    {
        return;
    }

    uint16                itemID          = PChar->styleItems[equipSlotID];
    const CItemEquipment* appearance      = xi::items::lookup<CItemEquipment>(itemID);
    uint16                appearanceModel = 0;

    if (appearance && HasItem(PChar, itemID))
    {
        appearanceModel = appearance->getModelId();
    }

    if (!canEquipItemOnAnyJob(PChar, appearance))
    {
        return;
    }

    switch (equipSlotID)
    {
        case SLOT_HEAD:
            PChar->mainlook.head = appearanceModel;
            break;
        case SLOT_BODY:
            PChar->mainlook.body = appearanceModel;
            break;
        case SLOT_HANDS:
            PChar->mainlook.hands = appearanceModel;
            break;
        case SLOT_LEGS:
            PChar->mainlook.legs = appearanceModel;
            break;
        case SLOT_FEET:
            PChar->mainlook.feet = appearanceModel;
            break;
    }
}

/// <summary>
/// Updates the Char's lockstyle look to account for gear that occupies multiple slots
/// This includes items like Black Cloak which restricts the equip AND look of headgear.
/// This also incluses items like Onca Suit which restricts equip and look of legs, but only look of hands and feet.
/// </summary>
/// <param name="PChar">Character to have Lockstyle look updated</param>
void UpdateRemovedSlotsLookForLockStyle(CCharEntity* PChar)
{
    if (!PChar || !PChar->getStyleLocked())
    {
        return;
    }

    auto items = PChar->styleItems;
    for (auto i = 0; i < 16; i++)
    {
        if (items[i] == 0)
        {
            continue;
        }

        const auto* PItem = xi::items::lookup<CItemEquipment>(items[i]);
        if (!PItem)
        {
            continue;
        }

        auto removeSlotID = PItem->getRemoveSlotLookId();
        // Some of the items don't have rslotlook set so we fall back on rslot to know which part to hide
        if (removeSlotID == 0)
        {
            removeSlotID = PItem->getRemoveSlotId();
        }
        if (removeSlotID > 0)
        {
            for (auto i = 4u; i <= 8u; i++)
            {
                if (removeSlotID & (1 << i))
                {
                    switch (i)
                    {
                        case SLOT_HEAD:
                            PChar->mainlook.head = PItem->getModelId();
                            break;
                        case SLOT_BODY:
                            PChar->mainlook.body = PItem->getModelId();
                            break;
                        case SLOT_HANDS:
                            PChar->mainlook.hands = PItem->getModelId();
                            break;
                        case SLOT_LEGS:
                            PChar->mainlook.legs = PItem->getModelId();
                            break;
                        case SLOT_FEET:
                            PChar->mainlook.feet = PItem->getModelId();
                            break;
                    }
                }
            }
        }
    }
}

/// <summary>
/// Updates the Char's look to account for gear that occupies multiple slots
/// This includes items like Black Cloak which restricts the equip AND look of headgear.
/// This also incluses items like Onca Suit which restricts equip and look of legs, but only look of hands and feet.
/// </summary>
/// <param name="PChar">Character to have look updated</param>
void UpdateRemovedSlotsLook(CCharEntity* PChar)
{
    if (!PChar)
    {
        return;
    }

    for (int i = SLOT_HEAD; i < SLOT_FEET; i++)
    {
        CItemEquipment* armor = PChar->getEquip((SLOTTYPE)i);
        if (armor && armor->isType(ITEM_EQUIPMENT) && armor->getRemoveSlotLookId())
        {
            auto removeSlotID = armor->getRemoveSlotLookId();
            for (int j = SLOT_HEAD; j <= SLOT_FEET; j++)
            {
                if (removeSlotID & (1 << j))
                {
                    switch (j)
                    {
                        case SLOT_HEAD:
                            PChar->look.head = armor->getModelId();
                            break;
                        case SLOT_BODY:
                            PChar->look.body = armor->getModelId();
                            break;
                        case SLOT_HANDS:
                            PChar->look.hands = armor->getModelId();
                            break;
                        case SLOT_LEGS:
                            PChar->look.legs = armor->getModelId();
                            break;
                        case SLOT_FEET:
                            PChar->look.feet = armor->getModelId();
                            break;
                    }
                }
            }
        }
    }
}

void AddItemToRecycleBin(CCharEntity* PChar, uint32 container, uint8 slotID, uint8 quantity)
{
    auto* RecycleBin     = PChar->getStorage(LOC_RECYCLEBIN);
    auto* OtherContainer = PChar->getStorage(container);

    auto* PSrcItem = OtherContainer->GetItem(slotID);
    if (PSrcItem == nullptr)
    {
        return;
    }

    const uint16 itemID   = PSrcItem->getID();
    const auto   itemName = PSrcItem->getName();

    if (RecycleBin->GetFreeSlotsCount() > 0)
    {
        const uint8 NewSlotID = OtherContainer->MoveItemTo(slotID, *RecycleBin);
        if (NewSlotID == ERROR_SLOTID)
        {
            return;
        }

        const auto rset = db::preparedStmt("UPDATE char_inventory SET location = ?, slot = ? WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
                                           LOC_RECYCLEBIN,
                                           NewSlotID,
                                           PChar->id,
                                           container,
                                           slotID);
        if (!rset || !rset->rowsAffected())
        {
            RecycleBin->MoveItemTo(NewSlotID, *OtherContainer, slotID);
            return;
        }

        auto* PInserted = RecycleBin->GetItem(NewSlotID);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(nullptr, static_cast<CONTAINER_ID>(container), slotID);
        PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PInserted, LOC_RECYCLEBIN, NewSlotID);
        PChar->pushPacket<GP_SERV_COMMAND_MESSAGE>(nullptr, itemID, quantity, MsgStd::ThrowAway);
        luautils::OnItemDrop(PChar, PInserted, IsRecycleBin::Yes);
    }
    else // Bin is full
    {
        // Evict recycle bin slot 1
        auto PEvictedItem = RecycleBin->RemoveItem(1);
        db::preparedStmt("DELETE FROM char_inventory WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
                         PChar->id,
                         LOC_RECYCLEBIN,
                         1);

        if (PEvictedItem)
        {
            luautils::OnItemDrop(PChar, PEvictedItem.get());
        }

        // Slide slots 2..10 down to 1..9
        for (int i = 2; i <= 10; ++i)
        {
            if (RecycleBin->GetItem(i) == nullptr)
            {
                continue;
            }
            RecycleBin->MoveItemTo(i, *RecycleBin, i - 1);

            const auto rset = db::preparedStmt("UPDATE char_inventory SET location = ?, slot = ? WHERE charid = ? AND location = ? AND slot = ? LIMIT 1", LOC_RECYCLEBIN, i - 1, PChar->id, LOC_RECYCLEBIN, i);
            if (!rset || !rset->rowsAffected())
            {
                ShowError("Problem moving Recycle Bin items! (%s - %s)", PChar->getName(), itemName);
            }
        }

        // Move new item from source container into freed slot 10
        OtherContainer->MoveItemTo(slotID, *RecycleBin, 10);
        auto* PInserted = RecycleBin->GetItem(10);

        const auto rset = db::preparedStmt("UPDATE char_inventory SET location = ?, slot = ? WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
                                           LOC_RECYCLEBIN,
                                           10,
                                           PChar->id,
                                           container,
                                           slotID);
        if (!rset || !rset->rowsAffected())
        {
            ShowError("Problem moving Recycle Bin items! (%s - %s)", PChar->getName(), itemName);
        }

        PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(nullptr, static_cast<CONTAINER_ID>(container), slotID);
        for (int i = 1; i <= 10; ++i)
        {
            CItem* PUpdatedItem = RecycleBin->GetItem(i);
            PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PUpdatedItem, LOC_RECYCLEBIN, i);
        }
        PChar->pushPacket<GP_SERV_COMMAND_MESSAGE>(nullptr, itemID, quantity, MsgStd::ThrowAway);
        luautils::OnItemDrop(PChar, PInserted, IsRecycleBin::Yes);
    }
    PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(PChar);
}

void EmptyRecycleBin(CCharEntity* PChar)
{
    TracyZoneScoped;

    CItemContainer* recycleBin = PChar->getStorage(LOC_RECYCLEBIN);

    for (uint8 slotID = 1; slotID <= recycleBin->GetSize(); ++slotID)
    {
        if (CItem* PItem = recycleBin->GetItem(slotID))
        {
            luautils::OnItemDrop(PChar, PItem);
        }
    }

    db::preparedStmt("DELETE FROM char_inventory WHERE charid = ? AND location = 17", PChar->id);
    recycleBin->Clear();
}

void SaveJobChangeGear(CCharEntity* PChar)
{
    if (PChar == nullptr)
    {
        return;
    }

    auto getEquipIdFromSlot = [](CCharEntity* PChar, SLOTTYPE slot) -> uint16
    {
        return (PChar->getEquip(slot) != nullptr) ? PChar->getEquip(slot)->getID() : 0;
    };

    uint16 main   = getEquipIdFromSlot(PChar, SLOT_MAIN);
    uint16 sub    = getEquipIdFromSlot(PChar, SLOT_SUB);
    uint16 ranged = getEquipIdFromSlot(PChar, SLOT_RANGED);
    uint16 ammo   = getEquipIdFromSlot(PChar, SLOT_AMMO);
    uint16 head   = getEquipIdFromSlot(PChar, SLOT_HEAD);
    uint16 body   = getEquipIdFromSlot(PChar, SLOT_BODY);
    uint16 hands  = getEquipIdFromSlot(PChar, SLOT_HANDS);
    uint16 legs   = getEquipIdFromSlot(PChar, SLOT_LEGS);
    uint16 feet   = getEquipIdFromSlot(PChar, SLOT_FEET);
    uint16 neck   = getEquipIdFromSlot(PChar, SLOT_NECK);
    uint16 waist  = getEquipIdFromSlot(PChar, SLOT_WAIST);
    uint16 ear1   = getEquipIdFromSlot(PChar, SLOT_EAR1);
    uint16 ear2   = getEquipIdFromSlot(PChar, SLOT_EAR2);
    uint16 ring1  = getEquipIdFromSlot(PChar, SLOT_RING1);
    uint16 ring2  = getEquipIdFromSlot(PChar, SLOT_RING2);
    uint16 back   = getEquipIdFromSlot(PChar, SLOT_BACK);

    db::preparedStmt("REPLACE INTO char_equip_saved SET "
                     "charid = ?, jobid = ?, main = ?, sub = ?, "
                     "ranged = ?, ammo = ?, head = ?, body = ?, "
                     "hands = ?, legs = ?, feet = ?, neck = ?, "
                     "waist = ?, ear1 = ?, ear2 = ?, ring1 = ?, "
                     "ring2 = ?, back = ?",
                     PChar->id,
                     PChar->GetMJob(),
                     main,
                     sub,
                     ranged,
                     ammo,
                     head,
                     body,
                     hands,
                     legs,
                     feet,
                     neck,
                     waist,
                     ear1,
                     ear2,
                     ring1,
                     ring2,
                     back);
}

void LoadJobChangeGear(CCharEntity* PChar)
{
    if (PChar == nullptr)
    {
        return;
    }

    const auto rset = db::preparedStmt("SELECT main, sub, ranged, ammo, head, body, hands, legs, feet, neck, waist, ear1, ear2, ring1, ring2, back "
                                       "FROM char_equip_saved AS equip "
                                       "WHERE charid = ? AND jobid = ? LIMIT 1",
                                       PChar->id,
                                       PChar->GetMJob());
    FOR_DB_SINGLE_RESULT(rset)
    {
        const std::vector<uint8> validContainers = { LOC_INVENTORY, LOC_WARDROBE, LOC_WARDROBE2, LOC_WARDROBE3, LOC_WARDROBE4, LOC_WARDROBE5, LOC_WARDROBE6, LOC_WARDROBE7, LOC_WARDROBE8 };

        for (uint8 equipSlot = SLOT_MAIN; equipSlot <= SLOT_BACK; equipSlot++)
        {
            const auto itemId = rset->get<uint16>(equipSlot);

            if (itemId > 0)
            {
                for (const auto container : validContainers)
                {
                    bool found = false;

                    for (uint8 slot = 0; slot < PChar->getStorage(container)->GetSize(); slot++)
                    {
                        auto* PEquip = dynamic_cast<CItemEquipment*>(PChar->getStorage(container)->GetItem(slot));

                        // ensure this is the item we actually want from the db
                        if (PEquip && PEquip->getID() == itemId)
                        {
                            // Validate that we're not trying to equip the same item to two different slots
                            CItemEquipment* compareItem = nullptr;

                            // Get item that theoretically could be equipped an adjacent slot
                            if (equipSlot == SLOT_MAIN || equipSlot == SLOT_EAR1 || equipSlot == SLOT_RING1)
                            {
                                // Check one item to the "right"
                                compareItem = PChar->getEquip(static_cast<SLOTTYPE>(equipSlot + 1));
                            }
                            else if (equipSlot == SLOT_SUB || equipSlot == SLOT_EAR2 || equipSlot == SLOT_RING2)
                            {
                                // Check one item to the "left"
                                compareItem = PChar->getEquip(static_cast<SLOTTYPE>(equipSlot - 1));
                            }

                            // If there's no item to compare then this item is valid
                            // If there is, check they aren't the same via pointer comparison (2 unique copies)
                            if (!compareItem || (compareItem && compareItem != PEquip))
                            {
                                found = true;
                                charutils::EquipItem(PChar, PEquip->getSlotID(), equipSlot, static_cast<CONTAINER_ID>(container));
                                break;
                            }
                        }
                    }

                    if (found)
                    {
                        break;
                    }
                }
            }
        }
    }
}

void EquipItem(CCharEntity* PChar, uint8 slotID, uint8 equipSlotID, uint8 containerID)
{
    if (PChar == nullptr || PChar->getStorage(containerID) == nullptr)
    {
        return;
    }

    CItemEquipment* PItem = dynamic_cast<CItemEquipment*>(PChar->getStorage(containerID)->GetItem(slotID));

    if (PItem && PItem == PChar->getEquip(static_cast<SLOTTYPE>(equipSlotID)))
    {
        return;
    }

     // slotID of zero = unequip
    if (slotID > 0)
    {
        // skip the rest of the function if we are trying to equip the same item to a different slot
        switch (static_cast<SLOTTYPE>(equipSlotID))
        {
            case SLOT_MAIN:
            {
                auto PSub = PChar->getEquip(SLOT_SUB);
                if (PItem == PSub)
                {
                    return;
                }
                break;
            }
            case SLOT_SUB:
            {
                auto PMain = PChar->getEquip(SLOT_MAIN);
                if (PItem == PMain)
                {
                    return;
                }
                break;
            }
            case SLOT_EAR1:
            {
                auto PEar2 = PChar->getEquip(SLOT_EAR2);
                if (PItem == PEar2)
                {
                    return;
                }
                break;
            }
            case SLOT_EAR2:
            {
                auto PEar1 = PChar->getEquip(SLOT_EAR1);
                if (PItem == PEar1)
                {
                    return;
                }
                break;
            }
            case SLOT_RING1:
            {
                auto PRing2 = PChar->getEquip(SLOT_RING2);
                if (PItem == PRing2)
                {
                    return;
                }
                break;
            }
            case SLOT_RING2:
            {
                auto PRing1 = PChar->getEquip(SLOT_RING1);
                if (PItem == PRing1)
                {
                    return;
                }
                break;
            }
            default:
                break;
        }
    }

    // if player attempts to change their ranged weapon during a ranged state then prevent equip
    // this prevents players from starting a RA with short delay x-bow and ending with high dmg longbow
    if (equipSlotID == SLOT_RANGED || (equipSlotID == SLOT_AMMO && !PChar->getEquip(SLOT_RANGED)))
    {
        if (PChar->PAI && PChar->PAI->IsCurrentState<CRangeState>())
        {
            return;
        }
    }

    if (equipSlotID == SLOT_SUB && PItem && !PItem->IsShield())
    {
        auto PItemWeapon = dynamic_cast<CItemWeapon*>(PItem);
        auto PMainItem   = dynamic_cast<CItemWeapon*>(PChar->getEquip(SLOT_MAIN));

        if (PItemWeapon && PItemWeapon->getSkillType() == SKILL_NONE && (!PMainItem || !PMainItem->isTwoHanded()))
        {
            PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, 0, 0, MsgBasic::Requires2HForGrip);
            return;
        }

         if (PItemWeapon && PItemWeapon->getSkillType() != SKILL_NONE)
        {
            // Don't attempt to equip item in equip menu if you don't have dual wield trait (client sees BLU, THF, DNC, NIN, /DNC or /NIN etc as able to equip sub weapons even if sub is too low or no trait on BLU)
            if (!PChar->hasTrait(TRAIT_DUAL_WIELD))
            {
                PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, PItemWeapon->getID(), 0, MsgBasic::NeedDualWield);
                return;
            }

            // Don't allow Dual Wield injections to offhand when you dont have a mainahdn (this was visual only)
            // Don't allow non-shields in offhand with no weapon
            if ((PMainItem && PMainItem->isTwoHanded()) || !PMainItem)
            {
                return;
            }
        }


        // Disallow everything but shields if you're using H2H
        // Equipping a shield will unequip the H2H weapon and you will go barefisted with a shield
        if (PMainItem && PMainItem->getSkillType() == SKILL_HAND_TO_HAND)
        {
            return;
        }
    }

    if (slotID == 0)
    {
        CItemEquipment* PSubItem = PChar->getEquip(SLOT_SUB);

        UnequipItem(PChar, equipSlotID);

        if (equipSlotID == 0 && PSubItem && !PSubItem->IsShield())
        {
            RemoveSub(PChar);
        }
    }
    else
    {
        if ((PItem != nullptr) && PItem->isType(ITEM_EQUIPMENT))
        {
            if (!PItem->isSubType(ITEM_LOCKED) && EquipArmor(PChar, slotID, equipSlotID, containerID))
            {
                if (PItem->getScriptType() & SCRIPT_EQUIP)
                {
                    luautils::OnItemCheck(PChar, PItem, ITEMCHECK::EQUIP, nullptr);
                    PChar->m_EquipFlag |= PItem->getScriptType();
                }
                if (PItem->isType(ITEM_USABLE) && ((CItemUsable*)PItem)->getCurrentCharges() != 0)
                {
                    PItem->setAssignTime(timer::now());
                    // add recast timer to Recast List from any bag
                    PChar->PRecastContainer->Add(RECAST_ITEM, static_cast<Recast>(slotID << 8 | containerID), PItem->getReuseTime());

                    // Do not forget to update the timer when equipping the subject

                    PChar->pushPacket<GP_SERV_COMMAND_ITEM_ATTR>(PItem, static_cast<CONTAINER_ID>(containerID), slotID);
                }
                PItem->setSubType(ITEM_LOCKED);

                if (equipSlotID == SLOT_SUB)
                {
                    // If main hand is empty, check which UnarmedItem to use.
                    if (!PChar->getEquip(SLOT_MAIN) || !PChar->getEquip(SLOT_MAIN)->isType(ITEM_EQUIPMENT))
                    {
                        CheckUnarmedWeapon(PChar);
                    }
                }

                PChar->addEquipModifiers(&PItem->modList, PItem->getReqLvl(), equipSlotID);
                PChar->PLatentEffectContainer->AddLatentEffects(PItem->latentList, PItem->getReqLvl(), equipSlotID);
                PChar->PLatentEffectContainer->CheckLatentsEquip(equipSlotID);
                PChar->addPetModifiers(&PItem->petModList);

                // Only call the lua onEquip if it's a valid equip - e.g. has passed EquipArmor and other checks above
                luautils::OnItemEquip(PChar, PItem);

                // queue look update on valid equip
                if (PItem != nullptr && PItem->isType(ITEM_EQUIPMENT))
                {
                    PChar->inventorySyncState().queueEquipChange(static_cast<CONTAINER_ID>(containerID), slotID, static_cast<SLOTTYPE>(equipSlotID), PItem, Equipping::Yes);
                }
            }
        }
    }

    if (equipSlotID == SLOT_MAIN || equipSlotID == SLOT_RANGED || equipSlotID == SLOT_SUB)
    {
        if (!PItem || !PItem->isType(ITEM_EQUIPMENT) ||
            (((CItemWeapon*)PItem)->getSkillType() != SKILL_STRING_INSTRUMENT && ((CItemWeapon*)PItem)->getSkillType() != SKILL_WIND_INSTRUMENT))
        {
            // If the weapon ISN'T a wind based instrument or a string based instrument
            PChar->health.tp = 0;
            PChar->StatusEffectContainer->DelStatusEffect(EFFECT_AFTERMATH);
        }

        if (!PChar->getEquip(SLOT_MAIN) || !PChar->getEquip(SLOT_MAIN)->isType(ITEM_EQUIPMENT) ||
            PChar->m_Weapons[SLOT_MAIN] == xi::items::unarmedH2H())
        {
            CheckUnarmedWeapon(PChar);
        }

        BuildingCharWeaponSkills(PChar);
    }

    charutils::BuildingCharSkillsTable(PChar);
    PChar->UpdateHealth();

    PChar->updatemask |= UPDATE_HP;
    PChar->updatemask |= UPDATE_LOOK;
}

/************************************************************************
 *                                                                       *
 *  Check the feature of the character wearing the items equipped on it  *
 *                                                                       *
 ************************************************************************/

void CheckValidEquipment(CCharEntity* PChar)
{
    CItemEquipment* PItem = nullptr;

    for (uint8 slotID = 0; slotID < 16; ++slotID)
    {
        PItem = PChar->getEquip((SLOTTYPE)slotID);
        if (PItem == nullptr || !PItem->isType(ITEM_EQUIPMENT))
        {
            continue;
        }

        if (PItem->getReqLvl() > (settings::get<bool>("map.DISABLE_GEAR_SCALING") ? PChar->GetMLevel() : PChar->jobs.job[PChar->GetMJob()]))
        {
            UnequipItem(PChar, slotID);
            continue;
        }

        if (slotID == SLOT_SUB && !PItem->IsShield())
        {
            // Unequip if no main weapon or a non-grip subslot without DW
            if (!PChar->getEquip(SLOT_MAIN) || (!charutils::hasTrait(PChar, TRAIT_DUAL_WIELD) && !(((CItemWeapon*)PItem)->getSkillType() == SKILL_NONE)))
            {
                UnequipItem(PChar, SLOT_SUB);
                continue;
            }
        }

        if ((PItem->getJobs() & (1 << (PChar->GetMJob() - 1))) && (PItem->getEquipSlotId() & (1 << slotID)))
        {
            continue;
        }

        UnequipItem(PChar, slotID);
    }
    // Unarmed H2H weapon check
    if (!PChar->getEquip(SLOT_MAIN) || !PChar->getEquip(SLOT_MAIN)->isType(ITEM_EQUIPMENT) || PChar->m_Weapons[SLOT_MAIN] == xi::items::unarmedH2H())
    {
        CheckUnarmedWeapon(PChar);
    }

    BuildingCharWeaponSkills(PChar);
    PChar->RequestPersist(CHAR_PERSIST::EQUIP);
}

void RemoveAllEquipment(CCharEntity* PChar)
{
    CItemEquipment* PItem = nullptr;

    for (uint8 slotID = 0; slotID < 16; ++slotID)
    {
        PItem = PChar->getEquip((SLOTTYPE)slotID);

        if ((PItem != nullptr) && PItem->isType(ITEM_EQUIPMENT))
        {
            UnequipItem(PChar, slotID);
        }
    }
    // Determines the UnarmedItem to use, since all slots are empty now.
    CheckUnarmedWeapon(PChar);

    BuildingCharWeaponSkills(PChar);
    PChar->RequestPersist(CHAR_PERSIST::EQUIP);
}

/************************************************************************
 *                                                                       *
 *  Check the logic of all character equipment                           *
 *                                                                       *
 ************************************************************************/

// Later will need to make equipment in the structure,
// where to add a bit field indicating in which cell is the equipment with the condition
// To begin with, this field will save us from checking cells in characters without equipment with the condition

void CheckEquipLogic(CCharEntity* PChar, SCRIPTTYPE ScriptType, uint32 param)
{
    if (!(PChar->m_EquipFlag & ScriptType))
    {
        return;
    }

    for (uint8 slotID = 0; slotID < 16; ++slotID)
    {
        CItem* PItem = PChar->getEquip((SLOTTYPE)slotID);

        if ((PItem != nullptr) && PItem->isType(ITEM_EQUIPMENT))
        {
            if (((CItemEquipment*)PItem)->getScriptType() & ScriptType)
            {
                luautils::OnItemCheck(PChar, PItem, static_cast<ITEMCHECK>(param), nullptr);
            }
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Load the Characters weapon skill list                                *
 *                                                                       *
 ************************************************************************/

void BuildingCharWeaponSkills(CCharEntity* PChar)
{
    std::memset(&PChar->m_WeaponSkills, 0, sizeof(PChar->m_WeaponSkills));

    CItemWeapon* PItem    = nullptr;
    int          main_ws  = 0;
    int          range_ws = 0;

    for (auto&& slot : { std::make_tuple(SLOT_MAIN, std::ref(main_ws)), std::make_tuple(SLOT_RANGED, std::ref(range_ws)) })
    {
        if (PChar->m_Weapons[std::get<0>(slot)])
        {
            PItem = dynamic_cast<CItemWeapon*>(PChar->m_Weapons[std::get<0>(slot)]);

            // As of writing, the only unlockable weapons are: wsnm, ksnm, nyzul vigil weapons
            if (PItem && (!PItem->isUnlockable() || PItem->isUnlocked()))
            {
                std::get<1>(slot) = battleutils::GetScaledItemModifier(PChar, PItem, Mod::ADDS_WEAPONSKILL);
            }
        }
    }

    // add in melee ws
    PItem       = dynamic_cast<CItemWeapon*>(PChar->getEquip(SLOT_MAIN));
    uint8 skill = PItem ? PItem->getSkillType() : (uint8)SKILL_HAND_TO_HAND;

    const auto& MeleeWeaponSkillList = battleutils::GetWeaponSkills(skill);
    for (auto&& PSkill : MeleeWeaponSkillList)
    {
        if (battleutils::CanUseWeaponskill(PChar, PSkill) || PSkill->getID() == main_ws)
        {
            addWeaponSkill(PChar, PSkill->getID());
        }
    }

    // add in ranged ws
    PItem = dynamic_cast<CItemWeapon*>(PChar->getEquip(SLOT_RANGED));
    if (PItem != nullptr && PItem->isType(ITEM_WEAPON) && PItem->getSkillType() != SKILL_THROWING)
    {
        skill                             = PItem ? PItem->getSkillType() : 0;
        const auto& RangedWeaponSkillList = battleutils::GetWeaponSkills(skill);
        for (auto&& PSkill : RangedWeaponSkillList)
        {
            if ((battleutils::CanUseWeaponskill(PChar, PSkill)) || PSkill->getID() == range_ws)
            {
                addWeaponSkill(PChar, PSkill->getID());
            }
        }
    }
}

void BuildingCharPetAbilityTable(CCharEntity* PChar, CPetEntity* PPet, uint32 PetID)
{
    if (PPet == nullptr || PChar == nullptr)
    {
        ShowWarning("PPet or PChar was null.");
        return;
    }

    std::memset(&PChar->m_PetCommands, 0, sizeof(PChar->m_PetCommands));

    if (PetID == 0)
    { // technically Fire Spirit but we're using this to null the abilities shown
        PChar->pushPacket<GP_SERV_COMMAND_COMMAND_DATA>(PChar);
        return;
    }

    if (PChar->GetMJob() == JOB_SMN || PChar->GetSJob() == JOB_SMN)
    {
        std::vector<CAbility*> AbilitiesList = ability::GetAbilities(JOB_SMN);

        for (auto PAbility : AbilitiesList)
        {
            if (PPet->GetMLevel() >= PAbility->getLevel() && ((PetID >= PETID_CARBUNCLE && PetID <= PETID_CAIT_SITH) || PetID == PETID_SIREN) && CheckAbilityAddtype(PChar, PAbility))
            {
                if (PetID == PETID_CARBUNCLE)
                {
                    if (PAbility->getID() >= ABILITY_HEALING_RUBY && PAbility->getID() <= ABILITY_SOOTHING_RUBY)
                    {
                        addPetAbility(PChar, PAbility->getID() - ABILITY_HEALING_RUBY);
                    }
                    else if (PAbility->getID() == ABILITY_PACIFYING_RUBY)
                    {
                        addPetAbility(PChar, 261);
                    }
                }
                else if (PetID >= PETID_FENRIR && PetID <= PETID_RAMUH)
                {
                    if (PAbility->getID() >= (ABILITY_HEALING_RUBY + ((PetID - 8) * 16)) && PAbility->getID() < (ABILITY_HEALING_RUBY + ((PetID - 7) * 16)))
                    {
                        addPetAbility(PChar, PAbility->getID() - ABILITY_HEALING_RUBY);
                    }
                }
                else if (PetID == PETID_DIABOLOS)
                {
                    if (PAbility->getID() >= ABILITY_CAMISADO && PAbility->getID() <= ABILITY_PERFECT_DEFENSE)
                    {
                        addPetAbility(PChar, PAbility->getID() - ABILITY_HEALING_RUBY);
                    }
                }
                else if (PetID == PETID_CAIT_SITH)
                {
                    if (PAbility->getID() > ABILITY_SOOTHING_RUBY && PAbility->getID() < ABILITY_MOONLIT_CHARGE)
                    {
                        addPetAbility(PChar, PAbility->getID() - ABILITY_HEALING_RUBY);
                    }
                }
                else if (PetID == PETID_SIREN)
                {
                    if (PAbility->getID() >= ABILITY_CLARSACH_CALL && PAbility->getID() <= ABILITY_HYSTERIC_ASSAULT)
                    {
                        uint16 sirenAbilltyPacketOffset = 0x1C0;
                        uint16 sirenAbilityPacketBit    = (PAbility->getID() - ABILITY_CLARSACH_CALL) + sirenAbilltyPacketOffset;
                        addPetAbility(PChar, sirenAbilityPacketBit);
                    }
                }
            }
        }
    }
    if (PPet->getPetType() == PET_TYPE::JUG_PET)
    {
        auto skillList{ battleutils::GetMobSkillList(PPet->m_MobSkillList) };
        for (auto&& abilityid : skillList)
        {
            addPetAbility(PChar, abilityid - ABILITY_HEALING_RUBY);
        }
    }
    PChar->pushPacket<GP_SERV_COMMAND_COMMAND_DATA>(PChar);
}

/************************************************************************
 *                                                                       *
 *  Collect the work table of the character's abilities.With zero level  *
 *  There must be 2H abilities .On this condition, sift them for SJOB    *
 *                                                                       *
 ************************************************************************/

void BuildingCharAbilityTable(CCharEntity* PChar)
{
    if (PChar == nullptr)
    {
        ShowWarning("charutils::BuildingCharAbilityTable() - PChar was null.");
        return;
    }

    std::memset(&PChar->m_Abilities, 0, sizeof(PChar->m_Abilities));

    for (auto PAbility : ability::GetAbilities(PChar->GetMJob()))
    {
        if (PAbility == nullptr)
        {
            continue;
        }

        if (PChar->GetMLevel() >= PAbility->getLevel())
        {
            if (PAbility->getID() < ABILITY_HEALING_RUBY && PAbility->getID() != ABILITY_PET_COMMANDS && CheckAbilityAddtype(PChar, PAbility))
            {
                addAbility(PChar, PAbility->getID());
                Charge_t*       charge     = ability::GetCharge(PChar, static_cast<uint16>(PAbility->getRecastId()));
                timer::duration chargeTime = 0s;
                auto            maxCharges = 0;
                if (charge)
                {
                    chargeTime = charge->chargeTime - std::chrono::seconds(PChar->PMeritPoints->GetMeritValue((MERIT_TYPE)charge->merit, PChar));
                    maxCharges = charge->maxCharges;
                }
                if (!PChar->PRecastContainer->Has(RECAST_ABILITY, PAbility->getRecastId()))
                {
                    PChar->PRecastContainer->Add(RECAST_ABILITY, PAbility->getRecastId(), 0s, chargeTime, maxCharges);
                }
            }
        }
        else
        {
            break;
        }
    }

    // To stop a character with no SJob to receive the traits with job = 0 in the DB.
    if (PChar->GetSJob() == JOB_NON)
    {
        return;
    }

    for (auto PAbility : ability::GetAbilities(PChar->GetSJob()))
    {
        if (!PAbility)
        {
            continue;
        }

        if (PChar->GetSLevel() >= PAbility->getLevel())
        {
            if (PAbility->getLevel() != 0 && PAbility->getID() < ABILITY_HEALING_RUBY)
            {
                if (PAbility->getID() != ABILITY_PET_COMMANDS && CheckAbilityAddtype(PChar, PAbility) && !(PAbility->getAddType() & ADDTYPE_MAIN_ONLY))
                {
                    addAbility(PChar, PAbility->getID());
                    Charge_t*       charge     = ability::GetCharge(PChar, static_cast<uint16>(PAbility->getRecastId()));
                    timer::duration chargeTime = 0s;
                    auto            maxCharges = 0;
                    if (charge)
                    {
                        chargeTime = charge->chargeTime - std::chrono::seconds(PChar->PMeritPoints->GetMeritValue((MERIT_TYPE)charge->merit, PChar));
                        maxCharges = charge->maxCharges;
                    }
                    if (!PChar->PRecastContainer->Has(RECAST_ABILITY, PAbility->getRecastId()))
                    {
                        PChar->PRecastContainer->Add(RECAST_ABILITY, PAbility->getRecastId(), 0s, chargeTime, maxCharges);
                    }
                }
            }
        }
        else
        {
            break;
        }
    }
}

// determines if this player has bonus for this skill based on the active sch arts
bool isArtsBonusActive(CCharEntity* PChar, SKILLTYPE SkillID)
{
    return (SkillID >= SKILL_DIVINE_MAGIC && SkillID <= SKILL_ENFEEBLING_MAGIC &&
            PChar->StatusEffectContainer->HasStatusEffect({ EFFECT_LIGHT_ARTS, EFFECT_ADDENDUM_WHITE })) ||
           (SkillID >= SKILL_ENFEEBLING_MAGIC && SkillID <= SKILL_DARK_MAGIC &&
            PChar->StatusEffectContainer->HasStatusEffect({ EFFECT_DARK_ARTS, EFFECT_ADDENDUM_BLACK }));
}

// calculates the bonus skill based on active sch arts
int16 ArtsBonusSkill(CCharEntity* PChar, SKILLTYPE SkillID)
{
    int16 skillBonus = 0;

    uint16 maxMainSkill = battleutils::GetMaxSkill(SkillID, PChar->GetMJob(), PChar->GetMLevel());
    uint16 maxSubSkill  = battleutils::GetMaxSkill(SkillID, PChar->GetSJob(), PChar->GetSLevel()) * 3 / 4;

    uint16 artsSkill    = battleutils::GetMaxSkill(SKILL_ENHANCING_MAGIC, JOB_RDM, PChar->GetMLevel());                               // B+ skill
    uint16 skillCapD    = battleutils::GetMaxSkill(SkillID, JOB_SCH, PChar->GetMLevel());                                             // D skill cap
    uint16 skillCapE    = battleutils::GetMaxSkill(SKILL_DARK_MAGIC, JOB_RDM, PChar->GetMLevel());                                    // E skill cap
    auto   currentSkill = std::clamp<uint16>((PChar->RealSkills.skill[(int32)SkillID] / 10), 0, std::max(maxMainSkill, maxSubSkill)); // working skill before bonuses
    uint16 artsBaseline = 0;                                                                                                          // Level based baseline to which to raise skills
    uint8  mLevel       = PChar->GetMLevel();
    if (mLevel < 51)
    {
        artsBaseline = (uint16)(5 + 2.7 * (mLevel - 1));
    }
    else if (mLevel < 61)
    {
        artsBaseline = (uint16)(137 + 4.7 * (mLevel - 50));
    }
    else if (mLevel < 71)
    {
        artsBaseline = (uint16)(184 + 3.7 * (mLevel - 60));
    }
    else if (mLevel < 75)
    {
        artsBaseline = (uint16)(221 + 5.0 * (mLevel - 70));
    }
    else // >= 75
    {
        artsBaseline = skillCapD + 36;
    }

    if (currentSkill < skillCapE)
    {
        // If the player's skill is below the E cap
        // give enough bonus points to raise it to the arts baseline
        skillBonus += std::max(artsBaseline - currentSkill, 0);
    }
    else if (currentSkill < skillCapD)
    {
        // if the skill is at or above the E cap but below the D cap
        // raise it up to the B+ skill cap minus the difference between the current skill rank and the scholar base skill cap (D)
        // i.e. give a bonus of the difference between the B+ skill cap and the D skill cap
        skillBonus += std::max((artsSkill - skillCapD), 0);
    }
    else if (currentSkill < artsSkill)
    {
        // If the player's skill is at or above the D cap but below the B+ cap
        // give enough bonus points to raise it to the B+ cap
        skillBonus += std::max(artsSkill - currentSkill, 0);
    }

    if (PChar->StatusEffectContainer->HasStatusEffect({ EFFECT_LIGHT_ARTS, EFFECT_ADDENDUM_WHITE }))
    {
        skillBonus += PChar->getMod(Mod::LIGHT_ARTS_SKILL);
    }
    else
    {
        skillBonus += PChar->getMod(Mod::DARK_ARTS_SKILL);
    }

    return skillBonus;
}

/************************************************************************
 *                                                                       *
 *  Collect the work table of the character skills based on real.        *
 *  Add restrictions, note the skills of the main job (rank! = 0)        *
 *                                                                       *
 ************************************************************************/

// TODO: This whole thing should eventually get a refactored to be less dependent on arbitrary ordering of modifier IDs and conditionals on skill ranges.
void BuildingCharSkillsTable(CCharEntity* PChar)
{
    MERIT_TYPE skillMerit[] = { MERIT_H2H,
                                MERIT_DAGGER,
                                MERIT_SWORD,
                                MERIT_GSWORD,
                                MERIT_AXE,
                                MERIT_GAXE,
                                MERIT_SCYTHE,
                                MERIT_POLEARM,
                                MERIT_KATANA,
                                MERIT_GKATANA,
                                MERIT_CLUB,
                                MERIT_STAFF,
                               // MERIT_AUTOMATON_SKILLS, Sanctum Custom
                               // MERIT_AUTOMATON_SKILLS, Sanctum Custom
                               // MERIT_AUTOMATON_SKILLS, Sanctum Custom
                                MERIT_ARCHERY,
                                MERIT_MARKSMANSHIP,
                                MERIT_THROWING,
                                MERIT_GUARDING,
                                MERIT_EVASION,
                                MERIT_SHIELD,
                                MERIT_PARRYING,
                                MERIT_DIVINE,
                                MERIT_HEALING,
                                MERIT_ENHANCING,
                                MERIT_ENFEEBLING,
                                MERIT_ELEMENTAL,
                                MERIT_DARK,
                                MERIT_SUMMONING,
                                MERIT_NINJITSU,
                                MERIT_SINGING,
                                MERIT_STRING,
                                MERIT_WIND,
                                MERIT_BLUE,
                                MERIT_GEO,
                                MERIT_HANDBELL };

    uint8 meritIndex = 0;

    bool automatonSkillUpdated = false;

    // Iterate over skill IDs (offsetting by 79 to get modifier ID)
    for (int32 i = 1; i < 48; ++i)
    {
        // ignore unused skills
        if ((i >= 13 && i <= 21) || (i >= 46 && i <= 47))
        {
            PChar->WorkingSkills.skill[i] = 0x8000;
            continue;
        }
        uint16 maxMainSkill = battleutils::GetMaxSkill((SKILLTYPE)i, PChar->GetMJob(), PChar->GetMLevel());
        uint16 maxSubSkill  = battleutils::GetMaxSkill((SKILLTYPE)i, PChar->GetSJob(), PChar->GetSLevel());
        int16  skillBonus   = 0;

        // apply arts bonuses
        if (isArtsBonusActive(PChar, static_cast<SKILLTYPE>(i)))
        {
            skillBonus += ArtsBonusSkill(PChar, static_cast<SKILLTYPE>(i));
        }
        else if (i >= SKILL_AUTOMATON_MELEE && i <= SKILL_AUTOMATON_MAGIC)
        {
            // TODO: does this need to change if you are /PUP?
            maxMainSkill = battleutils::GetMaxSkill(1, PChar->GetMLevel()); // A+ capped down to the Automaton's rating
        }

        skillBonus += PChar->PMeritPoints->GetMeritValue(skillMerit[meritIndex], PChar);
        meritIndex++;

        // Add 79 to get the modifier ID
        skillBonus += PChar->getMod(static_cast<Mod>(i + 79)); // This can be a negative value. Example: Shiva's Shotel.

        uint8 mainSkillRank = battleutils::GetSkillRank((SKILLTYPE)i, PChar->GetMJob());
        uint8 subSkillRank  = battleutils::GetSkillRank((SKILLTYPE)i, PChar->GetSJob());

        PChar->WorkingSkills.rank[i] = mainSkillRank;

        if (mainSkillRank != 0)
        {
            PChar->RealSkills.rank[i] = mainSkillRank;
        }
        else
        {
            PChar->RealSkills.rank[i] = subSkillRank;
        }

        uint16 currentSkill = PChar->RealSkills.skill[i] / 10;

        // Main Job Skills.
        if (maxMainSkill != 0)
        {
            if (currentSkill > maxMainSkill)
            {
                currentSkill = maxMainSkill;
            }

            int16 newSkillValue = currentSkill + skillBonus;
            if (newSkillValue < 0)
            {
                newSkillValue = 0;
            }

            PChar->WorkingSkills.skill[i] = static_cast<uint16>(newSkillValue);

            if (currentSkill >= maxMainSkill)
            {
                PChar->WorkingSkills.skill[i] |= 0x8000; // Blue text.
            }
        }

        // Sub Job Skills.
        else if (maxSubSkill != 0)
        {
            if (currentSkill > maxSubSkill)
            {
                currentSkill = maxSubSkill;
            }

            int16 newSkillValue = currentSkill + skillBonus;
            if (newSkillValue < 0)
            {
                newSkillValue = 0;
            }

            PChar->WorkingSkills.skill[i] = static_cast<uint16>(newSkillValue);

            if (currentSkill >= maxSubSkill)
            {
                PChar->WorkingSkills.skill[i] |= 0x8000; // Blue text.
            }
        }

        // Job setup doesn't have this skill.
        else
        {
            if (skillBonus < 0)
            {
                skillBonus = 0;
            }
            PChar->WorkingSkills.skill[i] = static_cast<uint16>(skillBonus) | 0x8000; // New value AND Blue text.
        }

        // Automaton skills are special (especially with magic...)
        if (i >= SKILL_AUTOMATON_MELEE && i <= SKILL_AUTOMATON_MAGIC)
        {
            if (auto PAutomaton = dynamic_cast<CAutomatonEntity*>(PChar->PPet))
            {
                switch (i)
                {
                    case SKILL_AUTOMATON_MAGIC:
                        PAutomaton->WorkingSkills.skill[i] = PChar->WorkingSkills.skill[i];

                        PAutomaton->WorkingSkills.skill[SKILL_HEALING_MAGIC]    = PChar->WorkingSkills.skill[i];
                        PAutomaton->WorkingSkills.skill[SKILL_ENHANCING_MAGIC]  = PChar->WorkingSkills.skill[i];
                        PAutomaton->WorkingSkills.skill[SKILL_ENFEEBLING_MAGIC] = PChar->WorkingSkills.skill[i];
                        PAutomaton->WorkingSkills.skill[SKILL_ELEMENTAL_MAGIC]  = PChar->WorkingSkills.skill[i];
                        PAutomaton->WorkingSkills.skill[SKILL_DARK_MAGIC]       = PChar->WorkingSkills.skill[i];
                        break;

                    default:
                        PAutomaton->WorkingSkills.skill[i] = PChar->WorkingSkills.skill[i];
                        break;
                }

                automatonSkillUpdated = true;
            }
        }
    }

    for (int32 i = 48; i < 58; ++i)
    {
        PChar->WorkingSkills.skill[i] = (PChar->RealSkills.skill[i] / 10) * 0x20 + PChar->RealSkills.rank[i];

        if ((PChar->RealSkills.rank[i] + 1) * 100 <= PChar->RealSkills.skill[i])
        {
            PChar->WorkingSkills.skill[i] += 0x8000;
        }
    }

    for (int32 i = 58; i < 64; ++i)
    {
        PChar->WorkingSkills.skill[i] = 0xFFFF;
    }

    // Update skills menu
    if (automatonSkillUpdated)
    {
        charutils::SendExtendedJobPackets(PChar);
    }
}

void BuildingCharTraitsTable(CCharEntity* PChar)
{
    for (std::size_t i = 0; i < PChar->TraitList.size(); ++i)
    {
        CTrait* PTrait = PChar->TraitList.at(i);
        PChar->delModifier(PTrait->getMod(), PTrait->getValue());
    }
    PChar->TraitList.clear();
    std::memset(&PChar->m_TraitList, 0, sizeof(PChar->m_TraitList));

    auto mjob = PChar->GetMJob();
    auto sjob = PChar->GetSJob();
    auto mlvl = PChar->GetMLevel();
    auto slvl = PChar->GetSLevel();

    // NOTE: Monstrosity (MON) is treated as its own job, but each species is it's own
    //     : combination of main/sub job for stats, traits and abilities.
    if (PChar->m_PMonstrosity != nullptr)
    {
        mjob = PChar->m_PMonstrosity->MainJob;
        sjob = PChar->m_PMonstrosity->SubJob;
        mlvl = PChar->m_PMonstrosity->levels[PChar->m_PMonstrosity->MonstrosityId];
        slvl = mlvl;
    }

    battleutils::AddTraits(PChar, traits::GetTraits(mjob), mlvl);
    battleutils::AddTraits(PChar, traits::GetTraits(sjob), slvl);

    // Sanctum custom merit: Dual Wield bonus, delete mod first then apply so if the function is called multiple times it won't keep adding the bonus on top of itself.
    PChar->delModifier(Mod::DUAL_WIELD, PChar->PMeritPoints->GetMeritValue(MERIT_DUAL_WIELD_BONUS, PChar));
    PChar->addModifier(Mod::DUAL_WIELD, PChar->PMeritPoints->GetMeritValue(MERIT_DUAL_WIELD_BONUS, PChar));

    // Sanctum custom merit: PUP Martial Arts bonus, delete mod first then apply so if the function is called multiple times it won't keep adding the bonus on top of itself.
    if (mjob == JOB_PUP)
    {
        PChar->delModifier(Mod::MARTIAL_ARTS, PChar->PMeritPoints->GetMeritValue(MERIT_MARTIAL_ARTS_EFFECT, PChar));
        PChar->addModifier(Mod::MARTIAL_ARTS, PChar->PMeritPoints->GetMeritValue(MERIT_MARTIAL_ARTS_EFFECT, PChar));
    }

    if (mjob == JOB_BLU || sjob == JOB_BLU)
    {
        blueutils::CalculateTraits(PChar);
    }

    PChar->delModifier(Mod::MEVA, PChar->m_magicEvasion);

    PChar->m_magicEvasion = battleutils::GetMaxSkill(12, mlvl); // Player MEVA is Rank G
    PChar->addModifier(Mod::MEVA, PChar->m_magicEvasion);
}

/************************************************************************
 *                                                                       *
 *  Try to increase the value of the skill                               *
 *                                                                       *
 ************************************************************************/

void TrySkillUP(CCharEntity* PChar, SKILLTYPE SkillID, uint8 lvl, bool forceSkillUp, bool useSubSkill)
{
    TracyZoneScoped;

    // This usually happens after a crash
    uint8 rawSkillID = static_cast<uint8>(SkillID);
    if (rawSkillID >= MAX_SKILLTYPE)
    {
        ShowWarning("SkillID (%d) exceeds MAX_SKILLTYPE.", rawSkillID);
        return;
    }

    if (((PChar->WorkingSkills.rank[rawSkillID] != 0) && !(PChar->WorkingSkills.skill[rawSkillID] & 0x8000)) || useSubSkill)
    {
        uint16 CurSkill     = PChar->RealSkills.skill[rawSkillID];
        uint16 MainCapSkill = battleutils::GetMaxSkill(SkillID, PChar->GetMJob(), PChar->GetMLevel());
        uint16 SubCapSkill  = battleutils::GetMaxSkill(SkillID, PChar->GetSJob(), PChar->GetSLevel());
        uint16 MainMaxSkill = battleutils::GetMaxSkill(SkillID, PChar->GetMJob(), std::min(PChar->GetMLevel(), lvl));
        uint16 SubMaxSkill  = battleutils::GetMaxSkill(SkillID, PChar->GetSJob(), std::min(PChar->GetSLevel(), lvl));
        uint16 MaxSkill     = 0;
        uint16 CapSkill     = 0;

        if (useSubSkill)
        {
            if (MainCapSkill > SubCapSkill)
            {
                CapSkill = MainCapSkill;
                MaxSkill = MainMaxSkill;
            }
            else
            {
                CapSkill = SubCapSkill;
                MaxSkill = SubMaxSkill;
            }
        }
        else
        {
            CapSkill = MainCapSkill;
            MaxSkill = MainMaxSkill;
        }
        // Max skill this victim level will allow.
        // Note this is no longer retail accurate, since now 'decent challenge' mobs allow to cap any skill.

        int16  Diff          = MaxSkill - CurSkill / 10;
        double SkillUpChance = Diff / 5.0 + settings::get<double>("map.SKILLUP_CHANCE_MULTIPLIER") * (2.0 - log10(1.0 + CurSkill / 100));

        double random = xirand::GetRandomNumber(1.);

        if (SkillUpChance > 0.5)
        {
            SkillUpChance = 0.5;
        }

        // Check for skillup% bonus. https://www.bg-wiki.com/bg/Category:Skill_Up_Food
        // Assuming multiplicative even though rate is already a % because 0.5 + 0.8 would be > 1.
        if ((SkillID >= 1 && SkillID <= 12) || (SkillID >= 25 && SkillID <= 31))
        // if should effect automaton replace the above with: (SkillID >= 1 && SkillID <= 31)
        {
            SkillUpChance *= ((100.0f + PChar->getMod(Mod::COMBAT_SKILLUP_RATE)) / 100.0f);
        }
        else if (SkillID >= 32 && SkillID <= 44)
        {
            SkillUpChance *= ((100.0f + PChar->getMod(Mod::MAGIC_SKILLUP_RATE)) / 100.0f);
        }

        // Custom Sanctum: Apply each race's favored and weaker skill-up rates.
        SkillUpChance *= getRacialSkillUpModifier(PChar, SkillID);

        // Custom Sanctum: Bonus skillup chance for low-level players
        if (PChar->GetMLevel() < 30)
        {
            SkillUpChance *= 1.5f;
        }

        if (Diff > 0 && (random < SkillUpChance || forceSkillUp))
        {
            double chance      = 0;
            uint8  SkillAmount = 1;
            uint8  tier        = std::min(1 + (Diff / 5), 5);

            for (uint8 i = 0; i < 4; ++i) // 1 + 4 possible additional ones (maximum 5)
            {
                random = xirand::GetRandomNumber(1.);

                switch (tier)
                {
                    case 5:
                        chance = 0.900;
                        break;
                    case 4:
                        chance = 0.700;
                        break;
                    case 3:
                        chance = 0.500;
                        break;
                    case 2:
                        chance = 0.300;
                        break;
                    case 1:
                        chance = 0.200;
                        break;
                    default:
                        chance = 0.000;
                        break;
                }

                if (chance < random || SkillAmount == 5)
                {
                    break;
                }

                tier -= 1;
                SkillAmount += 1;
            }
            // convert to 10th units
            CapSkill = CapSkill * 10;

            int16 rovBonus = 1;

            for (const auto skillupIncreaseKeyItem : skillupIncreaseKeyItems)
            {
                if (hasKeyItem(PChar, skillupIncreaseKeyItem))
                {
                    rovBonus += 1;
                }
            }

            SkillAmount *= rovBonus;
            if (SkillAmount > 9)
            {
                SkillAmount = 9;
            }

            // Do skill amount multiplier (Will only be applied if default setting is changed)
            if (settings::get<uint8>("map.SKILLUP_AMOUNT_MULTIPLIER") > 1)
            {
                SkillAmount += (uint8)(SkillAmount * settings::get<uint8>("map.SKILLUP_AMOUNT_MULTIPLIER"));
                if (SkillAmount > 9)
                {
                    SkillAmount = 9;
                }
            }

            if (SkillAmount + CurSkill >= CapSkill)
            {
                // skill is capped. set blue flag
                SkillAmount = CapSkill - CurSkill;
                PChar->WorkingSkills.skill[SkillID] |= 0x8000;
            }

            // check if skillup changed the bonus from sch arts
            int16 skillBonus = 0;
            if (isArtsBonusActive(PChar, SkillID))
            {
                skillBonus = ArtsBonusSkill(PChar, SkillID);
            }

            PChar->RealSkills.skill[SkillID] += SkillAmount;
            PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, SkillID, SkillAmount, MsgBasic::SkillGain);

            if ((CurSkill / 10) < (CurSkill + SkillAmount) / 10) // if gone up a level
            {
                // Light/Dark Arts artificially boost certain skills
                // if skillup happens when real skill is below the base for active arts, don't increment the shown skill
                if (isArtsBonusActive(PChar, SkillID))
                {
                    // if the bonus is the same, our real skill was already past the base bonus, so increment the shown skill from skillup
                    if (skillBonus == ArtsBonusSkill(PChar, SkillID))
                    {
                        PChar->WorkingSkills.skill[SkillID] += 1;
                    }
                }
                else
                {
                    PChar->WorkingSkills.skill[SkillID] += 1;
                }
                PChar->pushPacket<GP_SERV_COMMAND_CLISTATUS2>(PChar);
                PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, SkillID, (CurSkill + SkillAmount) / 10, MsgBasic::SkillLevelUp);

                CheckWeaponSkill(PChar, SkillID);
                /* ignoring this for now
                if (SkillID >= 1 && SkillID <= 12)
                {
                PChar->addModifier(Mod::ATT, 1);
                PChar->addModifier(Mod::ACC, 1);
                }
                */
            }
            SaveCharSkills(PChar, SkillID);
        }
    }
}

/************************************************************************
 *                                                                       *
 *  When skill level gained check for weapon skill                       *
 *                                                                       *
 ************************************************************************/

void CheckWeaponSkill(CCharEntity* PChar, uint8 skill)
{
    auto* weapon       = dynamic_cast<CItemWeapon*>(PChar->m_Weapons[SLOT_MAIN]);
    auto* rangedWeapon = dynamic_cast<CItemWeapon*>(PChar->m_Weapons[SLOT_RANGED]);

    bool noOrInvalidMainWeapon   = !weapon || weapon->getSkillType() != skill;
    bool noOrInvalidRangedWeapon = !rangedWeapon || rangedWeapon->getSkillType() != skill;

    if (noOrInvalidMainWeapon && noOrInvalidRangedWeapon)
    {
        return;
    }

    const auto& WeaponSkillList = battleutils::GetWeaponSkills(skill);
    uint16      curSkill        = PChar->RealSkills.skill[skill] / 10;

    for (auto&& PSkill : WeaponSkillList)
    {
        if (curSkill == PSkill->getSkillLevel() && (battleutils::CanUseWeaponskill(PChar, PSkill)))
        {
            addWeaponSkill(PChar, PSkill->getID());
            PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, PSkill->getID(), PSkill->getID(), MsgBasic::LearnsAbility);
            PChar->pushPacket<GP_SERV_COMMAND_COMMAND_DATA>(PChar);
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Methods for working with key items                                   *
 *                                                                       *
 ************************************************************************/

auto hasKeyItem(const CCharEntity* PChar, const KeyItem keyItemId) -> bool
{
    const auto keyItemTable = static_cast<uint16_t>(keyItemId) / 512;
    const auto keyItemIndex = static_cast<uint16_t>(keyItemId) % 512;

    if (keyItemTable >= PChar->keys.tables.size())
    {
        ShowErrorFmt("charutils::hasKeyItem() - Index {} exceeds key items table capacity.", keyItemTable);
        return false;
    }

    return PChar->keys.tables[keyItemTable].keyList[keyItemIndex];
}

auto seenKeyItem(CCharEntity* PChar, KeyItem keyItemId) -> bool
{
    const auto keyItemTable = static_cast<uint16_t>(keyItemId) / 512;
    const auto keyItemIndex = static_cast<uint16_t>(keyItemId) % 512;

    if (keyItemTable >= PChar->keys.tables.size())
    {
        ShowErrorFmt("charutils::seenKeyItem() - Index {} exceeds key items table capacity.", keyItemTable);
        return false;
    }

    return PChar->keys.tables[keyItemTable].seenList[keyItemIndex];
}

void markSeenKeyItem(CCharEntity* PChar, KeyItem keyItemId)
{
    const auto keyItemTable = static_cast<uint16_t>(keyItemId) / 512;
    const auto keyItemIndex = static_cast<uint16_t>(keyItemId) % 512;

    if (keyItemTable >= PChar->keys.tables.size())
    {
        ShowErrorFmt("charutils::markSeenKeyItem() - Index {} exceeds key items table capacity.", keyItemTable);
        return;
    }

    PChar->keys.tables[keyItemTable].seenList[keyItemIndex] = true;
}

void unseenKeyItem(CCharEntity* PChar, KeyItem keyItemId)
{
    const auto keyItemTable = static_cast<uint16_t>(keyItemId) / 512;
    const auto keyItemIndex = static_cast<uint16_t>(keyItemId) % 512;

    if (keyItemTable >= PChar->keys.tables.size())
    {
        ShowErrorFmt("charutils::unseenKeyItem() - Index {} exceeds key items table capacity.", keyItemTable);
        return;
    }

    PChar->keys.tables[keyItemTable].seenList[keyItemIndex] = false;
}

void addKeyItem(CCharEntity* PChar, KeyItem keyItemId)
{
    const auto keyItemTable = static_cast<uint16_t>(keyItemId) / 512;
    const auto keyItemIndex = static_cast<uint16_t>(keyItemId) % 512;

    if (keyItemTable >= PChar->keys.tables.size())
    {
        ShowErrorFmt("charutils::addKeyItem() - Index {} exceeds key items table capacity.", keyItemTable);
        return;
    }

    PChar->keys.tables[keyItemTable].keyList[keyItemIndex] = true;
}

void delKeyItem(CCharEntity* PChar, KeyItem keyItemId)
{
    const auto keyItemTable = static_cast<uint16_t>(keyItemId) / 512;
    const auto keyItemIndex = static_cast<uint16_t>(keyItemId) % 512;

    if (keyItemTable >= PChar->keys.tables.size())
    {
        ShowErrorFmt("charutils::delKeyItem() - Index {} exceeds key items table capacity.", keyItemTable);
        return;
    }

    PChar->keys.tables[keyItemTable].keyList[keyItemIndex] = false;
}

/************************************************************************
 *                                                                       *
 *  Methods for working with spells                                      *
 *                                                                       *
 ************************************************************************/

int32 hasSpell(CCharEntity* PChar, uint16 SpellID)
{
    return PChar->m_SpellList[SpellID];
}

int32 addSpell(CCharEntity* PChar, uint16 spellID)
{
    auto* PSpell = spell::GetSpell(static_cast<SpellID>(spellID));
    if (PSpell && !hasSpell(PChar, spellID))
    {
        PChar->m_SpellList[spellID] = true;
        return 1;
    }
    return 0;
}

int32 delSpell(CCharEntity* PChar, uint16 spellID)
{
    auto* PSpell = spell::GetSpell(static_cast<SpellID>(spellID));
    if (PSpell && hasSpell(PChar, spellID))
    {
        PChar->m_SpellList[spellID] = false;
        return 1;
    }
    return 0;
}

/************************************************************************
 *                                                                       *
 *  Learned abilities (corsair rolls)                                    *
 *                                                                       *
 ************************************************************************/

int32 hasLearnedAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return hasBit(AbilityID, PChar->m_LearnedAbilities, sizeof(PChar->m_LearnedAbilities));
}

int32 addLearnedAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return addBit(AbilityID, PChar->m_LearnedAbilities, sizeof(PChar->m_LearnedAbilities));
}

int32 delLearnedAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return delBit(AbilityID, PChar->m_LearnedAbilities, sizeof(PChar->m_LearnedAbilities));
}

/************************************************************************
 *                                                                       *
 *  Learned weaponskills                                                 *
 *                                                                       *
 ************************************************************************/

bool hasLearnedWeaponskill(CCharEntity* PChar, uint8 wsUnlockId)
{
    if (PChar == nullptr)
    {
        ShowError("PChar is null.");
        return false;
    }

    if (wsUnlockId > PChar->m_LearnedWeaponskills.size() - 1)
    {
        ShowError("wsUnlockId is greater than learned weaponskill bitset.");
        return false;
    }

    return PChar->m_LearnedWeaponskills[wsUnlockId];
}

void addLearnedWeaponskill(CCharEntity* PChar, uint8 wsUnlockId)
{
    if (PChar == nullptr)
    {
        ShowError("PChar is null.");
        return;
    }

    if (wsUnlockId > PChar->m_LearnedWeaponskills.size() - 1)
    {
        ShowError("wsUnlockId is greater than learned weaponskill bitset.");
        return;
    }

    PChar->m_LearnedWeaponskills[wsUnlockId] = true;
}

void delLearnedWeaponskill(CCharEntity* PChar, uint8 wsUnlockId)
{
    if (PChar == nullptr)
    {
        ShowError("PChar is null.");
        return;
    }

    if (wsUnlockId > PChar->m_LearnedWeaponskills.size() - 1)
    {
        ShowError("wsUnlockId is greater than learned weaponskill bitset.");
        return;
    }

    PChar->m_LearnedWeaponskills[wsUnlockId] = false;
}

/************************************************************************
 *                                                                       *
 *  Methods for working with titles                                      *
 *                                                                       *
 ************************************************************************/

int32 hasTitle(CCharEntity* PChar, uint16 Title)
{
    return hasBit(Title, PChar->m_TitleList, sizeof(PChar->m_TitleList));
}

int32 addTitle(CCharEntity* PChar, uint16 Title)
{
    return addBit(Title, PChar->m_TitleList, sizeof(PChar->m_TitleList));
}

int32 delTitle(CCharEntity* PChar, uint16 Title)
{
    return delBit(Title, PChar->m_TitleList, sizeof(PChar->m_TitleList));
}

void setTitle(CCharEntity* PChar, uint16 Title)
{
    PChar->profile.title = Title;
    PChar->pushPacket<GP_SERV_COMMAND_CLISTATUS>(PChar);

    addTitle(PChar, Title);
    SaveTitles(PChar);
}

/************************************************************************
 *                                                                       *
 *  Methods for working with basic abilities                             *
 *                                                                       *
 ************************************************************************/

int32 hasAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return hasBit(AbilityID, PChar->m_Abilities, sizeof(PChar->m_Abilities));
}

int32 addAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return addBit(AbilityID, PChar->m_Abilities, sizeof(PChar->m_Abilities));
}

int32 delAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return delBit(AbilityID, PChar->m_Abilities, sizeof(PChar->m_Abilities));
}

/************************************************************************
 *                                                                       *
 *  Weapon Skill functions                                               *
 *                                                                       *
 ************************************************************************/

int32 hasWeaponSkill(CCharEntity* PChar, uint16 WeaponSkillID)
{
    return hasBit(WeaponSkillID, PChar->m_WeaponSkills, sizeof(PChar->m_WeaponSkills));
}

int32 addWeaponSkill(CCharEntity* PChar, uint16 WeaponSkillID)
{
    return addBit(WeaponSkillID, PChar->m_WeaponSkills, sizeof(PChar->m_WeaponSkills));
}

int32 delWeaponSkill(CCharEntity* PChar, uint16 WeaponSkillID)
{
    return delBit(WeaponSkillID, PChar->m_WeaponSkills, sizeof(PChar->m_WeaponSkills));
}

bool canUseWeaponSkill(CCharEntity* PChar, uint16 wsid)
{
    CWeaponSkill* PWeaponSkill = battleutils::GetWeaponSkill(wsid);

    if (PWeaponSkill == nullptr)
    {
        ShowError("Invalid Weaponskill ID passed to function.");
        return false;
    }

    return PChar->GetSkill(PWeaponSkill->getType()) >= PWeaponSkill->getSkillLevel();
}

/************************************************************************
 *                                                                       *
 *  Trait Functions                                                      *
 *                                                                       *
 ************************************************************************/

int32 hasTrait(CCharEntity* PChar, uint16 TraitID)
{
    if (PChar->objtype != TYPE_PC)
    {
        ShowError("charutils::hasTrait Attempt to reference a trait from a non-character entity: %s %i", PChar->name.c_str(), PChar->id);
        return 0;
    }
    return hasBit(TraitID, PChar->m_TraitList, sizeof(PChar->m_TraitList));
}

int32 addTrait(CCharEntity* PChar, uint16 TraitID)
{
    if (PChar->objtype != TYPE_PC)
    {
        ShowError("charutils::addTrait Attempt to reference a trait from a non-character entity: %s %i", PChar->name.c_str(), PChar->id);
        return 0;
    }
    return addBit(TraitID, PChar->m_TraitList, sizeof(PChar->m_TraitList));
}

int32 delTrait(CCharEntity* PChar, uint16 TraitID)
{
    if (PChar->objtype != TYPE_PC)
    {
        ShowError("charutils::delTrait Attempt to reference a trait from a non-character entity: %s %i", PChar->name.c_str(), PChar->id);
        return 0;
    }
    return delBit(TraitID, PChar->m_TraitList, sizeof(PChar->m_TraitList));
}

/************************************************************************
 *                                                                       *
 *  Pet Command Functions                                                *
 *                                                                       *
 ************************************************************************/

int32 hasPetAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return hasBit(AbilityID, PChar->m_PetCommands, sizeof(PChar->m_PetCommands));
}

int32 addPetAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return addBit(AbilityID, PChar->m_PetCommands, sizeof(PChar->m_PetCommands));
}

int32 delPetAbility(CCharEntity* PChar, uint16 AbilityID)
{
    return delBit(AbilityID, PChar->m_PetCommands, sizeof(PChar->m_PetCommands));
}

/************************************************************************
 *                                                                       *
 *  Initialize the experience (exp) table                                *
 *                                                                       *
 ************************************************************************/

void LoadExpTable()
{
    TracyZoneScoped;

    auto rset = db::preparedStmt("SELECT r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20 "
                                 "FROM exp_table "
                                 "ORDER BY level ASC "
                                 "LIMIT ?",
                                 ExpTableRowCount);

    uint32 x = 0;
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        for (uint32 y = 0; y < 20; ++y)
        {
            g_ExpTable[x][y] = rset->get<uint16>(y);
        }

        ++x;
    }

    rset = db::preparedStmt("SELECT level, exp FROM exp_base LIMIT 100");
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        if (const auto level = rset->get<uint8>("level") - 1; level < 100)
        {
            g_ExpPerLevel[level] = rset->get<uint16>("exp");
        }
    }

    // run the function to fetch the /check difficulty curve.
    auto expDifficultyCurveFunction = lua["xi"]["expDifficultyCurve"]["loadExpDifficultyCurve"];

    if (!expDifficultyCurveFunction.valid())
    {
        ShowCritical("xi.expDifficultyCurve.loadExpDifficultyCurve function is not valid. Terminating.");
        std::terminate();
    }

    auto res = expDifficultyCurveFunction();
    if (!res.valid())
    {
        ShowCritical("xi.expDifficultyCurve.loadExpDifficultyCurve function failed to execute. Terminating.");
        std::terminate();
    }
}

void SetExpDifficultyCurve(std::vector<std::pair<uint16, EMobDifficulty>>& curve, std::pair<uint16, uint8>& incrediblyEasyPreyData)
{
    ExpToDifficultyTable    = curve;
    IncrediblyEasyPreyCheck = incrediblyEasyPreyData;
}
/************************************************************************
 *                                                                       *
 *  Return mob difficulty according to level difference                  *
 *                                                                       *
 ************************************************************************/

EMobDifficulty CheckMob(uint8 charlvl, CBattleEntity* PMob)
{
    auto moblvl = PMob ? PMob->GetMLevel() + PMob->getMod(Mod::EXP_LVL_MOD) : -1;

    uint32 baseExp = GetBaseExp(charlvl, moblvl);

    if (baseExp == 0)
    {
        return EMobDifficulty::TooWeak;
    }

    // Iterate over exp  difficulty table, populated similarly to
    // { 400, EMobDifficulty::IncrediblyTough }
    // { 350, EMobDifficulty::EMobDifficulty::VeryTough }
    for (auto& entry : ExpToDifficultyTable)
    {
        auto exp = entry.first;

        if (baseExp >= exp)
        {
            auto difficulty = entry.second;
            return difficulty;
        }
    }

    auto IEPExp   = IncrediblyEasyPreyCheck.first;
    auto IEPLevel = IncrediblyEasyPreyCheck.second;

    if (baseExp >= IEPExp && moblvl > IEPLevel)
    {
        return EMobDifficulty::IncrediblyEasyPrey;
    }

    return EMobDifficulty::TooWeak;
}

/************************************************************************
 *                                                                       *
 *  Unmodified EXP that the character will receive from the target       *
 *                                                                       *
 ************************************************************************/

uint32 GetBaseExp(uint8 charlvl, int16 moblvl)
{
    const int32 levelDif = moblvl - charlvl + 44;

    if (charlvl > 0 && charlvl < 100)
    {
        return g_ExpTable[std::clamp(levelDif, 0, ExpTableRowCount - 1)][(charlvl - 1) / 5];
    }

    return 0;
}

/************************************************************************
 *                                                                       *
 *  Calculate the amount of experience required to get the next level    *
 *                                                                       *
 ************************************************************************/

uint32 GetExpNEXTLevel(uint8 charlvl)
{
    if (charlvl > 0 && charlvl < 100)
    {
        return g_ExpPerLevel[charlvl];
    }
    return 0;
}

/************************************************************************
 *                                                                       *
 *  Distributes gil to party members.                                    *
 *                                                                       *
 ************************************************************************/

// TODO: REALISATION MUST BE IN TREASUREPOOL

void DistributeGil(CCharEntity* PChar, CMobEntity* PMob)
{
    TracyZoneScoped;

    // work out the amount of gil to give (guessed; replace with testing)
    uint32 gil    = PMob->GetRandomGil();
    uint32 gBonus = 0;

    if (gil && settings::get<float>("map.MOB_GIL_MULTIPLIER") >= 0.0f)
    {
        gil = static_cast<uint32>(gil * settings::get<float>("map.MOB_GIL_MULTIPLIER"));
    }

    if (settings::get<uint8>("map.ALL_MOBS_GIL_BONUS"))
    {
        gBonus = settings::get<uint8>("map.ALL_MOBS_GIL_BONUS") * PMob->GetMLevel();
        gil += std::clamp<uint32>(gBonus, 1, settings::get<uint32>("map.MAX_GIL_BONUS"));
    }

    // TODO: pin down moghancement money which seems to be a % bonus applied individually?
    // Gilfinder bonus is 1 + (128 + 0..GF level * 16)/256
    // https://docs.google.com/spreadsheets/d/134YjiVWoqn9UKOFrJFXZPHZChNa6heWzY0xXOGIteC8/edit
    if (PMob->m_GilfinderLevel > 0)
    {
        double multiplier = 1 + ((128 + xirand::GetRandomNumber<uint16_t>(0, PMob->m_GilfinderLevel * 16)) / 256.);

        gil = gil * multiplier;
    }

    int16 killshotBonus = PChar->getMod(Mod::MOGHANCEMENT_GIL_BONUS_P);
    if (killshotBonus > 0)
    {
        double multiplier = (100.0 + killshotBonus) / 100.0;

        gil = gil * multiplier;
    }

    // Distribute gil to player/party/alliance
    if (PChar->PParty != nullptr)
    {
        std::vector<CCharEntity*> members;

        // First gather all valid party members
        // clang-format off
            PChar->ForAlliance([PMob, &members](CBattleEntity* PPartyMember)
            {
                if (PPartyMember->getZone() == PMob->getZone() && isWithinDistance(PPartyMember->loc.p, PMob->loc.p, 100.0f)) // TODO: verify range
                {
                    members.emplace_back((CCharEntity*)PPartyMember);
                }
            });
        // clang-format on

        // all members might not be in range
        if (!members.empty())
        {
            // Calculate gil for each party member.
            uint32 gilPerPerson = static_cast<uint32>(gil / members.size());

            for (auto PMember : members)
            {
                UpdateItem(PMember, LOC_INVENTORY, 0, gilPerPerson);
                PMember->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PMember, PMember, gilPerPerson, 0, MsgBasic::Obtains);
            }
        }
    }
    else if (isWithinDistance(PChar->loc.p, PMob->loc.p, 100.0f))
    {
        UpdateItem(PChar, LOC_INVENTORY, 0, static_cast<int32>(gil));
        PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, static_cast<int32>(gil), 0, MsgBasic::Obtains);
    }
}

void DistributeItem(CCharEntity* PChar, CBaseEntity* PEntity, uint16 itemid, uint16 dropRate)
{
    TracyZoneScoped;

    auto   thDropRateFunction = lua["xi"]["combat"]["treasureHunter"]["getDropRate"];
    uint16 thDropRate         = dropRate * 10;

    if (auto* PMob = dynamic_cast<CMobEntity*>(PEntity))
    {
        thDropRate = thDropRateFunction(PMob->m_THLvl, thDropRate);
    }

    if (thDropRate > 0 && (1 + xirand::GetRandomNumber(10000)) <= thDropRate * settings::get<float>("map.DROP_RATE_MULTIPLIER"))
    {
        PChar->PTreasurePool->addItem(itemid, PEntity);
    }
}

double GetPlayerShareMultiplier(uint16 membersInZone, bool regionBuff)
{
    if (settings::get<bool>("main.DISABLE_PARTY_EXP_PENALTY"))
    {
        return 1.00;
    }

    // Alliance share
    if (membersInZone > 6)
    {
        return 2.0f / membersInZone;
    }

    // Party share
    if (regionBuff)
    {
        switch (membersInZone)
        {
            case 1:
                return 1.00;
            case 2:
                return 0.85;
            case 3:
                return 0.75;
            case 4:
                return 0.70;
            case 5:
                return 0.65;
            case 6:
                return 0.60;
            default:
                return 2.5 / membersInZone;
        }
    }
    else
    {
        switch (membersInZone)
        {
            case 1:
                return 1.00;
            case 2:
                return 0.85;
            case 3:
                return 0.75;
            case 4:
                return 0.70;
            case 5:
                return 0.65;
            case 6:
                return 0.60;
            default:
                return 2.5 / membersInZone;
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Allocate experience points                                           *
 *                                                                       *
 ************************************************************************/

static float GetChainDifficultyModifier(EMobDifficulty mobCheck)
{
    switch (mobCheck)
    {
        case EMobDifficulty::EasyPrey:
            return 0.85f;

        case EMobDifficulty::DecentChallenge:
            return 0.90f;

        case EMobDifficulty::EvenMatch:
            return 1.06f;

        case EMobDifficulty::Tough:
            return 1.15f;

        case EMobDifficulty::VeryTough:
            return 1.20f;

        case EMobDifficulty::IncrediblyTough:
            return 1.30f;

        default:
            return 1.00f;
    }
}

void DistributeExperiencePoints(CCharEntity* PChar, CMobEntity* PMob)
{
    TracyZoneScoped;

    uint8       pcinzone = 0;
    uint8       minlevel = 0;
    uint8       maxlevel = PChar->GetMLevel();
    REGION_TYPE region   = PChar->loc.zone->GetRegionID();

    if (PChar->PParty)
    {
        if (PChar->PParty->GetSyncTarget())
        {
            if (distance(PMob->loc.p, PChar->PParty->GetSyncTarget()->loc.p) >= 100 || PChar->PParty->GetSyncTarget()->health.hp == 0)
            {
                // clang-format off
                    PChar->ForParty([&PMob](CBattleEntity* PMember)
                    {
                        if (PMember->getZone() == PMob->getZone() && distance(PMember->loc.p, PMob->loc.p) < 100)
                        {
                            if (CCharEntity* PChar = dynamic_cast<CCharEntity*>(PMember))
                            {
                                PChar->pushPacket<GP_SERV_COMMAND_BATTLE_MESSAGE>(PChar, PChar, 0, 0, MsgBasic::LevelSyncNoExp);
                            }
                        }
                    });
                // clang-format on

                return;
            }
        }
    }

    // clang-format off
        PChar->ForAlliance([&pcinzone, &PMob, &minlevel, &maxlevel](CBattleEntity* PMember)
        {
            if (PMember->getZone() == PMob->getZone() && distance(PMember->loc.p, PMob->loc.p) < 100)
            {
                if (PMember->PPet != nullptr && PMember->PPet->GetMLevel() > maxlevel && PMember->PPet->objtype != TYPE_PET)
                {
                    maxlevel = PMember->PPet->GetMLevel();
                }
                if (PMember->GetMLevel() > maxlevel)
                {
                    maxlevel = PMember->GetMLevel();
                }
                else if (PMember->GetMLevel() < minlevel)
                {
                    minlevel = PMember->GetMLevel();
                }
                pcinzone++;
            }
        });
    // clang-format on

    pcinzone            = std::max(pcinzone, PMob->m_HiPartySize);
    maxlevel            = std::max(maxlevel, PMob->m_HiPCLvl);
    PMob->m_HiPartySize = pcinzone;
    PMob->m_HiPCLvl     = maxlevel;

    // clang-format off
        PChar->ForAlliance([&PMob, &region, &maxlevel, &pcinzone](CBattleEntity* PPartyMember)
        {
            CCharEntity* PMember = dynamic_cast<CCharEntity*>(PPartyMember);
            if (!PMember || PMember->isDead())
            {
                return;
            }

            bool chainactive = false;

            const int16 moblevel    = PMob->GetMLevel() + PMob->getMod(Mod::EXP_LVL_MOD);
            const uint8 memberlevel = PMember->GetMLevel();

            EMobDifficulty mobCheck = CheckMob(maxlevel, PMob);
            float          exp      = static_cast<float>(GetBaseExp(maxlevel, moblevel));

            if (mobCheck > EMobDifficulty::TooWeak)
            {
                if (PMember->getZone() == PMob->getZone())
                {
                    if (settings::get<bool>("map.EXP_PARTY_GAP_PENALTIES"))
                    {
                        uint8 partyGapNoExp = settings::get<uint8>("map.EXP_PARTY_GAP_NO_EXP");

                        if (partyGapNoExp > 0 && maxlevel >= (memberlevel + partyGapNoExp))
                        {
                            exp = 0;
                        }
                        else if (maxlevel > 50 || maxlevel > (memberlevel + 7))
                        {
                            exp *= memberlevel / (float)maxlevel;
                        }
                        else
                        {
                            exp *= GetExpNEXTLevel(memberlevel) / (float)GetExpNEXTLevel(maxlevel);
                        }
                    }

                    bool isInSignetZone =
                        PMember->StatusEffectContainer->HasStatusEffect(EFFECT_SIGNET) &&
                        region >= REGION_TYPE::RONFAURE &&
                        region <= REGION_TYPE::JEUNO;

                    bool isInSanctionZone =
                        PMember->StatusEffectContainer->HasStatusEffect(EFFECT_SANCTION) &&
                        region >= REGION_TYPE::WEST_AHT_URHGAN &&
                        region <= REGION_TYPE::ALZADAAL;

                    exp *= GetPlayerShareMultiplier(pcinzone, isInSignetZone || isInSanctionZone);

                    if (PMob->getMobMod(MOBMOD_EXP_BONUS))
                    {
                        const float monsterbonus = 1.0f + PMob->getMobMod(MOBMOD_EXP_BONUS) / 100.0f;
                        exp *= monsterbonus;
                    }
                        
                    // Per monster caps pulled from: https://ffxiclopedia.fandom.com/wiki/Experience_Points
                    if (PMember->GetMLevel() <= 50)
                    {
                        exp = std::fmin(exp, 400.0f);
                    }
                    else if (PMember->GetMLevel() <= 60)
                    {
                        exp = std::fmin(exp, 500.0f);
                    }
                    else
                    {
                        exp = std::fmin(exp, 600.0f);
                    }

                    // Skillchain / Magic Burst EXP Bonus (Sanctum custom)
                    // Bonus scales with the SC/MB damage dealt: bonus exp = exp * (accumulated dmg * pct), capped.
                    const uint32 scmbDmg = PMob->getSCMBExpBonusDmg();
                    if (scmbDmg > 0)
                    {
                        const float bonusMult = scmbDmg * (settings::get<float>("sanctum.SCMB_EXP_BONUS") / 100.0f);
                        float       expbonus  = exp * bonusMult;
                        expbonus              = std::clamp(expbonus, 0.0f, settings::get<float>("sanctum.SCMB_EXP_BONUS_CAP"));
                        exp += expbonus;
                    }

                    if (mobCheck > EMobDifficulty::TooWeak)
                    {
                        if (PMember->expChain.chainTime > timer::now() || PMember->expChain.chainTime == timer::time_point::min())
                        {
                            chainactive = true;
                            switch (PMember->expChain.chainNumber)
                            {
                                case 0:
                                    exp *= 1.0f;
                                    break;
                                case 1:
                                    exp *= 1.20;
                                    break;
                                case 2:
                                    exp *= 1.25;
                                    break;
                                case 3:
                                    exp *= 1.30f;
                                    break;
                                case 4:
                                    exp *= 1.35f;
                                    break;
                                case 5:
                                    exp *= 1.40f;
                                    break;
                                default:
                                    exp *= 1.50f;
                                    break;
                            }
                             exp *= GetChainDifficultyModifier(mobCheck);
                        }
                        else
                        {
                            if (PMember->GetMLevel() <= 10)
                            {
                                PMember->expChain.chainTime = timer::now() + 60s;
                            }
                            else if (PMember->GetMLevel() <= 20)
                            {
                                PMember->expChain.chainTime = timer::now() + 100s;
                            }
                            else if (PMember->GetMLevel() <= 30)
                            {
                                PMember->expChain.chainTime = timer::now() + 150s;
                            }
                            else if (PMember->GetMLevel() <= 40)
                            {
                                PMember->expChain.chainTime = timer::now() + 200s;
                            }
                            else if (PMember->GetMLevel() <= 50)
                            {
                                PMember->expChain.chainTime = timer::now() + 250s;
                            }
                            else if (PMember->GetMLevel() <= 60)
                            {
                                PMember->expChain.chainTime = timer::now() + 300s;
                            }
                            else
                            {
                                PMember->expChain.chainTime = timer::now() + 360s;
                            }
                            PMember->expChain.chainNumber = 1;
                        }

                        if (chainactive && PMember->GetMLevel() <= 10)
                        {
                            switch (PMember->expChain.chainNumber)
                            {
                                case 0:
                                    PMember->expChain.chainTime = timer::now() + 60s;
                                    break;
                                case 1:
                                    PMember->expChain.chainTime = timer::now() + 60s;
                                    break;
                                case 2:
                                    PMember->expChain.chainTime = timer::now() + 60s;
                                    break;
                                case 3:
                                    PMember->expChain.chainTime = timer::now() + 60s;
                                    break;
                                case 4:
                                    PMember->expChain.chainTime = timer::now() + 60s;
                                    break;
                                case 5:
                                    PMember->expChain.chainTime = timer::now() + 60s;
                                    break;
                                default:
                                    PMember->expChain.chainTime = timer::now() + 60s;
                                    break;
                            }
                        }
                        else if (chainactive && PMember->GetMLevel() <= 20)
                        {
                            switch (PMember->expChain.cha[Truncated]
