-- Sanctum custom family values translated to the species-based family system.
-- Shinryu intentionally keeps upstream ecosystem 17 (SupremeBeings).
-- Loaded after the core mob_family_system table by dbtool.

UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 1; -- Acuex
UPDATE `mob_family_system` SET `speed` = 30 WHERE `familyID` = 3; -- Botulus
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 5; -- Flan
UPDATE `mob_family_system` SET `speed` = 30 WHERE `familyID` = 7; -- Hecteye
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 12; -- Plovid
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 14; -- Sandworm
UPDATE `mob_family_system` SET `speed` = 35, `detects` = 34 WHERE `familyID` = 16; -- Clot
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 17; -- Scum
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 18; -- Slime
UPDATE `mob_family_system` SET `ACC` = 3 WHERE `familyID` = 23; -- Worm
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 29; -- Craklaw
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 32; -- Toad
UPDATE `mob_family_system` SET `speed` = 40 WHERE `familyID` = 34; -- Orobon
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 35; -- Pteraketo
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 38; -- Pugil
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 39; -- Rockfin
UPDATE `mob_family_system` SET `speed` = 45 WHERE `familyID` = 40; -- Ruszor
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 42; -- Sea_Monk
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 45; -- Acrolith
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 46; -- Bomb
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 47; -- Djinn
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 48; -- Snoll
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 49; -- Batons
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 50; -- Coins
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 51; -- Cups
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 52; -- Swords
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 53; -- Bishop
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 54; -- King
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 55; -- Knight
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 56; -- Pawn
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 57; -- Queen
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 58; -- Rook
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 59; -- Cluster
UPDATE `mob_family_system` SET `speed` = 55, `DEF` = 1, `ACC` = 2, `EVA` = 5 WHERE `familyID` = 60; -- Doll
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 61; -- Gargoyles
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 62; -- Evil_Weapon
UPDATE `mob_family_system` SET `speed` = 55, `DEF` = 1, `ACC` = 2, `EVA` = 5 WHERE `familyID` = 63; -- Golem
UPDATE `mob_family_system` SET `DEF` = 1, `ACC` = 2, `EVA` = 5 WHERE `familyID` = 64; -- Red_Golems
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 65; -- Grimoire
UPDATE `mob_family_system` SET `speed` = 70 WHERE `familyID` = 67; -- Khimaira
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 69; -- Magic_Pot
UPDATE `mob_family_system` SET `speed` = 55, `DEF` = 1, `EVA` = 5 WHERE `familyID` = 71; -- Marolith
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 75; -- Chariot
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 79; -- Gear
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 81; -- Triple_Gear
UPDATE `mob_family_system` SET `DEF` = 1, `EVA` = 5 WHERE `familyID` = 82; -- Iron_Giant
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 84; -- Rampart
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 85; -- Behemoth
UPDATE `mob_family_system` SET `speed` = 45 WHERE `familyID` = 88; -- Buffalo
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 90; -- Cerberus
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 91; -- Orthrus
UPDATE `mob_family_system` SET `speed` = 35 WHERE `familyID` = 95; -- Dhalmel
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 96; -- Gnole
UPDATE `mob_family_system` SET `speed` = 62, `detects` = 257 WHERE `familyID` = 97; -- Legendary_Manticore
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 98; -- Manticore
UPDATE `mob_family_system` SET `speed` = 40 WHERE `familyID` = 99; -- Marid
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 100; -- Opo-opo
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 106; -- Rabbit
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 111; -- Sheep
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 112; -- Legendary_Tigers
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 116; -- Yztarg
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2 WHERE `familyID` = 117; -- Antica
UPDATE `mob_family_system` SET `speed` = 50, `ACC` = 2 WHERE `familyID` = 118; -- Bugbear
UPDATE `mob_family_system` SET `speed` = 45, `ACC` = 2 WHERE `familyID` = 121; -- Gigas
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 124; -- Armored_Goblin
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2, `detects` = 1 WHERE `familyID` = 126; -- Goblin
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 127; -- Moblin
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 128; -- Experimental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 129; -- Lamiae
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 130; -- Medusa
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 131; -- Merrow
UPDATE `mob_family_system` SET `speed` = 55, `detects` = 1 WHERE `familyID` = 132; -- Knight_Ja
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 136; -- Meeble
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 138; -- Moogle
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2, `detects` = 1 WHERE `familyID` = 139; -- Orc
UPDATE `mob_family_system` SET `speed` = 30, `VIT` = 3, `AGI` = 4, `MND` = 3, `DEF` = 1, `ACC` = 2, `EVA` = 4 WHERE `familyID` = 143; -- Orcish_Warmachine
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 144; -- Blue_Poroggo
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 145; -- Green_Poroggo
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 146; -- Red_Poroggo
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2, `detects` = 1 WHERE `familyID` = 147; -- Qiqirn
UPDATE `mob_family_system` SET `ACC` = 2, `detects` = 2 WHERE `familyID` = 150; -- Quadav
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2 WHERE `familyID` = 151; -- Blue_Sahagin
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2 WHERE `familyID` = 152; -- Yellow_Sahagin
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 153; -- Shadow_Lord
UPDATE `mob_family_system` SET `speed` = 25 WHERE `familyID` = 159; -- Tonberry
UPDATE `mob_family_system` SET `speed` = 45, `ACC` = 2, `detects` = 1 WHERE `familyID` = 163; -- Troll
UPDATE `mob_family_system` SET `speed` = 55, `detects` = 1 WHERE `familyID` = 164; -- Blue_Velkk
UPDATE `mob_family_system` SET `speed` = 55, `detects` = 1 WHERE `familyID` = 165; -- Red_Velkk
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2 WHERE `familyID` = 168; -- Yagudo
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 169; -- Amphiptere
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 171; -- Apkallu
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 173; -- Bat
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 175; -- Bird
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 177; -- Cockatrice
UPDATE `mob_family_system` SET `speed` = 65, `EVA` = 1 WHERE `familyID` = 179; -- Colibri
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 181; -- Flock_Bat
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 188; -- Gagana
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 189; -- Legendary_Roc
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 190; -- Roc
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 192; -- Tulfaire
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 194; -- Waktza
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 195; -- Ahriman
UPDATE `mob_family_system` SET `speed` = 55, `detects` = 1 WHERE `familyID` = 201; -- Kindred
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 204; -- Dvergr
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 205; -- Warden
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 208; -- Gargouille
UPDATE `mob_family_system` SET `speed` = 60, `EVA` = 2 WHERE `familyID` = 212; -- Imp
UPDATE `mob_family_system` SET `speed` = 55, `detects` = 226 WHERE `familyID` = 215; -- Soulflayer
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 217; -- Taurus
UPDATE `mob_family_system` SET `speed` = 35 WHERE `familyID` = 218; -- Dahak
UPDATE `mob_family_system` SET `speed` = 35 WHERE `familyID` = 219; -- Dragon
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 222; -- Hydra
UPDATE `mob_family_system` SET `speed` = 65, `EVA` = 2 WHERE `familyID` = 224; -- Puk
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 225; -- Black_Feathered
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 226; -- Black_Wyrm
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 227; -- Blue_Wyrm
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 229; -- Earth_Wyrm
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 230; -- Orange_Wyrm
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 235; -- Wyvern
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 236; -- Blue_Wyvern
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 237; -- Shadow_Wyvern
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 238; -- Zilant
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 239; -- Alexander
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 240; -- Atomos
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 241; -- Bahamut
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 242; -- Cait_Sith
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 243; -- Carbuncle
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 245; -- Diabolos
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 247; -- Garuda
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 248; -- Ifrit
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 249; -- Leviathan
UPDATE `mob_family_system` SET `speed` = 70 WHERE `familyID` = 250; -- Odin
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 252; -- Ramuh
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 253; -- Shiva
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 254; -- Siren
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 256; -- Air_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 259; -- Dark_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 260; -- Earth_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 261; -- Fire_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 263; -- Ice_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 264; -- Light_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 265; -- Thunder_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 267; -- Water_Elemental
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 268; -- Heartwing
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 270; -- Macuil
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 272; -- Monoceros
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 274; -- Pixie
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 279; -- Umbril
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 281; -- Craver
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 290; -- Wanderer
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 293; -- Elvaan
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 294; -- Galks
UPDATE `mob_family_system` SET `speed` = 55, `ACC` = 2 WHERE `familyID` = 295; -- Humes
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 296; -- Mithra
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 297; -- Tarutaru
UPDATE `mob_family_system` SET `speed` = 40, `EVA` = 5 WHERE `familyID` = 298; -- Adamantoise
UPDATE `mob_family_system` SET `EVA` = 5 WHERE `familyID` = 300; -- Legendary_Adamantoise
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 302; -- Bugard
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 303; -- Eft
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 306; -- Ash_Lizard
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 307; -- Hill_Lizard
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 308; -- Snow_Lizard
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 312; -- Peiste
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 315; -- Raptor
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 319; -- Wivre
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 320; -- Aern
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 321; -- Euvhi
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 322; -- Hpemde
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 324; -- Wynav
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 327; -- Yovra
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 328; -- Bird_Ghrah
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 331; -- Zdei
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 332; -- Belladonna
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 334; -- Sabotender
UPDATE `mob_family_system` SET `speed` = 45 WHERE `familyID` = 336; -- Flytrap
UPDATE `mob_family_system` SET `speed` = 45 WHERE `familyID` = 338; -- Funguar
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 342; -- Leafkin
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 350; -- Mandragora
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 352; -- Ameretat
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 353; -- Morbol
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 354; -- Morbol_Menace
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 357; -- Panopt
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 359; -- Rafflesia
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 360; -- Sapling
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 362; -- Snapweed
UPDATE `mob_family_system` SET `speed` = 45 WHERE `familyID` = 366; -- Treant
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 369; -- Yggdreant
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 379; -- Tubes
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 382; -- Automaton
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 383; -- Cloud_of_Darkness
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 384; -- Hades
UPDATE `mob_family_system` SET `superFamilyID` = 95, `speed` = 75, `HP` = 130 WHERE `familyID` = 387; -- Promathia
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 388; -- Provenance_Watcher
UPDATE `mob_family_system` SET `speed` = 55, `HP` = 130, `MP` = 130, `STR` = 2, `DEX` = 3, `VIT` = 3, `AGI` = 5, `INT` = 3, `MND` = 6, `CHR` = 5, `DEF` = 1, `EVA` = 5, `detects` = 34 WHERE `familyID` = 390; -- Shinryu
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 391; -- Corpselight
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 394; -- Corse
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 396; -- Kumakatok
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 397; -- Defiant
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 398; -- Doomed
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 399; -- Dullahan
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 402; -- Fallen
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 403; -- Fomor
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 404; -- Hydra_Fomor
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 407; -- Bhoot
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 408; -- Ghost
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 409; -- Hound
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 411; -- Naraka
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 414; -- Qutrub
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 415; -- Shadow
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 416; -- Draugar
UPDATE `mob_family_system` SET `speed` = 50, `CHR` = 4 WHERE `familyID` = 419; -- Skeleton
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 421; -- Vampyr
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 422; -- Antlion
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 428; -- Yellow_Bee
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 429; -- Beetle
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 432; -- Bztavian
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 434; -- Chapuli
UPDATE `mob_family_system` SET `speed` = 70 WHERE `familyID` = 435; -- Chigoe
UPDATE `mob_family_system` SET `speed` = 70 WHERE `familyID` = 436; -- Djigga
UPDATE `mob_family_system` SET `speed` = 50 WHERE `familyID` = 437; -- Crawler
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 439; -- Eruca
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 442; -- Diremite
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 444; -- Fly
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 447; -- Gnat
UPDATE `mob_family_system` SET `speed` = 65 WHERE `familyID` = 449; -- Ladybug
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 452; -- Golden_Mantid
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 453; -- Green_Mantid
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 454; -- Red_Mantid
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 458; -- Great_Scorpion
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 460; -- Scorpion
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 464; -- Spider
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 467; -- Fluturini
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 468; -- Twitherym
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 470; -- Wamoura
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 471; -- Wamouracampa
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 472; -- Amoeban
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 473; -- Clionid
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 474; -- Limule
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 475; -- Murex
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 476; -- Animated_Weapons
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 477; -- Omega
UPDATE `mob_family_system` SET `speed` = 60 WHERE `familyID` = 482; -- Ultima
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 483; -- Mammet
UPDATE `mob_family_system` SET `speed` = 55 WHERE `familyID` = 484; -- Unclassified
