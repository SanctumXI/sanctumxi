-----------------------------------
-- Server First Announcements
--
-- Editable server-wide first-achievement configuration. Event catalogues are
-- grouped below; the callback logic begins after the Configuration section.
--
-- Title note:
--   setTitle() makes a client-supported title active and permanently unlocks
--   it. New custom titles also require the appropriate DAT changes.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/battlefield')
require('scripts/globals/dynamis')
require('scripts/globals/mobs')
require('scripts/globals/missions')
require('scripts/globals/player')

local m = Module:new('ServerFirst')

-----------------------------------
-- Configuration
-----------------------------------

-- Chat decorations used for normal and legendary announcements.
local decoration =
{
    standard  = '\129\154', -- gold star
    legendary = '\129\159',
}

local function eventKey(part)
    return string.gsub(string.lower(part), '[^a-z0-9]+', '_')
end

local function addNMEvent(tableRef, mobName, displayName, zoneName, title)
    tableRef[mobName] =
    {
        eventKey = 'nm.' .. eventKey(displayName),
        display  = displayName,
        zone     = zoneName,
        title    = title,
    }
end

-- Notorious monsters. Zone restrictions keep Nyzul and battlefield variants
-- from claiming an open-world server first.
local nmEvents = {}
addNMEvent(nmEvents, 'Jaggedy-Eared_Jack',       'Jaggedy-Eared Jack',       'West_Ronfaure')
addNMEvent(nmEvents, 'Leaping_Lizzy',            'Leaping Lizzy',            'South_Gustaberg')
addNMEvent(nmEvents, 'Valkurm_Emperor',          'Valkurm Emperor',          'Valkurm_Dunes')
addNMEvent(nmEvents, 'Argus',                    'Argus',                    'Maze_of_Shakhrami')
addNMEvent(nmEvents, 'Lord_of_Onzozo',           'Lord of Onzozo',           'Labyrinth_of_Onzozo')
addNMEvent(nmEvents, 'Hakutaku',                 'Hakutaku',                 'Den_of_Rancor')
addNMEvent(nmEvents, 'Charybdis',                'Charybdis',                'Sea_Serpent_Grotto')
addNMEvent(nmEvents, 'Bune',                     'Bune',                     'Gustav_Tunnel')
addNMEvent(nmEvents, 'Guivre',                   'Guivre',                   'Kuftal_Tunnel')
addNMEvent(nmEvents, 'King_Arthro',              'King Arthro',              'Jugner_Forest')
addNMEvent(nmEvents, 'Roc',                      'Roc',                      'Sauromugue_Champaign')
addNMEvent(nmEvents, 'Simurgh',                  'Simurgh',                  'Rolanberry_Fields')
addNMEvent(nmEvents, 'Serket',                   'Serket',                   'Garlaige_Citadel', xi.title.SERKET_BREAKER)
addNMEvent(nmEvents, 'Capricious_Cassie',        'Capricious Cassie',        'FeiYin', xi.title.CASSIENOVA)
addNMEvent(nmEvents, 'Lumber_Jack',              'Lumber Jack',              'Batallia_Downs')
addNMEvent(nmEvents, 'King_Vinegarroon',         'King Vinegarroon',         'Western_Altepa_Desert', xi.title.VINEGAR_EVAPORATOR)
addNMEvent(nmEvents, 'Behemoth',                 'Behemoth',                 'Behemoths_Dominion', xi.title.BEHEMOTHS_BANE)
addNMEvent(nmEvents, 'Adamantoise',              'Adamantoise',              'Valley_of_Sorrows')
addNMEvent(nmEvents, 'Fafnir',                   'Fafnir',                   'Dragons_Aery', xi.title.FAFNIR_SLAYER)
addNMEvent(nmEvents, 'King_Behemoth',            'King Behemoth',            'Behemoths_Dominion', xi.title.BEHEMOTH_DETHRONER)
addNMEvent(nmEvents, 'Aspidochelone',            'Aspidochelone',            'Valley_of_Sorrows', xi.title.ASPIDOCHELONE_SINKER)
addNMEvent(nmEvents, 'Nidhogg',                  'Nidhogg',                  'Dragons_Aery', xi.title.NIDHOGG_SLAYER)
addNMEvent(nmEvents, 'Tiamat',                   'Tiamat',                   'Attohwa_Chasm', xi.title.TIAMAT_TROUNCER)
addNMEvent(nmEvents, 'Jormungand',               'Jormungand',               'Uleguerand_Range', xi.title.WORLD_SERPENT_SLAYER)
addNMEvent(nmEvents, 'Vrtra',                    'Vrtra',                    'King_Ranperres_Tomb', xi.title.VRTRA_VANQUISHER)
addNMEvent(nmEvents, 'Hydra',                    'Hydra',                    'Wajaom_Woodlands', xi.title.HYDRA_HEADHUNTER)
addNMEvent(nmEvents, 'Cerberus',                 'Cerberus',                 'Mount_Zhayolm', xi.title.CERBERUS_MUZZLER)
addNMEvent(nmEvents, 'Khimaira',                 'Khimaira',                 'Caedarva_Mire', xi.title.KHIMAIRA_CARVER)
addNMEvent(nmEvents, 'Dark_Ixion',               'Dark Ixion') -- roams multiple Wings of the Goddess zones
addNMEvent(nmEvents, 'Sandworm',                 'Sandworm') -- roams multiple zones
addNMEvent(nmEvents, 'Overlord_Bakgodek',        'Overlord Bakgodek',        'Monastic_Cavern', xi.title.OVERLORD_OVERTHROWER)
addNMEvent(nmEvents, "Za'Dha_Adamantking",      "Za'Dha Adamantking",      'Castle_Oztroja')
addNMEvent(nmEvents, 'Tzee_Xicu_the_Manifest',  'Tzee Xicu the Manifest',  'Castle_Oztroja', xi.title.DEITY_DEBUNKER)
addNMEvent(nmEvents, 'Gulool_Ja_Ja',             'Gulool Ja Ja',             'Mamook', xi.title.SHINING_SCALE_RIFLER)
addNMEvent(nmEvents, 'Gurfurlur_the_Menacing',  'Gurfurlur the Menacing',  'Halvung', xi.title.TROLL_SUBJUGATOR)
addNMEvent(nmEvents, 'Medusa',                   'Medusa',                   'Arrapago_Reef', xi.title.GORGONSTONE_SUNDERER)
addNMEvent(nmEvents, 'Genbu',                    'Genbu',                    'RuAun_Gardens')
addNMEvent(nmEvents, 'Seiryu',                   'Seiryu',                   'RuAun_Gardens')
addNMEvent(nmEvents, 'Suzaku',                   'Suzaku',                   'RuAun_Gardens')
addNMEvent(nmEvents, 'Byakko',                   'Byakko',                   'RuAun_Gardens')
addNMEvent(nmEvents, 'Kirin',                    'Kirin',                    'The_Shrine_of_RuAvitau', xi.title.KIRIN_CAPTIVATOR)
addNMEvent(nmEvents, 'Jailer_of_Temperance',     'Jailer of Temperance',     'Grand_Palace_of_HuXzoi')
addNMEvent(nmEvents, 'Jailer_of_Fortitude',      'Jailer of Fortitude',      'The_Garden_of_RuHmet')
addNMEvent(nmEvents, 'Jailer_of_Faith',          'Jailer of Faith',          'The_Garden_of_RuHmet')
addNMEvent(nmEvents, 'Jailer_of_Justice',        'Jailer of Justice',        'AlTaieu')
addNMEvent(nmEvents, 'Jailer_of_Hope',           'Jailer of Hope',           'AlTaieu')
addNMEvent(nmEvents, 'Jailer_of_Prudence',       'Jailer of Prudence',       'AlTaieu')
addNMEvent(nmEvents, 'Jailer_of_Love',           'Jailer of Love',           'AlTaieu')
addNMEvent(nmEvents, 'Absolute_Virtue',          'Absolute Virtue',          'AlTaieu', xi.title.VIRTUOUS_SAINT)
addNMEvent(nmEvents, 'Tinnin',                   'Tinnin',                   'Wajaom_Woodlands')
addNMEvent(nmEvents, 'Sarameya',                 'Sarameya',                 'Mount_Zhayolm')
addNMEvent(nmEvents, 'Tyger',                    'Tyger',                    'Caedarva_Mire')
addNMEvent(nmEvents, 'Pandemonium_Warden',       'Pandemonium Warden',       'Aydeewa_Subterrane', xi.title.PANDEMONIUM_QUELLER)
addNMEvent(nmEvents, 'Proto-Omega',              'Proto-Omega',              'Apollyon')
addNMEvent(nmEvents, 'Proto-Ultima',              'Proto-Ultima',             'Temenos')

-- Each entry is an authoritative synthesis result ID. Keep the event key
-- stable once published; the display name is safe to edit for presentation.
-- addCraftEvent(itemId, eventKeySuffix, displayName)
local craftEvents = {}

local function addCraftEvent(itemId, eventKeySuffix, displayName)
    craftEvents[itemId] =
    {
        eventKey = 'craft.' .. eventKeySuffix,
        category = 'craft',
        display  = displayName,
    }
end

-- Curated iconic crafts, regardless of their skill requirements.
addCraftEvent(12579, 'scorpion_harness', 'Scorpion Harness')
addCraftEvent(13734, 'scorpion_harness_plus1', 'Scorpion Harness +1')
addCraftEvent(12555, 'haubergeon', 'Haubergeon')
addCraftEvent(13735, 'haubergeon_plus1', 'Haubergeon +1')
addCraftEvent(12556, 'hauberk', 'Hauberk')
addCraftEvent(13793, 'hauberk_plus1', 'Hauberk +1')
addCraftEvent(13748, 'vermillion_cloak', 'Vermillion Cloak')
addCraftEvent(13749, 'royal_cloak', 'Royal Cloak')
addCraftEvent(12605, 'nobles_tunic', "Noble's Tunic")
addCraftEvent(13774, 'aristocrats_coat', "Aristocrat's Coat")
addCraftEvent(13779, 'black_cloak', 'Black Cloak')
addCraftEvent(13780, 'demons_cloak', "Demon's Cloak")
addCraftEvent(13646, 'amemet_mantle_plus1', 'Amemet Mantle +1')
addCraftEvent(13627, 'prism_cape', 'Prism Cape')
addCraftEvent(16212, 'cerberus_mantle', 'Cerberus Mantle')
addCraftEvent(16216, 'cerberus_mantle_plus1', 'Cerberus Mantle +1')
addCraftEvent(17546, 'vulcans_staff',  "Vulcan's Staff")
addCraftEvent(17548, 'aquilos_staff',  "Aquilo's Staff") 
addCraftEvent(17550, 'austers_staff',  "Auster's Staff") 
addCraftEvent(17552, 'terras_staff',   "Terra's Staff")
addCraftEvent(17554, 'jupiters_staff', "Jupiter's Staff")
addCraftEvent(17556, 'neptunes_staff', "Neptune's Staff")
addCraftEvent(17558, 'apollos_staff',  "Apollo's Staff")
addCraftEvent(17560, 'plutos_staff',   "Pluto's Staff")
addCraftEvent(17264, 'hellfire_plus1', 'Hellfire +1')
addCraftEvent(17552, 'terras_staff', "Terra's Staff")
addCraftEvent(1345, 'cursed_kabuto_minus1', 'Cursed Kabuto -1')
addCraftEvent(1347, 'cursed_togi_minus1', 'Cursed Togi -1')
addCraftEvent(1349, 'cursed_kote_minus1', 'Cursed Kote -1')
addCraftEvent(1351, 'cursed_haidate_minus1', 'Cursed Haidate -1')
addCraftEvent(1353, 'cursed_sune_ate_minus1', 'Cursed Sune-Ate -1')
addCraftEvent(1355, 'cursed_celata_minus1', 'Cursed Celata -1')
addCraftEvent(1357, 'cursed_hauberk_minus1', 'Cursed Hauberk -1')
addCraftEvent(1359, 'cursed_mufflers_minus1', 'Cursed Mufflers -1')
addCraftEvent(1361, 'cursed_breeches_minus1', 'Cursed Breeches -1')
addCraftEvent(1363, 'cursed_sollerets_minus1', 'Cursed Sollerets -1')
addCraftEvent(1365, 'cursed_crown_minus1', 'Cursed Crown -1')
addCraftEvent(1367, 'cursed_dalmatica_minus1', 'Cursed Dalmatica -1')
addCraftEvent(1369, 'cursed_mitts_minus1', 'Cursed Mitts -1')
addCraftEvent(1371, 'cursed_slacks_minus1', 'Cursed Slacks -1')
addCraftEvent(1373, 'cursed_pumps_minus1', 'Cursed Pumps -1')
addCraftEvent(1375, 'cursed_schaller_minus1', 'Cursed Schaller -1')
addCraftEvent(1377, 'cursed_cuirass_minus1', 'Cursed Cuirass -1')
addCraftEvent(1379, 'cursed_handschuhs_minus1', 'Cursed Handschuhs -1')
addCraftEvent(1381, 'cursed_diechlings_minus1', 'Cursed Diechlings -1')
addCraftEvent(1383, 'cursed_schuhs_minus1', 'Cursed Schuhs -1')
addCraftEvent(1385, 'cursed_mask_minus1', 'Cursed Mask -1')
addCraftEvent(1387, 'cursed_mail_minus1', 'Cursed Mail -1')
addCraftEvent(1389, 'cursed_finger_gauntlets_minus1', 'Cursed Finger Gauntlets -1')
addCraftEvent(1391, 'cursed_cuisses_minus1', 'Cursed Cuisses -1')
addCraftEvent(1393, 'cursed_greaves_minus1', 'Cursed Greaves -1')
addCraftEvent(1395, 'cursed_cap_minus1', 'Cursed Cap -1')
addCraftEvent(1397, 'cursed_harness_minus1', 'Cursed Harness -1')
addCraftEvent(1399, 'cursed_gloves_minus1', 'Cursed Gloves -1')
addCraftEvent(1401, 'cursed_subligar_minus1', 'Cursed Subligar -1')
addCraftEvent(1403, 'cursed_leggings_minus1', 'Cursed Leggings -1')
addCraftEvent(2440, 'cursed_helm_minus1', 'Cursed Helm -1')
addCraftEvent(2442, 'cursed_breastplate_minus1', 'Cursed Breastplate -1')
addCraftEvent(2444, 'cursed_gauntlets_minus1', 'Cursed Gauntlets -1')
addCraftEvent(2446, 'cursed_cuishes_minus1', 'Cursed Cuishes -1')
addCraftEvent(2448, 'cursed_sabatons_minus1', 'Cursed Sabatons -1')
addCraftEvent(2450, 'cursed_hat_minus1', 'Cursed Hat -1')
addCraftEvent(2452, 'cursed_coat_minus1', 'Cursed Coat -1')
addCraftEvent(2454, 'cursed_cuffs_minus1', 'Cursed Cuffs -1')
addCraftEvent(2456, 'cursed_trews_minus1', 'Cursed Trews -1')
addCraftEvent(2458, 'cursed_clogs_minus1', 'Cursed Clogs -1')
addCraftEvent(11380, 'hermes_sandals_plus1', 'Hermes Sandals +1')
addCraftEvent(13162, 'brisingamen_plus1', 'Brisingamen +1')
addCraftEvent(13747, 'gavial_mail_plus1', 'Gavial Mail +1')
addCraftEvent(13943, 'panther_mask_plus1', 'Panther Mask +1')
addCraftEvent(13944, 'gavial_mask_plus1', 'Gavial Mask +1')
addCraftEvent(14390, 'dragon_harness_plus1', 'Dragon Harness +1')
addCraftEvent(14391, 'dusk_jerkin_plus1', 'Dusk Jerkin +1')
addCraftEvent(14438, 'blessed_bliaut_plus1', 'Blessed Bliaut +1')
addCraftEvent(14449, 'unicorn_harness_plus1', 'Unicorn Harness +1')
addCraftEvent(14538, 'hydra_mail_plus1', 'Hydra Mail +1')
addCraftEvent(14540, 'kyudogi_plus1', 'Kyudogi +1')
addCraftEvent(14545, 'corselet_plus1', 'Corselet +1')
addCraftEvent(15704, 'hydra_greaves_plus1', 'Hydra Greaves +1')
addCraftEvent(16074, 'hydra_mask_plus1', 'Hydra Mask +1')
addCraftEvent(16598, 'gold_algol_plus1', 'Gold Algol +1')
addCraftEvent(16894, 'ox_tongue_plus1', 'Ox Tongue +1')
addCraftEvent(17214, 'staurobow_plus1', 'Staurobow +1')
addCraftEvent(17570, 'iron_splitter_plus1', 'Iron-Splitter +1')
addCraftEvent(18022, 'adaman_kris_plus1', 'Adaman Kris +1')
addCraftEvent(18111, 'mezraq_plus1', 'Mezraq +1')
addCraftEvent(18124, 'thalassocrat_plus1', 'Thalassocrat +1')
addCraftEvent(18130, 'dabo_plus1', 'Dabo +1')
addCraftEvent(18147, 'culverin_plus1', 'Culverin +1')
addCraftEvent(18432, 'butachi_plus1', 'Butachi +1')
addCraftEvent(18483, 'amood_plus1', 'Amood +1')
addCraftEvent(18749, 'hades_sainti_plus1', 'Hades Sainti +1')

-- One-time item achievements.
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

-- Every completed relic and mythic is archived; the first of either kind also
-- receives the separate "first legendary weapon" announcement.
local legendaryWeapons =
{
    [15070] = { name = 'Aegis',         kind = 'relic' },
    [18264] = { name = 'Spharai',       kind = 'relic' },
    [18270] = { name = 'Mandau',        kind = 'relic' },
    [18276] = { name = 'Excalibur',     kind = 'relic' },
    [18282] = { name = 'Ragnarok',      kind = 'relic' },
    [18288] = { name = 'Guttler',       kind = 'relic' },
    [18294] = { name = 'Bravura',       kind = 'relic' },
    [18300] = { name = 'Gungnir',       kind = 'relic' },
    [18306] = { name = 'Apocalypse',    kind = 'relic' },
    [18312] = { name = 'Kikoku',        kind = 'relic' },
    [18318] = { name = 'Amanomurakumo', kind = 'relic' },
    [18324] = { name = 'Mjollnir',      kind = 'relic' },
    [18330] = { name = 'Claustrum',     kind = 'relic' },
    [18336] = { name = 'Annihilator',   kind = 'relic' },
    [18342] = { name = 'Gjallarhorn',   kind = 'relic' },
    [18348] = { name = 'Yoichinoyumi',  kind = 'relic' },
    [18989] = { name = 'Terpsichore',   kind = 'mythic' },
    [18990] = { name = 'Tupsimati',     kind = 'mythic' },
    [18991] = { name = 'Conqueror',     kind = 'mythic' },
    [18992] = { name = 'Glanzfaust',    kind = 'mythic' },
    [18993] = { name = 'Yagrush',       kind = 'mythic' },
    [18994] = { name = 'Laevateinn',    kind = 'mythic' },
    [18995] = { name = 'Murgleis',      kind = 'mythic' },
    [18996] = { name = 'Vajra',         kind = 'mythic' },
    [18997] = { name = 'Burtgang',      kind = 'mythic' },
    [18998] = { name = 'Liberator',     kind = 'mythic' },
    [18999] = { name = 'Aymur',         kind = 'mythic' },
    [19000] = { name = 'Carnwenhan',    kind = 'mythic' },
    [19001] = { name = 'Gastraphetes',  kind = 'mythic' },
    [19002] = { name = 'Kogarasumaru',  kind = 'mythic' },
    [19003] = { name = 'Nagi',          kind = 'mythic' },
    [19004] = { name = 'Ryunohige',     kind = 'mythic' },
    [19005] = { name = 'Nirvana',       kind = 'mythic' },
    [19006] = { name = 'Tizona',        kind = 'mythic' },
    [19007] = { name = 'Death Penalty', kind = 'mythic' },
    [19008] = { name = 'Kenkonken',     kind = 'mythic' },
}

-- Only these item IDs need the onPlayerItemAdded callback, avoiding Lua work
-- for ordinary item acquisition.
local trackedItemIds = {}
for itemId in pairs(specialItemEvents) do
    table.insert(trackedItemIds, itemId)
end
for itemId in pairs(legendaryWeapons) do
    table.insert(trackedItemIds, itemId)
end
xi.serverFirstConfig = { trackedItemIds = trackedItemIds }

-- First player to reach the skill cap for each craft.
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

-- Battlefield IDs are resolved once during module load. Missing IDs are
-- reported and skipped so a branch without optional content keeps loading.
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
        display  = displayName,
        title    = title,
    }
end

-- Level 20
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

-- Expansion mission completions.
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

-- Dynamis zones and their associated titles.
local dynamisEvents = {}

local function addDynamisEvent(zoneName, displayName, title)
    dynamisEvents[zoneName] =
    {
        eventKey = 'dynamis.' .. eventKey(displayName),
        display  = displayName,
        title    = title,
    }
end

addDynamisEvent('Dynamis-San_dOria',   "Dynamis-San d'Oria", xi.title.DYNAMIS_SAN_DORIA_INTERLOPER)
addDynamisEvent('Dynamis-Bastok',      'Dynamis-Bastok',      xi.title.DYNAMIS_BASTOK_INTERLOPER)
addDynamisEvent('Dynamis-Windurst',    'Dynamis-Windurst',    xi.title.DYNAMIS_WINDURST_INTERLOPER)
addDynamisEvent('Dynamis-Jeuno',       'Dynamis-Jeuno',       xi.title.DYNAMIS_JEUNO_INTERLOPER)
addDynamisEvent('Dynamis-Beaucedine',  'Dynamis-Beaucedine',  xi.title.DYNAMIS_BEAUCEDINE_INTERLOPER)
addDynamisEvent('Dynamis-Xarcabard',   'Dynamis-Xarcabard',   xi.title.DYNAMIS_XARCABARD_INTERLOPER)
addDynamisEvent('Dynamis-Valkurm',     'Dynamis-Valkurm',     xi.title.DYNAMIS_VALKURM_INTERLOPER)
addDynamisEvent('Dynamis-Buburimu',    'Dynamis-Buburimu',    xi.title.DYNAMIS_BUBURIMU_INTERLOPER)
addDynamisEvent('Dynamis-Qufim',       'Dynamis-Qufim',       xi.title.DYNAMIS_QUFIM_INTERLOPER)
addDynamisEvent('Dynamis-Tavnazia',    'Dynamis-Tavnazia',    xi.title.DYNAMIS_TAVNAZIA_INTERLOPER)

-- First Rank 10 by nation.
local rankEvents =
{
    [xi.nation.SANDORIA] = { eventKey = 'rank.first_10_san_d_orian', category = 'rank', display = "San d'Oria Rank 10" },
    [xi.nation.BASTOK]   = { eventKey = 'rank.first_10_bastokan',    category = 'rank', display = 'Bastokan Rank 10' },
    [xi.nation.WINDURST] = { eventKey = 'rank.first_10_windurstian', category = 'rank', display = 'Windurstian Rank 10' },
}

-----------------------------------
-- Runtime helpers
-----------------------------------

-- Participant collection and attribution
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
        entity             = entity,
        char_id            = participant.char_id,
        char_name          = participant.char_name,
        linkshell_name     = participant.linkshell_name or '',
        is_party_leader    = participant.is_party_leader or false,
        is_alliance_leader = participant.is_alliance_leader or false,
        is_leader          = false,
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
        local hasMajority = count * 2 >= #participants
        local winsCount = count > linkshellCount
        local winsTieBreak = count == linkshellCount and (not linkshellWinner or linkshell < linkshellWinner)
        if hasMajority and (winsCount or winsTieBreak) then
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
        local isEligibleLeader =
            (wantAllianceLeader and participant.is_alliance_leader) or
            (not wantAllianceLeader and participant.is_party_leader)
        if isEligibleLeader then
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

-- Announcement delivery
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

-- Item acquisition handling
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

-----------------------------------
-- Event hooks
-----------------------------------

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
    if definition then
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

    local definition = rankEvents[nation]
    if not definition then
        return
    end

    announceSolo(
        definition,
        player,
        string.format('SERVER FIRST! %s has become the first %s adventurer!', player:getName(), definition.display))
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
