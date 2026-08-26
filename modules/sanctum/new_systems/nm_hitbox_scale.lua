-----------------------------------
-- NM Hitbox Scale
--
-- Companion to the client-side 'SanctumClient' Ashita addon that enlarges
-- enemies. Then, this module scales the server-size mob value to match.
-- Bigger hitbox, better coffee.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('nm_hitbox_scale')
m:setEnabled(true)

local nmsToScale =
{
    -- 200%
    { 'Bibiki_Bay', 'Serra', 3.2, 2.0 },
    { 'Carpenters_Landing', 'Orctrap', 1.3, 2.0 },
    { 'Ifrits_Cauldron', 'Tarasque', 1.8, 2.0 },
    { 'Nyzul_Isle', 'Bomb_King', 1.3, 2.0 },
    { 'Nyzul_Isle', 'Orctrap', 1.3, 2.0 },
    { 'Outer_Horutoto_Ruins', 'Bomb_King', 1.3, 2.0 },
    { 'QuBia_Arena', 'Anansi', 1.9, 2.0 },
    { 'The_Shrine_of_RuAvitau', 'Kirin', 4.4, 2.0 },
    { 'Waughroon_Shrine', 'Queen_Jelly', 3.3, 2.0 },
    -- 150%
    { 'Apollyon', 'Proto-Omega', 1.7, 1.5 },
    { 'Balgas_Dais', 'Giant_Moa', 3.7, 1.5 },
    { 'Beaucedine_Glacier', 'Gargantua', 2.2, 1.5 },
    { 'Behemoths_Dominion', 'King_Behemoth', 4.5, 1.5 },
    { 'Buburimu_Peninsula', 'Buburimboo', 3.2, 1.5 },
    { 'Carpenters_Landing', 'Hercules_Beetle', 1.1, 1.5 },
    { 'Crawlers_Nest', 'Demonic_Tiphia', 1.1, 1.5 },
    { 'Everbloom_Hollow', 'King_Arthro', 1.6, 1.5 },
    { 'Fort_Ghelsba', 'Orcish_Panzer', 2.8, 1.5 },
    { 'Ifrits_Cauldron', 'Bomb_Queen', 1.6, 1.5 },
    { 'Jugner_Forest', 'King_Arthro', 1.6, 1.5 },
    { 'Jugner_Forest', 'Panzer_Percival', 1.4, 1.5 },
    { 'Maze_of_Shakhrami', 'Argus', 1.6, 1.5 },
    { 'Maze_of_Shakhrami', 'Leech_King', 1.5, 1.5 },
    { 'Nyzul_Isle', 'Aquarius', 1.6, 1.5 },
    { 'Nyzul_Isle', 'Argus', 1.6, 1.5 },
    { 'Nyzul_Isle', 'Bloodpool_Vorax', 1.2, 1.5 },
    { 'Nyzul_Isle', 'Buburimboo', 3.2, 1.5 },
    { 'Nyzul_Isle', 'Gargantua', 2.2, 1.5 },
    { 'Nyzul_Isle', 'Leech_King', 1.5, 1.5 },
    { 'Nyzul_Isle', 'Panzer_Percival', 1.4, 1.5 },
    { 'Pashhow_Marshlands', 'Bloodpool_Vorax', 1.2, 1.5 },
    { 'QuBia_Arena', 'Beelzebub', 1.3, 1.5 },
    { 'Sea_Serpent_Grotto', 'Charybdis', 2.5, 1.5 },
    { 'Ship_bound_for_Mhaura', 'Sea_Horror', 2.5, 1.5 },
    { 'Ship_bound_for_Selbina', 'Sea_Horror', 2.5, 1.5 },
    { 'Temenos', 'Proto-Ultima', 1.5, 1.5 },
    { 'The_Boyahda_Tree', 'Aquarius', 1.6, 1.5 },
    { 'Waughroon_Shrine', 'Flayer_Franz', 1.8, 1.5 },
    -- 120%
    { 'Balgas_Dais', 'Bitoso', 2.0, 1.2 },
    { 'Balgas_Dais', 'Macan_Gadangan', 1.6, 1.2 },
    { 'Balgas_Dais', 'Phoedme', 1.2, 1.2 },
    { 'Beaucedine_Glacier', 'Kirata', 2.9, 1.2 },
    { 'Beaucedine_Glacier', 'Nue', 2.9, 1.2 },
    { 'Bibiki_Bay', 'Shen', 1.6, 1.2 },
    { 'Castle_Zvahl_Keep', 'Count_Bifrons', 2.0, 1.2 },
    { 'Crawlers_Nest', 'Awd_Goggie', 2.0, 1.2 },
    { 'Crawlers_Nest', 'Dynast_Beetle', 1.2, 1.2 },
    { 'Crawlers_Nest', 'Queen_Crawler', 1.7, 1.2 },
    { 'Dangruf_Wadi', 'Chocoboleech', 1.2, 1.2 },
    { 'East_Ronfaure', 'Bigmouth_Billy', 1.4, 1.2 },
    { 'East_Ronfaure', 'Swamfisk', 3.2, 1.2 },
    { 'East_Sarutabaruta', 'Duke_Decapod', 1.1, 1.2 },
    { 'East_Sarutabaruta', 'Spiny_Spipi', 1.7, 1.2 },
    { 'FeiYin', 'Goliath', 2.2, 1.2 },
    { 'Ghelsba_Outpost', 'Colo-colo', 1.4, 1.2 },
    { 'Ghelsba_Outpost', 'Kalamainu', 1.8, 1.2 },
    { 'Ghelsba_Outpost', 'Kilioa', 1.8, 1.2 },
    { 'Horlais_Peak', 'Aries', 5.8, 1.2 },
    { 'Horlais_Peak', 'Evil_Oscar', 4.4, 1.2 },
    { 'Horlais_Peak', 'Gerjis', 3.6, 1.2 },
    { 'Horlais_Peak', 'Sobbing_Eyes', 1.6, 1.2 },
    { 'Konschtat_Highlands', 'Haty', 2.5, 1.2 },
    { 'Korroloka_Tunnel', 'Morion_Worm', 1.4, 1.2 },
    { 'Kuftal_Tunnel', 'Arachne', 1.6, 1.2 },
    { 'Kuftal_Tunnel', 'Guivre', 4.4, 1.2 },
    { 'La_Theine_Plateau', 'Tumbling_Truffle', 1.7, 1.2 },
    { 'Labyrinth_of_Onzozo', 'Hellion', 3.4, 1.2 },
    { 'Labyrinth_of_Onzozo', 'Lord_of_Onzozo', 2.5, 1.2 },
    { 'Labyrinth_of_Onzozo', 'Narasimha', 3.6, 1.2 },
    { 'Meriphataud_Mountains', 'Waraxe_Beak', 5.3, 1.2 },
    { 'North_Gustaberg', 'Bedrock_Barry', 1.1, 1.2 },
    { 'North_Gustaberg', 'Stinging_Sophie', 1.1, 1.2 },
    { 'Nyzul_Isle', 'Carnero', 2.7, 1.2 },
    { 'Nyzul_Isle', 'Fungus_Beetle', 1.4, 1.2 },
    { 'Nyzul_Isle', 'Hellion', 3.4, 1.2 },
    { 'Nyzul_Isle', 'Keeper_of_Halidom', 3.4, 1.2 },
    { 'Nyzul_Isle', 'Leaping_Lizzy', 1.8, 1.2 },
    { 'Nyzul_Isle', 'Spiny_Spipi', 1.7, 1.2 },
    { 'Nyzul_Isle', 'Stinging_Sophie', 1.1, 1.2 },
    { 'Nyzul_Isle', 'Swamfisk', 3.2, 1.2 },
    { 'Nyzul_Isle', 'Tom_Tit_Tat', 0.9, 1.2 },
    { 'Nyzul_Isle', 'Tumbling_Truffle', 1.7, 1.2 },
    { 'Nyzul_Isle', 'Valkurm_Emperor', 1.7, 1.2 },
    { 'Ordelles_Caves', 'Morbolger', 4.4, 1.2 },
    { 'QuBia_Arena', 'Doll_Factory', 1.0, 1.2 },
    { 'RuAun_Gardens', 'Byakko', 3.6, 1.2 },
    { 'RuAun_Gardens', 'Genbu', 3.6, 1.2 },
    { 'RuAun_Gardens', 'Suzaku', 4.4, 1.2 },
    { 'Sauromugue_Champaign', 'Deadly_Dodo', 4.3, 1.2 },
    { 'South_Gustaberg', 'Carnero', 2.7, 1.2 },
    { 'South_Gustaberg', 'Leaping_Lizzy', 1.8, 1.2 },
    { 'South_Gustaberg', 'Tococo', 1.7, 1.2 },
    { 'Temple_of_Uggalepih', 'Flauros', 1.6, 1.2 },
    { 'The_Sanctuary_of_ZiTah', 'Keeper_of_Halidom', 3.4, 1.2 },
    { 'The_Sanctuary_of_ZiTah', 'Noble_Mold', 1.7, 1.2 },
    { 'The_Shrine_of_RuAvitau', 'Byakko', 3.6, 1.2 },
    { 'The_Shrine_of_RuAvitau', 'Genbu', 3.6, 1.2 },
    { 'The_Shrine_of_RuAvitau', 'Suzaku', 4.4, 1.2 },
    { 'Toraimarai_Canal', 'Oni_Carcass', 3.4, 1.2 },
    { 'Valkurm_Dunes', 'Valkurm_Emperor', 1.7, 1.2 },
    { 'Waughroon_Shrine', 'Fee', 1.7, 1.2 },
    { 'Waughroon_Shrine', 'Heavy_Metal_Crab', 1.6, 1.2 },
    { 'Waughroon_Shrine', 'Tartaruga_Gigante', 3.2, 1.2 },
    { 'West_Ronfaure', 'Amanita', 1.2, 1.2 },
    { 'West_Ronfaure', 'Fungus_Beetle', 1.4, 1.2 },
    { 'West_Sarutabaruta', 'Tom_Tit_Tat', 0.9, 1.2 },
    -- 110%
    { 'Attohwa_Chasm', 'Ambusher_Antlion', 1.3, 1.1 },
    { 'Balgas_Dais', 'Dvorovoi', 1.1, 1.1 },
    { 'Balgas_Dais', 'Nenaunir', 4.3, 1.1 },
    { 'Balgas_Dais', 'Opo-opo_Monarch', 2.6, 1.1 },
    { 'Balgas_Dais', 'Pepper', 1.2, 1.1 },
    { 'Batallia_Downs_[S]', 'La_Velue', 2.5, 1.1 },
    { 'Behemoths_Dominion', 'Behemoth', 3.8, 1.1 },
    { 'Bibiki_Bay', 'Intulo', 1.3, 1.1 },
    { 'Buburimu_Peninsula', 'Backoo', 0.8, 1.1 },
    { 'Buburimu_Peninsula', 'Helldiver', 2.2, 1.1 },
    { 'Dragons_Aery', 'Fafnir', 4.2, 1.1 },
    { 'Eastern_Altepa_Desert', 'Dune_Widow', 1.6, 1.1 },
    { 'Garlaige_Citadel', 'Old_Two-Wings', 1.8, 1.1 },
    { 'Garlaige_Citadel', 'Serket', 1.9, 1.1 },
    { 'Horlais_Peak', 'Huntfly', 2.0, 1.1 },
    { 'Konschtat_Highlands', 'Steelfleece_Baldarich', 5.8, 1.1 },
    { 'La_Theine_Plateau', 'Bloodtear_Baldurf', 5.8, 1.1 },
    { 'Meriphataud_Mountains', 'Chonchon', 3.7, 1.1 },
    { 'Meriphataud_Mountains', 'Daggerclaw_Dracos', 2.1, 1.1 },
    { 'Monastic_Cavern', 'Orcish_Warlord', 1.7, 1.1 },
    { 'Nyzul_Isle', 'Behemoth', 3.8, 1.1 },
    { 'Nyzul_Isle', 'Bloodtear_Baldurf', 5.8, 1.1 },
    { 'Nyzul_Isle', 'Cactuar_Cantautor', 0.9, 1.1 },
    { 'Nyzul_Isle', 'Daggerclaw_Dracos', 2.1, 1.1 },
    { 'Nyzul_Isle', 'Drooling_Daisy', 3.6, 1.1 },
    { 'Nyzul_Isle', 'Dune_Widow', 1.6, 1.1 },
    { 'Nyzul_Isle', 'Fafnir', 4.2, 1.1 },
    { 'Nyzul_Isle', 'Helldiver', 2.2, 1.1 },
    { 'Nyzul_Isle', 'Intulo', 1.3, 1.1 },
    { 'Nyzul_Isle', 'Jolly_Green', 3.4, 1.1 },
    { 'Nyzul_Isle', 'Old_Two-Wings', 1.8, 1.1 },
    { 'Nyzul_Isle', 'Roc', 3.2, 1.1 },
    { 'Nyzul_Isle', 'Serket', 1.9, 1.1 },
    { 'Nyzul_Isle', 'Simurgh', 3.6, 1.1 },
    { 'Nyzul_Isle', 'Steelfleece_Baldarich', 5.8, 1.1 },
    { 'Oldton_Movalpolos', 'Bugbear_Strongman', 1.3, 1.1 },
    { 'Pashhow_Marshlands', 'Jolly_Green', 3.4, 1.1 },
    { 'Quicksand_Caves', 'Nussknacker', 1.8, 1.1 },
    { 'Reisenjima_Henge', 'HM_Roc', 3.2, 1.1 },
    { 'Reisenjima_Henge', 'HM_Simurgh', 3.6, 1.1 },
    { 'Rolanberry_Fields', 'Drooling_Daisy', 3.6, 1.1 },
    { 'Rolanberry_Fields', 'Simurgh', 3.6, 1.1 },
    { 'RuAun_Gardens', 'Seiryu', 4.4, 1.1 },
    { 'Sauromugue_Champaign', 'Roc', 3.2, 1.1 },
    { 'Sea_Serpent_Grotto', 'Sea_Hog', 3.2, 1.1 },
    { 'The_Shrine_of_RuAvitau', 'Seiryu', 4.4, 1.1 },
    { 'Upper_Delkfutts_Tower', 'Porphyrion', 4.1, 1.1 },
    { 'Valley_of_Sorrows', 'Aspidochelone', 3.2, 1.1 },
    { 'Waughroon_Shrine', 'Metsanneitsyt', 1.2, 1.1 },
    { 'Western_Altepa_Desert', 'Cactuar_Cantautor', 0.9, 1.1 },
    { 'Western_Altepa_Desert', 'Celphie', 3.7, 1.1 },
    { 'Yuhtunga_Jungle', 'Rose_Garden', 3.6, 1.1 },
}

for _, entry in pairs(nmsToScale) do
    local zoneName     = entry[1]
    local mobName      = entry[2]
    local baseHitbox   = entry[3]
    local scale        = entry[4]
    local targetHitbox = baseHitbox * scale

    -- onMobInitialize fires once when the persistent mob entity is created
    -- (not on every respawn), so this sets the hitbox exactly once and it
    -- sticks across pops without.
    m:addOverride(string.format('xi.zones.%s.mobs.%s.onMobInitialize', zoneName, mobName),
    function(mob)
        super(mob)

        mob:setHitboxSize(targetHitbox)
        print(string.format('[nm_hitbox_scale] %s hitbox set to %.2f yalms (%.0f%% of %.2f baseline)',
            mob:getPacketName(), targetHitbox, scale * 100, baseHitbox))
    end)
end

return m
