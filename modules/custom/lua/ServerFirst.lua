-----------------------------------
-- Server First
--
-- Sanctum's server-wide first-achievement system.
--
-- Title note:
--   setTitle() both makes a title active and permanently unlocks it. DAT edits have to be done for new custom titles perachievement.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/battlefield')
require('scripts/globals/dynamis')
require('scripts/globals/mobs')
require('scripts/globals/missions')
require('scripts/globals/player')

local m = Module:new('ServerFirst')

local decoration =
{
    standard = '\129\154', -- gold star
    legendary = '\129\159',
}

local function eventKey(part)
    return string.gsub(string.lower(part), '[^a-z0-9]+', '_')
end

local function addNMEVent(tableRef, mobName, displayName, zoneName, title)
    tableRef[mobName] =
    {
        eventKey = 'nm.' .. eventKey(displayName),
        display = displayName,
        zone = zoneName,
        title = title,
    }
end

-- Some of these enemies are Nyzul/battlefield versions so they don't count as server firsts.
local nmEvents = {}
addNMEVent(nmEvents, 'Jaggedy-Eared_Jack',       'Jaggedy-Eared Jack',       'West_Ronfaure')
addNMEVent(nmEvents, 'Leaping_Lizzy',            'Leaping Lizzy',            'South_Gustaberg')
addNMEVent(nmEvents, 'Valkurm_Emperor',          'Valkurm Emperor',          'Valkurm_Dunes')
addNMEVent(nmEvents, 'Argus',                    'Argus',                    'Maze_of_Shakhrami')
addNMEVent(nmEvents, 'Lord_of_Onzozo',           'Lord of Onzozo',           'Labyrinth_of_Onzozo')
addNMEVent(nmEvents, 'Hakutaku',                 'Hakutaku',                 'Den_of_Rancor')
addNMEVent(nmEvents, 'Charybdis',                'Charybdis',                'Sea_Serpent_Grotto')
addNMEVent(nmEvents, 'Bune',                     'Bune',                     'Gustav_Tunnel')
addNMEVent(nmEvents, 'Guivre',                   'Guivre',                   'Kuftal_Tunnel')
addNMEVent(nmEvents, 'King_Arthro',              'King Arthro',              'Jugner_Forest')
addNMEVent(nmEvents, 'Roc',                      'Roc',                      'Sauromugue_Champaign')
addNMEVent(nmEvents, 'Simurgh',                  'Simurgh',                  'Rolanberry_Fields')
addNMEVent(nmEvents, 'Serket',                   'Serket',                   'Garlaige_Citadel', xi.title.SERKET_BREAKER)
addNMEVent(nmEvents, 'Capricious_Cassie',        'Capricious Cassie',        'FeiYin', xi.title.CASSIENOVA)
addNMEVent(nmEvents, 'Lumber_Jack',              'Lumber Jack',              'Batallia_Downs')
addNMEVent(nmEvents, 'King_Vinegarroon',         'King Vinegarroon',         'Western_Altepa_Desert', xi.title.VINEGAR_EVAPORATOR)
addNMEVent(nmEvents, 'Behemoth',                 'Behemoth',                 'Behemoths_Dominion', xi.title.BEHEMOTHS_BANE)
addNMEVent(nmEvents, 'Adamantoise',              'Adamantoise',              'Valley_of_Sorrows')
addNMEVent(nmEvents, 'Fafnir',                   'Fafnir',                   'Dragons_Aery', xi.title.FAFNIR_SLAYER)
addNMEVent(nmEvents, 'King_Behemoth',            'King Behemoth',            'Behemoths_Dominion', xi.title.BEHEMOTH_DETHRONER)
addNMEVent(nmEvents, 'Aspidochelone',            'Aspidochelone',            'Valley_of_Sorrows', xi.title.ASPIDOCHELONE_SINKER)
addNMEVent(nmEvents, 'Nidhogg',                  'Nidhogg',                  'Dragons_Aery', xi.title.NIDHOGG_SLAYER)
addNMEVent(nmEvents, 'Tiamat',                   'Tiamat',                   'Attohwa_Chasm', xi.title.TIAMAT_TROUNCER)
addNMEVent(nmEvents, 'Jormungand',               'Jormungand',               'Uleguerand_Range', xi.title.WORLD_SERPENT_SLAYER)
addNMEVent(nmEvents, 'Vrtra',                    'Vrtra',                    'King_Ranperres_Tomb', xi.title.VRTRA_VANQUISHER)
addNMEVent(nmEvents, 'Hydra',                    'Hydra',                    'Wajaom_Woodlands', xi.title.HYDRA_HEADHUNTER)
addNMEVent(nmEvents, 'Cerberus',                 'Cerberus',                 'Mount_Zhayolm', xi.title.CERBERUS_MUZZLER)
addNMEVent(nmEvents, 'Khimaira',                 'Khimaira',                 'Caedarva_Mire', xi.title.KHIMAIRA_CARVER)
addNMEVent(nmEvents, 'Dark_Ixion',               'Dark Ixion') -- roams multiple Wings of the Goddess zones
addNMEVent(nmEvents, 'Sandworm',                 'Sandworm') -- roams multiple zones
addNMEVent(nmEvents, 'Overlord_Bakgodek',        'Overlord Bakgodek',        'Monastic_Cavern', xi.title.OVERLORD_OVERTHROWER)
addNMEVent(nmEvents, "Za'Dha_Adamantking",      "Za'Dha Adamantking",      'Castle_Oztroja')
addNMEVent(nmEvents, 'Tzee_Xicu_the_Manifest',  'Tzee Xicu the Manifest',  'Castle_Oztroja', xi.title.DEITY_DEBUNKER)
addNMEVent(nmEvents, 'Gulool_Ja_Ja',             'Gulool Ja Ja',             'Mamook', xi.title.SHINING_SCALE_RIFLER)
addNMEVent(nmEvents, 'Gurfurlur_the_Menacing',  'Gurfurlur the Menacing',  'Halvung', xi.title.TROLL_SUBJUGATOR)
addNMEVent(nmEvents, 'Medusa',                   'Medusa',                   'Arrapago_Reef', xi.title.GORGONSTONE_SUNDERER)
addNMEVent(nmEvents, 'Genbu',                    'Genbu',                    'RuAun_Gardens')
addNMEVent(nmEvents, 'Seiryu',                   'Seiryu',                   'RuAun_Gardens')
addNMEVent(nmEvents, 'Suzaku',                   'Suzaku',                   'RuAun_Gardens')
addNMEVent(nmEvents, 'Byakko',                   'Byakko',                   'RuAun_Gardens')
addNMEVent(nmEvents, 'Kirin',                    'Kirin',                    'The_Shrine_of_RuAvitau', xi.title.KIRIN_CAPTIVATOR)
addNMEVent(nmEvents, 'Jailer_of_Temperance',     'Jailer of Temperance',     'Grand_Palace_of_HuXzoi')
addNMEVent(nmEvents, 'Jailer_of_Fortitude',      'Jailer of Fortitude',      'The_Garden_of_RuHmet')
addNMEVent(nmEvents, 'Jailer_of_Faith',          'Jailer of Faith',          'The_Garden_of_RuHmet')
addNMEVent(nmEvents, 'Jailer_of_Justice',        'Jailer of Justice',        'AlTaieu')
addNMEVent(nmEvents, 'Jailer_of_Hope',           'Jailer of Hope',           'AlTaieu')
addNMEVent(nmEvents, 'Jailer_of_Prudence',       'Jailer of Prudence',       'AlTaieu')
addNMEVent(nmEvents, 'Jailer_of_Love',           'Jailer of Love',           'AlTaieu')
addNMEVent(nmEvents, 'Absolute_Virtue',          'Absolute Virtue',          'AlTaieu', xi.title.VIRTUOUS_SAINT)
addNMEVent(nmEvents, 'Tinnin',                   'Tinnin',                   'Wajaom_Woodlands')
addNMEVent(nmEvents, 'Sarameya',                 'Sarameya',                 'Mount_Zhayolm')
addNMEVent(nmEvents, 'Tyger',                    'Tyger',                    'Caedarva_Mire')
addNMEVent(nmEvents, 'Pandemonium_Warden',       'Pandemonium Warden',       'Aydeewa_Subterrane', xi.title.PANDEMONIUM_QUELLER)
addNMEVent(nmEvents, 'Proto-Omega',              'Proto-Omega',              'Apollyon')
addNMEVent(nmEvents, 'Proto-Ultima',              'Proto-Ultima',             'Temenos')


local craftEvents =
{
    [12579] = { eventKey = 'craft.scorpion_harness',       display = 'Scorpion Harness' },
    [13734] = { eventKey = 'craft.scorpion_harness_plus1', display = 'Scorpion Harness +1' },
    [12555] = { eventKey = 'craft.haubergeon',             display = 'Haubergeon' },
    [13735] = { eventKey = 'craft.haubergeon_plus1',       display = 'Haubergeon +1' },
    [12556] = { eventKey = 'craft.hauberk',                display = 'Hauberk' },
    [13793] = { eventKey = 'craft.hauberk_plus1',          display = 'Hauberk +1' },
    [13748] = { eventKey = 'craft.vermillion_cloak',       display = 'Vermillion Cloak' },
    [13749] = { eventKey = 'craft.royal_cloak',            display = 'Royal Cloak' },
    [12605] = { eventKey = 'craft.nobles_tunic',           display = "Noble's Tunic" },
    [13774] = { eventKey = 'craft.aristocrats_coat',       display = "Aristocrat's Coat" },
    [13779] = { eventKey = 'craft.black_cloak',            display = 'Black Cloak' },
    [13780] = { eventKey = 'craft.demons_cloak',           display = "Demon's Cloak" },
    [13645] = { eventKey = 'craft.amemet_mantle',          display = 'Amemet Mantle' },
    [13646] = { eventKey = 'craft.amemet_mantle_plus1',    display = 'Amemet Mantle +1' },
    [13587] = { eventKey = 'craft.rainbow_cape',           display = 'Rainbow Cape' },
    [13627] = { eventKey = 'craft.prism_cape',             display = 'Prism Cape' },
    [16212] = { eventKey = 'craft.cerberus_mantle',        display = 'Cerberus Mantle' },
    [16216] = { eventKey = 'craft.cerberus_mantle_plus1',  display = 'Cerberus Mantle +1' },
    [17251] = { eventKey = 'craft.hellfire',               display = 'Hellfire' },
    [17264] = { eventKey = 'craft.hellfire_plus1',         display = 'Hellfire +1' },
    [17552] = { eventKey = 'craft.terras_staff',           display = "Terra's Staff" },
    [17553] = { eventKey = 'craft.thunder_staff',          display = 'Thunder Staff' },
    [17554] = { eventKey = 'craft.jupiters_staff',         display = "Jupiter's Staff" },
    [17555] = { eventKey = 'craft.water_staff',            display = 'Water Staff' },
    [17556] = { eventKey = 'craft.neptunes_staff',         display = "Neptune's Staff" },
    [17557] = { eventKey = 'craft.light_staff',            display = 'Light Staff' },
    [17558] = { eventKey = 'craft.apollos_staff',          display = "Apollo's Staff" },
    [17559] = { eventKey = 'craft.dark_staff',             display = 'Dark Staff' },
    [17560] = { eventKey = 'craft.plutos_staff',           display = "Pluto's Staff" },
}

-- The C++ companion loads the rest of the in-era catalogue from the recipe
-- database at boot: every Cursed -1 item at its normal rank, and every +1
-- output requiring a 100+ craft skill. Keep the entries above for their
-- deliberately curated spelling, while the data-driven catalogue prevents
-- this module becoming stale or doing database work during synthesis.

local specialItemEvents =
{
    [xi.item.MAATS_CAP] =
    {
        eventKey = 'achievement.maats_cap',
        category = 'achievement',
        subject = "Maat's Cap",
        title = xi.title.MAAT_MASHER,
        message = function(player)
            return string.format("SERVER FIRST! %s has claimed Maat's Cap!", player:getName())
        end,
    },
    [14371] =
    {
        eventKey = 'craft.armada_hauberk',
        category = 'craft',
        subject = 'Armada Hauberk',
        message = function(player)
            return string.format('SERVER FIRST! Armada Hauberk has been restored by %s!', player:getName())
        end,
    },
}

local legendaryWeapons =
{
    [15070] = { name = 'Aegis',        kind = 'relic' },
    [18264] = { name = 'Spharai',      kind = 'relic' },
    [18270] = { name = 'Mandau',       kind = 'relic' },
    [18276] = { name = 'Excalibur',    kind = 'relic' },
    [18282] = { name = 'Ragnarok',     kind = 'relic' },
    [18288] = { name = 'Guttler',      kind = 'relic' },
    [18294] = { name = 'Bravura',      kind = 'relic' },
    [18300] = { name = 'Gungnir',      kind = 'relic' },
    [18306] = { name = 'Apocalypse',   kind = 'relic' },
    [18312] = { name = 'Kikoku',       kind = 'relic' },
    [18318] = { name = 'Amanomurakumo', kind = 'relic' },
    [18324] = { name = 'Mjollnir',     kind = 'relic' },
    [18330] = { name = 'Claustrum',    kind = 'relic' },
    [18336] = { name = 'Annihilator',  kind = 'relic' },
    [18342] = { name = 'Gjallarhorn',  kind = 'relic' },
    [18348] = { name = 'Yoichinoyumi', kind = 'relic' },
    [18989] = { name = 'Terpsichore',  kind = 'mythic' },
    [18990] = { name = 'Tupsimati',    kind = 'mythic' },
    [18991] = { name = 'Conqueror',    kind = 'mythic' },
    [18992] = { name = 'Glanzfaust',   kind = 'mythic' },
    [18993] = { name = 'Yagrush',      kind = 'mythic' },
    [18994] = { name = 'Laevateinn',   kind = 'mythic' },
    [18995] = { name = 'Murgleis',     kind = 'mythic' },
    [18996] = { name = 'Vajra',        kind = 'mythic' },
    [18997] = { name = 'Burtgang',     kind = 'mythic' },
    [18998] = { name = 'Liberator',    kind = 'mythic' },
    [18999] = { name = 'Aymur',        kind = 'mythic' },
    [19000] = { name = 'Carnwenhan',   kind = 'mythic' },
    [19001] = { name = 'Gastraphetes', kind = 'mythic' },
    [19002] = { name = 'Kogarasumaru', kind = 'mythic' },
    [19003] = { name = 'Nagi',         kind = 'mythic' },
    [19004] = { name = 'Ryunohige',    kind = 'mythic' },
    [19005] = { name = 'Nirvana',      kind = 'mythic' },
    [19006] = { name = 'Tizona',       kind = 'mythic' },
    [19007] = { name = 'Death Penalty', kind = 'mythic' },
    [19008] = { name = 'Kenkonken',    kind = 'mythic' },
}

local trackedItemIds = {}
for itemId in pairs(specialItemEvents) do
    table.insert(trackedItemIds, itemId)
end
for itemId in pairs(legendaryWeapons) do
    table.insert(trackedItemIds, itemId)
end
xi.serverFirstConfig = { trackedItemIds = trackedItemIds }

local skillMilestones =
{
    [xi.skill.WOODWORKING]  = { name = 'Woodworking',  title = xi.title.LEGENDARY_WOODWORKER },
    [xi.skill.SMITHING]     = { name = 'Smithing',     title = xi.title.LEGENDARY_BLACKSMITH },
    [xi.skill.GOLDSMITHING] = { name = 'Goldsmithing', title = xi.title.LEGENDARY_GOLDSMITH },
    [xi.skill.CLOTHCRAFT]   = { name = 'Clothcraft',   title = xi.title.LEGENDARY_WEAVER },
    [xi.skill.LEATHERCRAFT] = { name = 'Leathercraft', title = xi.title.LEGENDARY_TANNER },
    [xi.skill.BONECRAFT]    = { name = 'Bonecraft',    title = xi.title.LEGENDARY_BONEWORKER },
    [xi.skill.ALCHEMY]      = { name = 'Alchemy',      title = xi.title.LEGENDARY_ALCHEMIST },
    [xi.skill.COOKING]      = { name = 'Cooking',      title = xi.title.LEGENDARY_CULINARIAN },
}

local battlefieldEvents = {}
local function addBattlefieldEvent(enumName, displayName, title)
    local id = xi.battlefield.id[enumName]
    if type(id) ~= 'number' then
        print(string.format('[ServerFirst] Battlefield ID %s is unavailable; entry skipped.', enumName))
        return
    end

    battlefieldEvents[id] =
    {
        eventKey = 'battlefield.' .. eventKey(displayName),
        display = displayName,
        title = title,
    }
end

-- Level 20 and 30
addBattlefieldEvent('CHARMING_TRIO', 'Charming Trio')
addBattlefieldEvent('CRUSTACEAN_CONUNDRUM', 'Crustacean Conundrum')
addBattlefieldEvent('SHOOTING_FISH', 'Shooting Fish')
addBattlefieldEvent('WINGS_OF_FURY', 'Wings of Fury')
-- Level 30
addBattlefieldEvent('BIRDS_OF_A_FEATHER', 'Birds of a Feather')
addBattlefieldEvent('CARAPACE_COMBATANTS', 'Carapace Combatants')
addBattlefieldEvent('CREEPING_DOOM', 'Creeping Doom')
addBattlefieldEvent('DIE_BY_THE_SWORD', 'Die by the Sword')
addBattlefieldEvent('DROPPING_LIKE_FLIES', 'Dropping Like Flies')
addBattlefieldEvent('GROVE_GUARDIANS', 'Grove Guardians')
addBattlefieldEvent('HAREM_SCAREM', 'Harem Scarem')
addBattlefieldEvent('LET_SLEEPING_DOGS_DIE', 'Let Sleeping Dogs Lie')
addBattlefieldEvent('PETRIFYING_PAIR', 'Petrifying Pair')
addBattlefieldEvent('TOADAL_RECALL', 'Toadal Recall')
-- Level 40
addBattlefieldEvent('FACTORY_REJECTS', 'Factory Rejects')
addBattlefieldEvent('ROYAL_JELLY', 'Royal Jelly')
addBattlefieldEvent('ROYAL_SUCCESSION', 'Royal Succession')
addBattlefieldEvent('STEAMED_SPROUTS', 'Steamed Sprouts')
addBattlefieldEvent('TAILS_OF_WOE', 'Tails of Woe')
addBattlefieldEvent('WORMS_TURN', "The Worm's Turn")
addBattlefieldEvent('UNDER_OBSERVATION', 'Under Observation')
addBattlefieldEvent('UNDYING_PROMISE', 'Undying Promise')
-- Level 50
addBattlefieldEvent('THREE_TWO_ONE', '3, 2, 1...')
addBattlefieldEvent('AWFUL_AUTOPSY', 'An Awful Autopsy')
addBattlefieldEvent('EYE_OF_THE_TIGER', 'Eye of the Tiger')
addBattlefieldEvent('HOSTILE_HERBIVORES', 'Hostile Herbivores')
addBattlefieldEvent('IDOL_THOUGHTS', 'Idol Thoughts')
addBattlefieldEvent('RAPID_RAPTORS', 'Rapid Raptors')
addBattlefieldEvent('FINAL_BOUT', 'The Final Bout')
addBattlefieldEvent('TREASURE_AND_TRIBULATIONS', 'Treasure and Tribulations')
-- Level 60
addBattlefieldEvent('AMPHIBIAN_ASSAULT', 'Amphibian Assault')
addBattlefieldEvent('BROTHERS_D_AURPHE', "Brothers D'Aurphe")
addBattlefieldEvent('CELERY', 'Celery')
addBattlefieldEvent('DEMOLITION_SQUAD', 'Demolition Squad')
addBattlefieldEvent('DISMEMBERMENT_BRIGADE', 'Dismemberment Brigade')
addBattlefieldEvent('DIVINE_PUNISHERS', 'Divine Punishers')
addBattlefieldEvent('GRIMSHELL_SHOCKTROOPERS', 'Grimshell Shocktroopers')
addBattlefieldEvent('JUNGLE_BOOGYMEN', 'Jungle Boogymen')
addBattlefieldEvent('KINDRED_SPIRITS', 'Kindred Spirits')
addBattlefieldEvent('LEGION_XI_COMITATENSIS', 'Legion XI Comitatensis')
addBattlefieldEvent('SHOTS_IN_THE_DARK', 'Shots in the Dark')
addBattlefieldEvent('UP_IN_ARMS', 'Up in Arms')
addBattlefieldEvent('WILD_WILD_WHISKERS', 'Wild Wild Whiskers')
-- Uncapped Kindred Seal and misc
addBattlefieldEvent('CACTUAR_SUAVE', 'Cactuar Suave')
addBattlefieldEvent('COME_INTO_MY_PARLOR', 'Come Into My Parlor')
addBattlefieldEvent('CONTAMINATED_COLOSSEUM', 'Contaminated Colosseum')
addBattlefieldEvent('COPYCAT', 'Copycat')
addBattlefieldEvent('DOUBLE_DRAGONIAN', 'Double Dragonian')
addBattlefieldEvent('E_VASE_IVE_ACTION', 'E-vase-ive Action')
addBattlefieldEvent('EYE_OF_THE_STORM', 'Eye of the Storm')
addBattlefieldEvent('INFERNAL_SWARM', 'Infernal Swarm')
addBattlefieldEvent('MOA_CONSTRICTORS', 'Moa Constrictors')
addBattlefieldEvent('OPERATION_DESERT_SWARM', 'Operation Desert Swarm')
addBattlefieldEvent('PREHISTORIC_PIGEONS', 'Prehistoric Pigeons')
addBattlefieldEvent('ROYALE_RAMBLE', 'Royale Ramble')
addBattlefieldEvent('SEASONS_GREETINGS', 'Seasons Greetings')
addBattlefieldEvent('SCARLET_KING', 'The Scarlet King')
addBattlefieldEvent('TODAYS_HOROSCOPE', "Today's Horoscope")
addBattlefieldEvent('EARLY_BIRD_CATCHES_THE_WYRM', 'Early Bird Catches the Wyrm')
addBattlefieldEvent('HORNS_OF_WAR', 'Horns of War')
addBattlefieldEvent('HILLS_ARE_ALIVE', 'The Hills Are Alive')
-- High-end battlefields
addBattlefieldEvent('OURYU_COMETH', 'Ouryu Cometh')
addBattlefieldEvent('WYRMKING_DESCENDS', 'The Wyrmking Descends')
addBattlefieldEvent('DIVINE_MIGHT', 'Divine Might')
addBattlefieldEvent('APOCALYPSE_NIGH', 'Apocalypse Nigh', xi.title.AVERTER_OF_THE_APOCALYPSE)

local missionEvents =
{
    [string.format('%u:%u', xi.mission.log_id.ZILART, xi.mission.id.zilart.AWAKENING)] =
    {
        eventKey = 'mission.rise_of_the_zilart',
        display = 'The Rise of the Zilart saga',
    },
    [string.format('%u:%u', xi.mission.log_id.COP, xi.mission.id.cop.DAWN)] =
    {
        eventKey = 'mission.chains_of_promathia',
        display = 'The Chains of Promathia saga',
    },
    [string.format('%u:%u', xi.mission.log_id.TOAU, xi.mission.id.toau.ETERNAL_MERCENARY)] =
    {
        eventKey = 'mission.treasures_of_aht_urhgan',
        display = 'The Treasures of Aht Urhgan saga',
    },
}

local dynamisEvents =
{
    Dynamis_San_dOria = { display = 'Dynamis-San d’Oria', title = xi.title.DYNAMIS_SAN_DORIA_INTERLOPER },
    ['Dynamis-Bastok'] = { display = 'Dynamis-Bastok', title = xi.title.DYNAMIS_BASTOK_INTERLOPER },
    ['Dynamis-Windurst'] = { display = 'Dynamis-Windurst', title = xi.title.DYNAMIS_WINDURST_INTERLOPER },
    ['Dynamis-Jeuno'] = { display = 'Dynamis-Jeuno', title = xi.title.DYNAMIS_JEUNO_INTERLOPER },
    ['Dynamis-Beaucedine'] = { display = 'Dynamis-Beaucedine', title = xi.title.DYNAMIS_BEAUCEDINE_INTERLOPER },
    ['Dynamis-Xarcabard'] = { display = 'Dynamis-Xarcabard', title = xi.title.DYNAMIS_XARCABARD_INTERLOPER },
    ['Dynamis-Valkurm'] = { display = 'Dynamis-Valkurm', title = xi.title.DYNAMIS_VALKURM_INTERLOPER },
    ['Dynamis-Buburimu'] = { display = 'Dynamis-Buburimu', title = xi.title.DYNAMIS_BUBURIMU_INTERLOPER },
    ['Dynamis-Qufim'] = { display = 'Dynamis-Qufim', title = xi.title.DYNAMIS_QUFIM_INTERLOPER },
    ['Dynamis-Tavnazia'] = { display = 'Dynamis-Tavnazia', title = xi.title.DYNAMIS_TAVNAZIA_INTERLOPER },
}

dynamisEvents['Dynamis-San_dOria'] = dynamisEvents.Dynamis_San_dOria
dynamisEvents.Dynamis_San_dOria = nil
dynamisEvents['Dynamis-San_dOria'].display = "Dynamis-San d'Oria"

for _, event in pairs(dynamisEvents) do
    event.eventKey = 'dynamis.' .. eventKey(event.display)
end

local function participantFor(entity)
    if not xi.serverFirst or not xi.serverFirst.participant or not entity or not entity:isPC() then
        return nil
    end

    local participant = xi.serverFirst.participant(entity)
    if not participant or not participant.char_id or participant.char_id == 0 then
        return nil
    end

    return
    {
        entity = entity,
        char_id = participant.char_id,
        char_name = participant.char_name,
        linkshell_name = participant.linkshell_name or '',
        is_party_leader = participant.is_party_leader or false,
        is_alliance_leader = participant.is_alliance_leader or false,
        is_leader = false,
    }
end

local function collectParticipants(entities, zoneId)
    local participants = {}
    local seen = {}

    for _, entity in pairs(entities) do
        if entity and entity:isPC() and (not zoneId or entity:getZoneID() == zoneId) then
            local participant = participantFor(entity)
            if participant and not seen[participant.char_id] then
                seen[participant.char_id] = true
                table.insert(participants, participant)
            end
        end
    end

    table.sort(participants, function(a, b)
        return a.char_id < b.char_id
    end)

    return participants
end

local function collectAllianceParticipants(player, zoneId)
    return collectParticipants(player:getAlliance(), zoneId)
end

local function resolveAttribution(participants)
    if #participants == 0 then
        return 'unknown', 'unknown', 'an uncredited group'
    end

    local linkshells = {}
    local linkshellWinner = nil
    local linkshellCount = 0

    for _, participant in ipairs(participants) do
        local linkshell = participant.linkshell_name
        if linkshell ~= '' then
            linkshells[linkshell] = (linkshells[linkshell] or 0) + 1
        end
    end

    for linkshell, count in pairs(linkshells) do
        if count * 2 >= #participants and (count > linkshellCount or (count == linkshellCount and (not linkshellWinner or linkshell < linkshellWinner))) then
            linkshellWinner = linkshell
            linkshellCount = count
        end
    end

    if linkshellWinner then
        for _, participant in ipairs(participants) do
            participant.is_leader = false
        end

        return 'linkshell', linkshellWinner, string.format('the linkshell %s', linkshellWinner)
    end

    local wantAllianceLeader = #participants > 6
    local leader = nil
    for _, participant in ipairs(participants) do
        if (wantAllianceLeader and participant.is_alliance_leader) or (not wantAllianceLeader and participant.is_party_leader) then
            leader = participant
            break
        end
    end
    leader = leader or participants[1]
    leader.is_leader = true

    if wantAllianceLeader then
        return 'alliance', leader.char_name, string.format('an alliance led by %s', leader.char_name)
    end

    return 'party', leader.char_name, string.format("%s's party", leader.char_name)
end

local function decorate(message, kind)
    local mark = decoration[kind or 'standard']
    return string.format('%s %s %s', mark, message, mark)
end

local function awardTitle(participants, title)
    if not title then
        return
    end

    for _, participant in ipairs(participants) do
        participant.entity:setTitle(title)
    end
end

local function announceFirst(definition, participants, announcer, message, creditType, creditName, title)
    if #participants == 0 or not announcer or not xi.serverFirst or not xi.serverFirst.claim then
        return false
    end

    creditType = creditType or 'player'
    creditName = creditName or participants[1].char_name
    local decorated = decorate(message, definition.decoration)

    if not xi.serverFirst.claim(
        {
            event_key = definition.eventKey,
            category = definition.category or 'server_first',
            subject = definition.display or definition.subject,
            credit_type = creditType,
            credit_name = creditName,
            zone_id = announcer:getZoneID(),
            message = decorated,
            participants = participants,
        })
    then
        return false
    end

    awardTitle(participants, title or definition.title)
    announcer:printToArea(decorated, xi.msg.channel.SYSTEM_3, xi.msg.area.SYSTEM, '', false)
    return true
end

local function announceSolo(definition, player, message)
    local participants = collectParticipants({ player }, player:getZoneID())
    if #participants ~= 1 then
        return false
    end

    participants[1].is_leader = true
    return announceFirst(definition, participants, player, message, 'player', participants[1].char_name)
end

local function announceLegend(player, itemId, weapon)
    local participant = participantFor(player)
    if not participant or not xi.serverFirst or not xi.serverFirst.recordLegend then
        return
    end

    participant.is_leader = true
    local firstDefinition =
    {
        eventKey = 'legend.first_weapon',
        category = 'legendary_weapon',
        display = 'first relic or mythic weapon',
        decoration = 'legendary',
    }

    local achievementText = weapon.kind == 'mythic' and
        string.format('awakened the mythic weapon %s', weapon.name) or
        string.format('restored the legendary relic weapon %s', weapon.name)

    -- The permanent every-weapon record must succeed before either kind of
    -- legendary notice is sent.  A first-event row alone is not enough: the
    -- all-legends archive is part of the feature's guarantee.
    if not xi.serverFirst.recordLegend(
        {
            char_id = participant.char_id,
            char_name = participant.char_name,
            weapon_id = itemId,
            weapon_name = weapon.name,
            weapon_kind = weapon.kind,
            zone_id = player:getZoneID(),
        })
    then
        return
    end

    local isFirst = announceFirst(
        firstDefinition,
        { participant },
        player,
        string.format('SERVER FIRST! A NEW LEGEND IS WRITTEN! %s has %s!', player:getName(), achievementText),
        'player',
        participant.char_name)

    if not isFirst then
        player:printToArea(
            decorate(string.format('A NEW LEGEND IS WRITTEN! %s has %s!', player:getName(), achievementText), 'legendary'),
            xi.msg.channel.SYSTEM_3,
            xi.msg.area.SYSTEM,
            '',
            false)
    end
end

local function receivedItem(player, itemId)
    local special = specialItemEvents[itemId]
    if special then
        announceSolo(special, player, special.message(player))
    end

    local weapon = legendaryWeapons[itemId]
    if weapon then
        announceLegend(player, itemId, weapon)
    end
end

m:addOverride('xi.mob.onMobDeathEx', function(mob, player, isKiller, isWeaponSkillKill)
    super(mob, player, isKiller, isWeaponSkillKill)

    -- Triggers once per eligible alliance member.
    if not isKiller then
        return
    end

    local definition = nmEvents[mob:getName()]
    if not definition or (definition.zone and definition.zone ~= mob:getZoneName()) then
        return
    end

    local participants = collectAllianceParticipants(player, mob:getZoneID())
    local creditType, creditName, creditPhrase = resolveAttribution(participants)
    announceFirst(
        definition,
        participants,
        player,
        string.format('SERVER FIRST! %s has been defeated by %s!', definition.display, creditPhrase),
        creditType,
        creditName)
end)

m:addOverride('xi.player.onPlayerLevelUp', function(player, ...)
    super(player, ...)

    if player:getMainLvl() ~= 75 then
        return
    end

    local playerName = player:getName()
    announceSolo(
        {
            eventKey = 'level.first_75',
            category = 'level',
            display = 'level 75',
        },
        player,
        string.format("SERVER FIRST! %s has become Vana'diel's first level 75 adventurer!", playerName))

    local jobId = player:getMainJob()
    local jobName = xi.jobName[jobId] and xi.jobName[jobId][2]
    local jobKey = xi.jobName[jobId] and xi.jobName[jobId][1]
    if jobName and jobKey then
        announceSolo(
            {
                eventKey = 'level.first_75_' .. string.lower(jobKey),
                category = 'level',
                display = 'level 75 ' .. jobName,
            },
            player,
            string.format("SERVER FIRST! %s has become Vana'diel's first level 75 %s!", playerName, jobName))
    end
end)

m:addOverride('xi.player.onPlayerCraftSkillUp', function(player, skillType, oldSkill, newSkill)
    super(player, skillType, oldSkill, newSkill)

    local craft = skillMilestones[skillType]
    if not craft or oldSkill >= 1000 or newSkill < 1000 then
        return
    end

    announceSolo(
        {
            eventKey = 'craft.first_100_' .. eventKey(craft.name),
            category = 'craft_skill',
            display = craft.name .. ' 100',
            title = craft.title,
        },
        player,
        string.format('SERVER FIRST! %s has become Vana\'diel\'s first %s 100 artisan!', player:getName(), craft.name))
end)

m:addOverride('xi.player.onPlayerSynthesis', function(player, itemId, quantity, skillType)
    super(player, itemId, quantity, skillType)

    local definition = craftEvents[itemId]
    if not definition and xi.serverFirst and xi.serverFirst.getHighSkillCraftName then
        local display = xi.serverFirst.getHighSkillCraftName(itemId)
        if display then
            definition =
            {
                -- Item IDs make the archived first-event key unambiguous even
                -- if two item names differ only by punctuation.
                eventKey = string.format('craft.item_%u', itemId),
                display = display,
                category = 'craft',
            }
        end
    end

    if definition then
        definition.category = definition.category or 'craft'
        announceSolo(
            definition,
            player,
            string.format('SERVER FIRST! A %s has been crafted by %s!', definition.display, player:getName()))
    end
end)

m:addOverride('xi.player.onPlayerMissionComplete', function(player, logId, missionId)
    super(player, logId, missionId)

    local definition = missionEvents[string.format('%u:%u', logId, missionId)]
    if not definition then
        return
    end

    local participants = collectAllianceParticipants(player, player:getZoneID())
    local creditType, creditName, creditPhrase = resolveAttribution(participants)
    announceFirst(
        definition,
        participants,
        player,
        string.format('SERVER FIRST! %s has been completed by %s!', definition.display, creditPhrase),
        creditType,
        creditName)
end)

m:addOverride('xi.player.onPlayerRankChange', function(player, nation, rank)
    super(player, nation, rank)

    if rank ~= 10 then
        return
    end

    local nationNames =
    {
        [xi.nation.SANDORIA] = 'San d’Orian',
        [xi.nation.BASTOK] = 'Bastokan',
        [xi.nation.WINDURST] = 'Windurstian',
    }
    local nationName = nationNames[nation]
    nationName = nation == xi.nation.SANDORIA and "San d'Orian" or nationName
    if nationName then
        announceSolo(
            {
                eventKey = 'rank.first_10_' .. eventKey(nationName),
                category = 'rank',
                display = nationName .. ' Rank 10',
            },
            player,
            string.format('SERVER FIRST! %s has become the first %s Rank 10 adventurer!', player:getName(), nationName))
    end
end)

m:addOverride('Battlefield.onBattlefieldStatusChange', function(self, battlefield, status)
    super(self, battlefield, status)

    if status ~= xi.battlefield.status.WON then
        return
    end

    local definition = battlefieldEvents[battlefield:getID()]
    if not definition then
        return
    end

    local participants = collectParticipants(battlefield:getPlayers(), self.zoneId)
    if #participants == 0 then
        return
    end

    local creditType, creditName, creditPhrase = resolveAttribution(participants)
    announceFirst(
        definition,
        participants,
        participants[1].entity,
        string.format('SERVER FIRST! The battlefield "%s" has been cleared by %s!', definition.display, creditPhrase),
        creditType,
        creditName,
        definition.title or self.title)
end)

m:addOverride('xi.dynamis.megaBossOnDeath', function(mob, player, optParams)
    super(mob, player, optParams)

    if not optParams or not optParams.isKiller then
        return
    end

    local definition = dynamisEvents[mob:getZoneName()]
    if not definition then
        return
    end

    local participants = collectAllianceParticipants(player, mob:getZoneID())
    local creditType, creditName = resolveAttribution(participants)
    announceFirst(
        definition,
        participants,
        player,
        string.format('SERVER FIRST! %s has been overcome!', definition.display),
        creditType,
        creditName)
end)

m:addOverride('xi.player.onPlayerItemAdded', function(player, itemId, quantity)
    super(player, itemId, quantity)
    receivedItem(player, itemId)
end)

return m
