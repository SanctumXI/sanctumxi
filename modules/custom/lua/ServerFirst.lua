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

    -- Editable expanded craft catalogue. Cursed -1 items are included at
    -- their normal recipe ranks; the +1 items below require a 100+ craft
    -- skill in this server's pre-SoA recipe data.
    -- Cursed -1 items
    [1345] = { eventKey = 'craft.cursed_kabuto_minus1', display = 'Cursed Kabuto -1' },
    [1347] = { eventKey = 'craft.cursed_togi_minus1', display = 'Cursed Togi -1' },
    [1349] = { eventKey = 'craft.cursed_kote_minus1', display = 'Cursed Kote -1' },
    [1351] = { eventKey = 'craft.cursed_haidate_minus1', display = 'Cursed Haidate -1' },
    [1353] = { eventKey = 'craft.cursed_sune_ate_minus1', display = 'Cursed Sune-Ate -1' },
    [1355] = { eventKey = 'craft.cursed_celata_minus1', display = 'Cursed Celata -1' },
    [1357] = { eventKey = 'craft.cursed_hauberk_minus1', display = 'Cursed Hauberk -1' },
    [1359] = { eventKey = 'craft.cursed_mufflers_minus1', display = 'Cursed Mufflers -1' },
    [1361] = { eventKey = 'craft.cursed_breeches_minus1', display = 'Cursed Breeches -1' },
    [1363] = { eventKey = 'craft.cursed_sollerets_minus1', display = 'Cursed Sollerets -1' },
    [1365] = { eventKey = 'craft.cursed_crown_minus1', display = 'Cursed Crown -1' },
    [1367] = { eventKey = 'craft.cursed_dalmatica_minus1', display = 'Cursed Dalmatica -1' },
    [1369] = { eventKey = 'craft.cursed_mitts_minus1', display = 'Cursed Mitts -1' },
    [1371] = { eventKey = 'craft.cursed_slacks_minus1', display = 'Cursed Slacks -1' },
    [1373] = { eventKey = 'craft.cursed_pumps_minus1', display = 'Cursed Pumps -1' },
    [1375] = { eventKey = 'craft.cursed_schaller_minus1', display = 'Cursed Schaller -1' },
    [1377] = { eventKey = 'craft.cursed_cuirass_minus1', display = 'Cursed Cuirass -1' },
    [1379] = { eventKey = 'craft.cursed_handschuhs_minus1', display = 'Cursed Handschuhs -1' },
    [1381] = { eventKey = 'craft.cursed_diechlings_minus1', display = 'Cursed Diechlings -1' },
    [1383] = { eventKey = 'craft.cursed_schuhs_minus1', display = 'Cursed Schuhs -1' },
    [1385] = { eventKey = 'craft.cursed_mask_minus1', display = 'Cursed Mask -1' },
    [1387] = { eventKey = 'craft.cursed_mail_minus1', display = 'Cursed Mail -1' },
    [1389] = { eventKey = 'craft.cursed_finger_gauntlets_minus1', display = 'Cursed Finger Gauntlets -1' },
    [1391] = { eventKey = 'craft.cursed_cuisses_minus1', display = 'Cursed Cuisses -1' },
    [1393] = { eventKey = 'craft.cursed_greaves_minus1', display = 'Cursed Greaves -1' },
    [1395] = { eventKey = 'craft.cursed_cap_minus1', display = 'Cursed Cap -1' },
    [1397] = { eventKey = 'craft.cursed_harness_minus1', display = 'Cursed Harness -1' },
    [1399] = { eventKey = 'craft.cursed_gloves_minus1', display = 'Cursed Gloves -1' },
    [1401] = { eventKey = 'craft.cursed_subligar_minus1', display = 'Cursed Subligar -1' },
    [1403] = { eventKey = 'craft.cursed_leggings_minus1', display = 'Cursed Leggings -1' },
    [2440] = { eventKey = 'craft.cursed_helm_minus1', display = 'Cursed Helm -1' },
    [2442] = { eventKey = 'craft.cursed_breastplate_minus1', display = 'Cursed Breastplate -1' },
    [2444] = { eventKey = 'craft.cursed_gauntlets_minus1', display = 'Cursed Gauntlets -1' },
    [2446] = { eventKey = 'craft.cursed_cuishes_minus1', display = 'Cursed Cuishes -1' },
    [2448] = { eventKey = 'craft.cursed_sabatons_minus1', display = 'Cursed Sabatons -1' },
    [2450] = { eventKey = 'craft.cursed_hat_minus1', display = 'Cursed Hat -1' },
    [2452] = { eventKey = 'craft.cursed_coat_minus1', display = 'Cursed Coat -1' },
    [2454] = { eventKey = 'craft.cursed_cuffs_minus1', display = 'Cursed Cuffs -1' },
    [2456] = { eventKey = 'craft.cursed_trews_minus1', display = 'Cursed Trews -1' },
    [2458] = { eventKey = 'craft.cursed_clogs_minus1', display = 'Cursed Clogs -1' },

    -- +1 items whose recipe requires at least one 100+ craft skill
    [4141] = { eventKey = 'craft.pro_ether_plus1', display = 'Pro-Ether +1' },
    [6072] = { eventKey = 'craft.magma_steak_plus1', display = 'Magma Steak +1' },
    [11380] = { eventKey = 'craft.hermes_sandals_plus1', display = 'Hermes Sandals +1' },
    [13162] = { eventKey = 'craft.brisingamen_plus1', display = 'Brisingamen +1' },
    [13747] = { eventKey = 'craft.gavial_mail_plus1', display = 'Gavial Mail +1' },
    [13943] = { eventKey = 'craft.panther_mask_plus1', display = 'Panther Mask +1' },
    [13944] = { eventKey = 'craft.gavial_mask_plus1', display = 'Gavial Mask +1' },
    [14390] = { eventKey = 'craft.dragon_harness_plus1', display = 'Dragon Harness +1' },
    [14391] = { eventKey = 'craft.dusk_jerkin_plus1', display = 'Dusk Jerkin +1' },
    [14438] = { eventKey = 'craft.blessed_bliaut_plus1', display = 'Blessed Bliaut +1' },
    [14449] = { eventKey = 'craft.unicorn_harness_plus1', display = 'Unicorn Harness +1' },
    [14538] = { eventKey = 'craft.hydra_mail_plus1', display = 'Hydra Mail +1' },
    [14540] = { eventKey = 'craft.kyudogi_plus1', display = 'Kyudogi +1' },
    [14545] = { eventKey = 'craft.corselet_plus1', display = 'Corselet +1' },
    [15704] = { eventKey = 'craft.hydra_greaves_plus1', display = 'Hydra Greaves +1' },
    [16074] = { eventKey = 'craft.hydra_mask_plus1', display = 'Hydra Mask +1' },
    [16598] = { eventKey = 'craft.gold_algol_plus1', display = 'Gold Algol +1' },
    [16894] = { eventKey = 'craft.ox_tongue_plus1', display = 'Ox Tongue +1' },
    [17214] = { eventKey = 'craft.staurobow_plus1', display = 'Staurobow +1' },
    [17570] = { eventKey = 'craft.iron_splitter_plus1', display = 'Iron-Splitter +1' },
    [18022] = { eventKey = 'craft.adaman_kris_plus1', display = 'Adaman Kris +1' },
    [18111] = { eventKey = 'craft.mezraq_plus1', display = 'Mezraq +1' },
    [18124] = { eventKey = 'craft.thalassocrat_plus1', display = 'Thalassocrat +1' },
    [18130] = { eventKey = 'craft.dabo_plus1', display = 'Dabo +1' },
    [18147] = { eventKey = 'craft.culverin_plus1', display = 'Culverin +1' },
    [18432] = { eventKey = 'craft.butachi_plus1', display = 'Butachi +1' },
    [18483] = { eventKey = 'craft.amood_plus1', display = 'Amood +1' },
    [18749] = { eventKey = 'craft.hades_sainti_plus1', display = 'Hades Sainti +1' },
    [19152] = { eventKey = 'craft.bahadur_plus1', display = 'Bahadur +1' },
    [20622] = { eventKey = 'craft.nanti_knife_plus1', display = 'Nanti Knife +1' },
    [20724] = { eventKey = 'craft.dija_sword_plus1', display = 'Dija Sword +1' },
    [20780] = { eventKey = 'craft.senbaak_nagan_plus1', display = 'Senbaak Nagan +1' },
    [21352] = { eventKey = 'craft.roppo_shuriken_plus1', display = 'Roppo Shuriken +1' },
    [21379] = { eventKey = 'craft.yetshila_plus1', display = 'Yetshila +1' },
    [26878] = { eventKey = 'craft.foppish_tunica_plus1', display = 'Foppish Tunica +1' },
    [26880] = { eventKey = 'craft.wretched_coat_plus1', display = 'Wretched Coat +1' },
    [27604] = { eventKey = 'craft.aptitude_mantle_plus1', display = 'Aptitude Mantle +1' },
    [27747] = { eventKey = 'craft.aetosaur_helm_plus1', display = 'Aetosaur Helm +1' },
    [27749] = { eventKey = 'craft.shabti_armet_plus1', display = 'Shabti Armet +1' },
    [27751] = { eventKey = 'craft.haruspex_hat_plus1', display = 'Haruspex Hat +1' },
    [27890] = { eventKey = 'craft.aetosaur_jerkin_plus1', display = 'Aetosaur Jerkin +1' },
    [27892] = { eventKey = 'craft.shabti_cuirass_plus1', display = 'Shabti Cuirass +1' },
    [27894] = { eventKey = 'craft.haruspex_coat_plus1', display = 'Haruspex Coat +1' },
    [28037] = { eventKey = 'craft.aetosaur_gloves_plus1', display = 'Aetosaur Gloves +1' },
    [28039] = { eventKey = 'craft.shabti_gauntlets_plus1', display = 'Shabti Gauntlets +1' },
    [28041] = { eventKey = 'craft.haruspex_cuffs_plus1', display = 'Haruspex Cuffs +1' },
    [28177] = { eventKey = 'craft.aetosaur_trousers_plus1', display = 'Aetosaur Trousers +1' },
    [28179] = { eventKey = 'craft.shabti_cuisses_plus1', display = 'Shabti Cuisses +1' },
    [28181] = { eventKey = 'craft.haruspex_slops_plus1', display = 'Haruspex Slops +1' },
    [28315] = { eventKey = 'craft.aetosaur_ledelsens_plus1', display = 'Aetosaur Ledelsens +1' },
    [28317] = { eventKey = 'craft.shabti_sabatons_plus1', display = 'Shabti Sabatons +1' },
    [28319] = { eventKey = 'craft.haruspex_pigaches_plus1', display = 'Haruspex Pigaches +1' },
    [28375] = { eventKey = 'craft.dakatsu_no_nodowa_plus1', display = 'Dakatsu-No-Nodowa +1' },
    [28405] = { eventKey = 'craft.ej_necklace_plus1', display = 'Ej Necklace +1' },
    [28447] = { eventKey = 'craft.sweordfaetels_plus1', display = 'Sweordfaetels +1' },
    [28465] = { eventKey = 'craft.pyaekue_belt_plus1', display = 'Pyaekue Belt +1' },
    [28467] = { eventKey = 'craft.dynamic_belt_plus1', display = 'Dynamic Belt +1' },
    [28527] = { eventKey = 'craft.tati_earring_plus1', display = 'Tati Earring +1' },
    [28607] = { eventKey = 'craft.aput_mantle_plus1', display = 'Aput Mantle +1' },
    [28665] = { eventKey = 'craft.killedar_shield_plus1', display = 'Killedar Shield +1' },
}

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
    if definition then
        definition.category = 'craft'
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
