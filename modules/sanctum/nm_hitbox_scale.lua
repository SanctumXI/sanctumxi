-----------------------------------
-- NM Hitbox Scale
--
-- Companion to the client-side "SanctumSize" Ashita addon, which enlarges
-- the *visual* model of configured NMs for players who have it installed.
-- That addon is purely cosmetic and client-local; it cannot change how
-- melee, weaponskills, spells, abilities, or aura ranges are actually
-- calculated, since all of that runs here on the server against
-- modelHitboxSize (see src/map/entities/mobentity.cpp,
-- src/map/ai/states/ability_state.cpp, src/map/ai/states/magic_state.cpp,
-- and src/map/status_effect_container.cpp, which all add modelHitboxSize
-- into their range checks).
--
-- This module scales that server-authoritative value to match, so the
-- bigger model is backed by a bigger real hitbox for every player, not
-- just those with the client addon installed.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('nm_hitbox_scale')
m:setEnabled(true)

-- NOTE: These names are as they are as filenames.
-- Example: Behemoth's Dominion => Behemoths_Dominion
-- Example: King Behemoth       => King_Behemoth
-- { zone name, mob name, base hitbox in yalms (mob_pools.modelHitboxSize / 10), scale }
--
-- To add another NM: add a row here AND a matching entry in the client's
-- scaled_mobs table (E:\FFXI\addons\SanctumSize\SanctumSize.lua) so the
-- visual and the real hitbox stay in sync.
--
-- Notes on names that came off the original mass list but are NOT here:
--   - Cancer (Kuftal_Tunnel, poolid 620): mob_pools.modelHitboxSize is NULL,
--     so there's no baseline to scale from. Needs an explicit target value.
--   - Father Frost (Uleguerand_Range, poolid 1303, baseline 1.5 yalms) and
--     Snow Maiden (Uleguerand_Range, poolid 3690, baseline 1.2 yalms): both
--     are pure mob_pools/mob_groups entries with no scripts/zones/.../mobs/
--     file, so there's no onMobInitialize to override here.
--   - Blackbeard: no mob_pools or mob script match at all - it's spawned as
--     part of the Ship_bound_for_Selbina_Pirates boarding event
--     (see scripts/zones/Ship_bound_for_Selbina_Pirates/IDs.lua), not a
--     standalone NM pop. Needs its own investigation.
--   - King Arthro only applies to the classic Jugner_Forest fight, not the
--     unrelated Everbloom_Hollow "King Arthro (Sandworm)" reskin that
--     happens to share the display name.
--   - Seiryu/Genbu/Suzaku/Byakko only apply to their real RuAun_Gardens
--     fights, not the "(Pet version)" duplicates summoned during the Kirin
--     encounter in The_Shrine_of_RuAvitau.
--   - Sea Horror gets two rows: it's the same NM on both ferry routes.
local nmsToScale =
{
    -- 200%
    { 'QuBia_Arena', 'Anansi', 1.9, 2.0 },
    { 'Outer_Horutoto_Ruins', 'Bomb_King', 1.3, 2.0 },
    { 'The_Shrine_of_RuAvitau', 'Kirin', 4.4, 2.0 },
    { 'Carpenters_Landing', 'Orctrap', 1.3, 2.0 },
    { 'Waughroon_Shrine', 'Queen_Jelly', 3.3, 2.0 },
    { 'Bibiki_Bay', 'Serra', 3.2, 2.0 },
    { 'Ifrits_Cauldron', 'Tarasque', 1.8, 2.0 },
    -- 150%
    { 'The_Boyahda_Tree', 'Aquarius', 1.6, 1.5 },
    { 'Maze_of_Shakhrami', 'Argus', 1.6, 1.5 },
    { 'QuBia_Arena', 'Beelzebub', 1.3, 1.5 },
    { 'Pashhow_Marshlands', 'Bloodpool_Vorax', 1.2, 1.5 },
    { 'Ifrits_Cauldron', 'Bomb_Queen', 1.6, 1.5 },
    { 'Buburimu_Peninsula', 'Buburimboo', 3.2, 1.5 },
    { 'Sea_Serpent_Grotto', 'Charybdis', 2.5, 1.5 },
    { 'Crawlers_Nest', 'Demonic_Tiphia', 1.1, 1.5 },
    { 'Waughroon_Shrine', 'Flayer_Franz', 1.8, 1.5 },
    { 'Beaucedine_Glacier', 'Gargantua', 2.2, 1.5 },
    { 'Balgas_Dais', 'Giant_Moa', 3.7, 1.5 },
    { 'Carpenters_Landing', 'Hercules_Beetle', 1.1, 1.5 },
    { 'Jugner_Forest', 'King_Arthro', 1.6, 1.5 },
    { 'Behemoths_Dominion', 'King_Behemoth', 4.5, 1.5 },
    { 'Maze_of_Shakhrami', 'Leech_King', 1.5, 1.5 },
    { 'Fort_Ghelsba', 'Orcish_Panzer', 2.8, 1.5 },
    { 'Jugner_Forest', 'Panzer_Percival', 1.4, 1.5 },
    { 'Ship_bound_for_Mhaura', 'Sea_Horror', 2.5, 1.5 },
    { 'Ship_bound_for_Selbina', 'Sea_Horror', 2.5, 1.5 },
    -- 120%
    { 'West_Ronfaure', 'Amanita', 1.2, 1.2 },
    { 'Kuftal_Tunnel', 'Arachne', 1.6, 1.2 },
    { 'Horlais_Peak', 'Aries', 5.8, 1.2 },
    { 'Crawlers_Nest', 'Awd_Goggie', 2.0, 1.2 },
    { 'North_Gustaberg', 'Bedrock_Barry', 1.1, 1.2 },
    { 'East_Ronfaure', 'Bigmouth_Billy', 1.4, 1.2 },
    { 'Balgas_Dais', 'Bitoso', 2.0, 1.2 },
    { 'RuAun_Gardens', 'Byakko', 3.6, 1.2 },
    { 'South_Gustaberg', 'Carnero', 2.7, 1.2 },
    { 'Dangruf_Wadi', 'Chocoboleech', 1.2, 1.2 },
    { 'Ghelsba_Outpost', 'Colo-colo', 1.4, 1.2 },
    { 'Castle_Zvahl_Keep', 'Count_Bifrons', 2.0, 1.2 },
    { 'Sauromugue_Champaign', 'Deadly_Dodo', 4.3, 1.2 },
    { 'QuBia_Arena', 'Doll_Factory', 1.0, 1.2 },
    { 'East_Sarutabaruta', 'Duke_Decapod', 1.1, 1.2 },
    { 'Crawlers_Nest', 'Dynast_Beetle', 1.2, 1.2 },
    { 'Horlais_Peak', 'Evil_Oscar', 4.4, 1.2 },
    { 'Waughroon_Shrine', 'Fee', 1.7, 1.2 },
    { 'Temple_of_Uggalepih', 'Flauros', 1.6, 1.2 },
    { 'West_Ronfaure', 'Fungus_Beetle', 1.4, 1.2 },
    { 'RuAun_Gardens', 'Genbu', 3.6, 1.2 },
    { 'Horlais_Peak', 'Gerjis', 3.6, 1.2 },
    { 'FeiYin', 'Goliath', 2.2, 1.2 },
    { 'Kuftal_Tunnel', 'Guivre', 4.4, 1.2 },
    { 'Konschtat_Highlands', 'Haty', 2.5, 1.2 },
    { 'Waughroon_Shrine', 'Heavy_Metal_Crab', 1.6, 1.2 },
    { 'Labyrinth_of_Onzozo', 'Hellion', 3.4, 1.2 },
    { 'Ghelsba_Outpost', 'Kalamainu', 1.8, 1.2 },
    { 'The_Sanctuary_of_ZiTah', 'Keeper_of_Halidom', 3.4, 1.2 },
    { 'Ghelsba_Outpost', 'Kilioa', 1.8, 1.2 },
    { 'Beaucedine_Glacier', 'Kirata', 2.9, 1.2 },
    { 'South_Gustaberg', 'Leaping_Lizzy', 1.8, 1.2 },
    { 'Labyrinth_of_Onzozo', 'Lord_of_Onzozo', 2.5, 1.2 },
    { 'Balgas_Dais', 'Macan_Gadangan', 1.6, 1.2 },
    { 'Ordelles_Caves', 'Morbolger', 4.4, 1.2 },
    { 'Korroloka_Tunnel', 'Morion_Worm', 1.4, 1.2 },
    { 'Labyrinth_of_Onzozo', 'Narasimha', 3.6, 1.2 },
    { 'The_Sanctuary_of_ZiTah', 'Noble_Mold', 1.7, 1.2 },
    { 'Beaucedine_Glacier', 'Nue', 2.9, 1.2 },
    { 'Toraimarai_Canal', 'Oni_Carcass', 3.4, 1.2 },
    { 'Balgas_Dais', 'Phoedme', 1.2, 1.2 },
    { 'Crawlers_Nest', 'Queen_Crawler', 1.7, 1.2 },
    { 'Bibiki_Bay', 'Shen', 1.6, 1.2 },
    { 'Horlais_Peak', 'Sobbing_Eyes', 1.6, 1.2 },
    { 'East_Sarutabaruta', 'Spiny_Spipi', 1.7, 1.2 },
    { 'North_Gustaberg', 'Stinging_Sophie', 1.1, 1.2 },
    { 'RuAun_Gardens', 'Suzaku', 4.4, 1.2 },
    { 'East_Ronfaure', 'Swamfisk', 3.2, 1.2 },
    { 'Waughroon_Shrine', 'Tartaruga_Gigante', 3.2, 1.2 },
    { 'South_Gustaberg', 'Tococo', 1.7, 1.2 },
    { 'West_Sarutabaruta', 'Tom_Tit_Tat', 0.9, 1.2 },
    { 'La_Theine_Plateau', 'Tumbling_Truffle', 1.7, 1.2 },
    { 'Valkurm_Dunes', 'Valkurm_Emperor', 1.7, 1.2 },
    { 'Meriphataud_Mountains', 'Waraxe_Beak', 5.3, 1.2 },
    -- 110%
    { 'Attohwa_Chasm', 'Ambusher_Antlion', 1.3, 1.1 },
    { 'Valley_of_Sorrows', 'Aspidochelone', 3.2, 1.1 },
    { 'Buburimu_Peninsula', 'Backoo', 0.8, 1.1 },
    { 'Behemoths_Dominion', 'Behemoth', 3.8, 1.1 },
    { 'La_Theine_Plateau', 'Bloodtear_Baldurf', 5.8, 1.1 },
    { 'Oldton_Movalpolos', 'Bugbear_Strongman', 1.3, 1.1 },
    { 'Western_Altepa_Desert', 'Cactuar_Cantautor', 0.9, 1.1 },
    { 'Western_Altepa_Desert', 'Celphie', 3.7, 1.1 },
    { 'Meriphataud_Mountains', 'Chonchon', 3.7, 1.1 },
    { 'Meriphataud_Mountains', 'Daggerclaw_Dracos', 2.1, 1.1 },
    { 'Rolanberry_Fields', 'Drooling_Daisy', 3.6, 1.1 },
    { 'Eastern_Altepa_Desert', 'Dune_Widow', 1.6, 1.1 },
    { 'Balgas_Dais', 'Dvorovoi', 1.1, 1.1 },
    { 'Dragons_Aery', 'Fafnir', 4.2, 1.1 },
    { 'Buburimu_Peninsula', 'Helldiver', 2.2, 1.1 },
    { 'Horlais_Peak', 'Huntfly', 2.0, 1.1 },
    { 'Bibiki_Bay', 'Intulo', 1.3, 1.1 },
    { 'Pashhow_Marshlands', 'Jolly_Green', 3.4, 1.1 },
    { 'Batallia_Downs_[S]', 'La_Velue', 2.5, 1.1 },
    { 'Waughroon_Shrine', 'Metsanneitsyt', 1.2, 1.1 },
    { 'Balgas_Dais', 'Nenaunir', 4.3, 1.1 },
    { 'Quicksand_Caves', 'Nussknacker', 1.8, 1.1 },
    { 'Garlaige_Citadel', 'Old_Two-Wings', 1.8, 1.1 },
    { 'Balgas_Dais', 'Opo-opo_Monarch', 2.6, 1.1 },
    { 'Monastic_Cavern', 'Orcish_Warlord', 1.7, 1.1 },
    { 'Balgas_Dais', 'Pepper', 1.2, 1.1 },
    { 'Upper_Delkfutts_Tower', 'Porphyrion', 4.1, 1.1 },
    { 'Sauromugue_Champaign', 'Roc', 3.2, 1.1 },
    { 'Yuhtunga_Jungle', 'Rose_Garden', 3.6, 1.1 },
    { 'Sea_Serpent_Grotto', 'Sea_Hog', 3.2, 1.1 },
    { 'RuAun_Gardens', 'Seiryu', 4.4, 1.1 },
    { 'Garlaige_Citadel', 'Serket', 1.9, 1.1 },
    { 'Rolanberry_Fields', 'Simurgh', 3.6, 1.1 },
    { 'Konschtat_Highlands', 'Steelfleece_Baldarich', 5.8, 1.1 },
}

for _, entry in pairs(nmsToScale) do
    local zoneName     = entry[1]
    local mobName      = entry[2]
    local baseHitbox   = entry[3]
    local scale        = entry[4]
    local targetHitbox = baseHitbox * scale

    -- onMobInitialize fires once when the persistent mob entity is created
    -- (not on every respawn), so this sets the hitbox exactly once and it
    -- sticks across pops without compounding on repeated overrides.
    m:addOverride(string.format('xi.zones.%s.mobs.%s.onMobInitialize', zoneName, mobName),
    function(mob)
        super(mob)

        mob:setHitboxSize(targetHitbox)
        print(string.format('[nm_hitbox_scale] %s hitbox set to %.2f yalms (%.0f%% of %.2f baseline)',
            mob:getPacketName(), targetHitbox, scale * 100, baseHitbox))
    end)
end

return m
