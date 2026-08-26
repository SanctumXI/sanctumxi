local packetAliases =
{
    ['CB Catastrophic Weapon']  = 'CB Cata Weapon',
    ['CB Chasm Creeper']        = 'CB Chasm Creep',
    ['CB Chocoshoe Crab']       = 'CB Choco Crab',
    ['CB Crawler Queen']        = 'CB Crawl Queen',
    ['CB Drogaroga Stalker']    = 'CB Droga Stalk',
    ['CB Funerary Ichor']       = 'CB Funeral Ich',
    ['CB Goblin Postman']       = 'CB Gob Postman',
    ['CB Ironwood Horn']        = 'CB Iron Horn',
    ['CB Labyrinth Borer']      = 'CB Lab Borer',
    ['CB Lesser Vampire']       = 'CB Less Vamp',
    ['CB Ordelle Dweller']      = 'CB Ord Dweller',
    ['CB Orcish Siege Engine']  = 'CB Orc Siege',
    ['CB Orcish Warmonger']     = 'CB Orc Warmong',
    ['CB Primeval Spider']      = 'CB Prime Spider',
    ['CB Shadfly Emperor']      = 'CB Shad Emp',
    ['CB Sinister Weapon']      = 'CB Sin Weapon',
    ['CB Vociferous Vine']      = 'CB Voci Vine',
    ['CB Yagudo Bishop']        = 'CB Yag Bishop',
    ['CB Zepwell Digger']       = 'CB Zep Digger',
    ['V Apocalyptic Weapon']    = 'V Apoc Weapon',
    ['V Bark Tarantula']        = 'V Bark Tarant',
    ['V Burrow Antlion']        = 'V Bur Antlion',
    ['V Desert Dhalmel']        = 'V Des Dhalmel',
    ['V Goblin Furrier']        = 'V Gob Furrier',
    ['V Goblin Gambler']        = 'V Gob Gambler',
    ['V Goblin Leecher']        = 'V Gob Leecher',
    ['V Goblin Pathfinder']     = 'V Gob Pathfind',
    ['V Goliath Beetle']        = 'V Gol Beetle',
    ['V Hunter Antlion']        = 'V Hunt Antlion',
    ['V Jugner Funguar']        = 'V Jug Funguar',
    ['V Infernal Weapon']       = 'V Infer Weapon',
    ['V Killing Weapon']        = 'V Kill Weapon',
    ['V Ominous Weapon']        = 'V Omin Weapon',
    ['V Orcish Flamethrower']   = 'V Orc Flame',
    ['V Orcish Neckchopper']    = 'V Orc Neckchop',
    ['V Orcish Stonechucker']   = 'V Orc Stonechk',
    ['V Sabertooth Tiger']      = 'V Saber Tiger',
    ['V Tracer Antlion']        = 'V Trace Antlion',
    ['V Tracker Antlion']       = 'V Track Antlion',
    ['V Trench Antlion']        = 'V Trench Ant',
    ['V Tulwar Scorpion']       = 'V Tul Scorpion',
    ['V Wandering Sapling']     = 'V Wand Sapling',
    ['V Yagudo Assassin']       = 'V Yag Assassin',
    ['V Yagudo Chanter']        = 'V Yag Chanter',
    ['V Yagudo Conductor']      = 'V Yag Conduct',
    ['V Yagudo Conquistador']   = 'V Yag Conquist',
    ['V Yagudo Drummer']        = 'V Yag Drummer',
    ['V Yagudo Flagellant']     = 'V Yag Flagel',
    ['V Yagudo Inquisitor']     = 'V Yag Inquis',
    ['V Yagudo Interrogator']   = 'V Yag Interrog',
    ['V Yagudo Lutenist']       = 'V Yag Lutenist',
    ['V Yagudo Parasite']       = 'V Yag Parasite',
    ['V Yagudo Prelate']        = 'V Yag Prelate',
    ['V Yagudo Sentinel']       = 'V Yag Sentinel',
    ['V Yagudo Theologist']     = 'V Yag Theolog',
    ['ZB Attohwa Dreadmaw']     = 'ZB Atto Dread',
    ['ZB Batallia Nightlord']   = 'ZB Bata Night',
    ['ZB Boyahda Matriarch']    = 'ZB Boy Matri',
    ['ZB Buburimu Skyking']     = 'ZB Bubu Skyking',
    ['ZB Crawler Kingpin']      = 'ZB Crawl King',
    ['ZB Duneweaver Empress']   = 'ZB Dune Empress',
    ['ZB Garlaige Revenant']    = 'ZB Garl Reven',
    ['ZB Ghelsba Overlord']     = 'ZB Ghel Over',
    ['ZB Jugner Ironheart']     = 'ZB Jug Iron',
    ['ZB Korroloka Underlord']  = 'ZB Korr Under',
    ['ZB Kuftal Tyrant']        = 'ZB Kuft Tyrant',
    ['ZB Meriphataud Ravager']  = 'ZB Meri Ravager',
    ['ZB Ordelle Burrowlord']   = 'ZB Ord Burrow',
    ['ZB Oztroja Hierophant']   = 'ZB Ozt Hiero',
    ['ZB Pashhow Mirelord']     = 'ZB Pash Mire',
    ['ZB RoMaeve Warmaster']    = 'ZB Ro Warmast',
    ['ZB RuAun Ascendant']      = 'ZB Ruaun Asc',
    ['ZB RuAvitau Archon']      = 'ZB Rua Archon',
    ['ZB Sauromugue Warchief']  = 'ZB Sauro Chief',
    ['ZB Shakhrami Devourer']   = 'ZB Shak Devour',
    ['ZB Zepwell Sandscourge']  = 'ZB Zep Scourge',
}

local maxPacketNameLength = 15

local function getPacketAlias(packetName)
    local alias = packetAliases[packetName] or packetName

    assert(
        #alias <= maxPacketNameLength,
        string.format('Missing short packet alias for %s.', packetName))

    return alias
end

local function variantOnly(key, mobName)
    local packetName = mobName:gsub('_', ' ')

    return
    {
        key                = key,
        mobName            = mobName,
        packetName         = packetName,
        variantPacketName  = getPacketAlias('V ' .. packetName),
        variantDisplayName = 'Variant ' .. packetName,
    }
end

local function variantWithChainbreaker(key, mobName, chainbreakerName, groupId, groupZoneId, look, baseHitbox)
    local config      = variantOnly(key, mobName)
    local displayName = chainbreakerName:gsub('_', ' ')

    config.chainbreaker =
    {
        name             = chainbreakerName,
        packetName       = getPacketAlias('CB ' .. displayName),
        displayName      = displayName,
        groupId          = groupId,
        groupZoneId      = groupZoneId,
        look             = look,
        baseHitbox       = baseHitbox,
        specialCosmetics = {},
    }

    return config
end

local function withLevelRange(config, minLevel, maxLevel)
    config.minLevel = minLevel
    config.maxLevel = maxLevel

    return config
end

local function makeZoneBoss(config)
    local displayName = config.name:gsub('_', ' ')

    config.packetName       = getPacketAlias('ZB ' .. displayName)
    config.displayName      = displayName
    config.hitboxScale      = config.hitboxScale or 2.0
    config.damageMultiplier = config.damageMultiplier or 125
    config.cosmeticLevel    = config.cosmeticLevel or config.level
    config.xpPerPoint       = config.xpPerPoint or 10
    config.fallbackItem     = config.fallbackItem or
        (config.level <= 30 and xi.item.DRAGON_CHRONICLES or xi.item.MIRATETES_MEMOIRS)

    return config
end

local zones =
{
    {
        zoneId   = xi.zone.VALKURM_DUNES,
        zoneName = 'Valkurm_Dunes',
        zoneBoss =
        {
            name             = 'Valkurm_King',
            packetName       = 'ZB Valkurm King',
            displayName      = 'Valkurm King',
            groupId          = 30,
            groupZoneId      = 103,
            level            = 24,
            maxHp            = 7500,
            hitboxScale      = 2.0,
            damageMultiplier = 125,
            cosmeticLevel    = 20,
            xpPerPoint       = 10,
            xpCap            = 1500,
            fallbackItem     = xi.item.DRAGON_CHRONICLES,
            spawn =
            {
                x        = 484.84,
                y        = -15.96,
                z        = 202.45,
                rotation = 201,
            },
        },
        mobs =
        {
            {
                key                = 'thread_leech',
                mobName            = 'Thread_Leech',
                packetName         = 'Thread Leech',
                variantPacketName  = 'V Thread Leech',
                variantDisplayName = 'Variant Thread Leech',
                chainbreaker =
                {
                    name        = 'Valkurm_Leech_King',
                    packetName  = 'CB Leech King', -- The CB prefix activates the client name and size rules.
                    displayName = 'Valkurm Leech King',
                    groupId     = 26,
                    groupZoneId = 103,
                    look        = '0x00008E0700000000000000000000000000000000',
                    baseHitbox  = 1.1,
                    specialCosmetics =
                    {
                        -- Fixed drop rates use 1000 = 100%.
                        -- { itemId = xi.item.WYRMKING_MASQUE, rate = 100 },
                    },
                },
            },
            {
                key                = 'hill_lizard',
                mobName            = 'Hill_Lizard',
                packetName         = 'Hill Lizard',
                variantPacketName  = 'V Hill Lizard',
                variantDisplayName = 'Variant Hill Lizard',
                chainbreaker =
                {
                    name        = 'Leaping_Lizard',
                    packetName  = 'CB Leap Lizard',
                    displayName = 'Leaping Lizard',
                    groupId     = 23,
                    groupZoneId = 103,
                    look        = '0x0000490100000000000000000000000000000000',
                    baseHitbox  = 1.8,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.QUFIM_ISLAND,
        zoneName = 'Qufim_Island',
        zoneBoss =
        {
            name             = 'Qufim_Lord',
            packetName       = 'ZB Qufim Lord',
            displayName      = 'Qufim Lord',
            groupId          = 12,
            groupZoneId      = 126,
            look             = '0x0000830200000000000000000000000000000000',
            level            = 35,
            maxHp            = 10500,
            hitboxScale      = 2.0,
            damageMultiplier = 125,
            cosmeticLevel    = 30,
            xpPerPoint       = 10,
            xpCap            = 2500,
            fallbackItem     = xi.item.MIRATETES_MEMOIRS,
            spawn =
            {
                x        = 45.27,
                y        = -20.10,
                z        = 275.37,
                rotation = 123,
            },
        },
        mobs =
        {
            {
                key                = 'greater_pugil',
                mobName            = 'Greater_Pugil',
                packetName         = 'Greater Pugil',
                variantPacketName  = 'V Greater Pugil',
                variantDisplayName = 'Variant Greater Pugil',
                chainbreaker =
                {
                    name        = 'Sleet_Fin',
                    packetName  = 'CB Sleet Fin',
                    displayName = 'Sleet Fin',
                    groupId     = 20,
                    groupZoneId = 126,
                    look        = '0x00005E0100000000000000000000000000000000',
                    baseHitbox  = 5.0,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'land_worm',
                mobName            = 'Land_Worm',
                packetName         = 'Land Worm',
                variantPacketName  = 'V Land Worm',
                variantDisplayName = 'Variant Land Worm',
                chainbreaker =
                {
                    name        = 'Snow_Worm',
                    packetName  = 'CB Snow Worm',
                    displayName = 'Snow Worm',
                    groupId     = 8,
                    groupZoneId = 126,
                    look        = '0x0000580900000000000000000000000000000000',
                    baseHitbox  = 0.6,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'clipper',
                mobName            = 'Clipper',
                packetName         = 'Clipper',
                variantPacketName  = 'V Clipper',
                variantDisplayName = 'Variant Clipper',
                chainbreaker =
                {
                    name        = 'Icy_Shell',
                    packetName  = 'CB Icy Shell',
                    displayName = 'Icy Shell',
                    groupId     = 9,
                    groupZoneId = 126,
                    look        = '0x0000670100000000000000000000000000000000',
                    baseHitbox  = 2.5,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.KORROLOKA_TUNNEL,
        zoneName = 'Korroloka_Tunnel',
        zoneBoss =
        {
            name             = 'Korroloka_Underlord',
            packetName       = 'ZB Korroloka Underlord',
            displayName      = 'Korroloka Underlord',
            groupId          = 15,
            groupZoneId      = 173,
            level            = 34,
            maxHp            = 10500,
            hitboxScale      = 2.0,
            damageMultiplier = 125,
            cosmeticLevel    = 40,
            xpPerPoint       = 10,
            xpCap            = 2500,
            fallbackItem     = xi.item.MIRATETES_MEMOIRS,
            spawn =
            {
                x        = -216.84,
                y        = -5.00,
                z        = 76.35,
                rotation = 251,
            },
        },
        mobs =
        {
            {
                key                = 'clipper',
                mobName            = 'Clipper',
                packetName         = 'Clipper',
                variantPacketName  = 'V Clipper',
                variantDisplayName = 'Variant Clipper',
                chainbreaker =
                {
                    name        = 'Ghost_Shell',
                    packetName  = 'CB Ghost Shell',
                    displayName = 'Ghost Shell',
                    groupId     = 13,
                    groupZoneId = 173,
                    look        = '0x0000950B00000000000000000000000000000000',
                    baseHitbox  = 1.3,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'combat',
                mobName            = 'Combat',
                packetName         = 'Combat',
                variantPacketName  = 'V Combat',
                variantDisplayName = 'Variant Combat',
                chainbreaker =
                {
                    name        = 'Gloomwing',
                    packetName  = 'CB Gloomwing',
                    displayName = 'Gloomwing',
                    groupId     = 8,
                    groupZoneId = 173,
                    look        = '0x0000070100000000000000000000000000000000',
                    baseHitbox  = 1.1,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.GUSGEN_MINES,
        zoneName = 'Gusgen_Mines',
        zoneBoss =
        {
            name             = 'Nukekubi',
            packetName       = 'ZB Nukekubi',
            displayName      = 'Nukekubi',
            groupId          = 1,
            groupZoneId      = 137,
            level            = 44,
            maxHp            = 12000,
            hitboxScale      = 2.5,
            damageMultiplier = 125,
            cosmeticLevel    = 40,
            xpPerPoint       = 10,
            xpCap            = 3500,
            fallbackItem     = xi.item.MIRATETES_MEMOIRS,
            spawn =
            {
                x        = -86.44,
                y        = -38.75,
                z        = 40.08,
                rotation = 0,
            },
        },
        mobs =
        {
            {
                key                = 'bandersnatch',
                mobName            = 'Bandersnatch',
                packetName         = 'Bandersnatch',
                variantPacketName  = 'V Bandersnatch',
                variantDisplayName = 'Variant Bandersnatch',
                chainbreaker =
                {
                    name         = 'Undead_Warg',
                    packetName   = 'CB Undead Warg',
                    displayName  = 'Undead Warg',
                    groupId      = 15,
                    groupZoneId  = 196,
                    look         = '0x0000F20700000000000000000000000000000000',
                    baseHitbox   = 1.1,
                    animationSub = 4,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'myconid',
                mobName            = 'Myconid',
                packetName         = 'Myconid',
                variantPacketName  = 'V Myconid',
                variantDisplayName = 'Variant Myconid',
                chainbreaker =
                {
                    name        = 'Gravespore',
                    packetName  = 'CB Gravespore',
                    displayName = 'Gravespore',
                    groupId     = 28,
                    groupZoneId = 196,
                    look        = '0x0000D70A00000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.BATALLIA_DOWNS,
        zoneName = 'Batallia_Downs',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Batallia_Nightlord',
            groupId     = 36,
            groupZoneId = 105,
            look        = '0x0000BD0100000000000000000000000000000000',
            baseHitbox  = 2.0,
            level       = 33,
            maxHp       = 10500,
            xpCap       = 2500,
            spawn       = { x = -51.563, y = 1.160, z = 125.463, rotation = 17 },
        }),
        mobs =
        {
            {
                key                = 'may_fly',
                mobName            = 'May_Fly',
                packetName         = 'May Fly',
                variantPacketName  = 'V May Fly',
                variantDisplayName = 'Variant May Fly',
                chainbreaker =
                {
                    name        = 'Shadfly_Emperor',
                    packetName  = 'CB Shadfly Emperor',
                    displayName = 'Shadfly Emperor',
                    groupId     = 9,
                    groupZoneId = 105,
                    look        = '0x0000C10100000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'ba',
                mobName            = 'Ba',
                packetName         = 'Ba',
                variantPacketName  = 'V Ba',
                variantDisplayName = 'Variant Ba',
                chainbreaker =
                {
                    name        = 'Duskwing',
                    packetName  = 'CB Duskwing',
                    displayName = 'Duskwing',
                    groupId     = 36,
                    groupZoneId = 105,
                    look        = '0x0000BD0100000000000000000000000000000000',
                    baseHitbox  = 2.0,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.JUGNER_FOREST,
        zoneName = 'Jugner_Forest',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Jugner_Ironheart',
            groupId     = 8,
            groupZoneId = 104,
            look        = '0x00009A0100000000000000000000000000000000',
            baseHitbox  = 1.2,
            level       = 30,
            maxHp       = 9000,
            xpCap       = 2000,
            spawn       = { x = -313.503, y = -0.534, z = -346.715, rotation = 127 },
        }),
        mobs =
        {
            {
                key                = 'stag_beetle',
                mobName            = 'Stag_Beetle',
                packetName         = 'Stag Beetle',
                variantPacketName  = 'V Stag Beetle',
                variantDisplayName = 'Variant Stag Beetle',
                chainbreaker =
                {
                    name        = 'Ironwood_Horn',
                    packetName  = 'CB Ironwood Horn',
                    displayName = 'Ironwood Horn',
                    groupId     = 8,
                    groupZoneId = 104,
                    look        = '0x00009A0100000000000000000000000000000000',
                    baseHitbox  = 1.2,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'jugner_funguar',
                mobName            = 'Jugner_Funguar',
                packetName         = 'Jugner Funguar',
                variantPacketName  = 'V Jugner Funguar',
                variantDisplayName = 'Variant Jugner Funguar',
                chainbreaker =
                {
                    name        = 'Elder_Spore',
                    packetName  = 'CB Elder Spore',
                    displayName = 'Elder Spore',
                    groupId     = 12,
                    groupZoneId = 104,
                    look        = '0x0000C90800000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.CARPENTERS_LANDING,
        zoneName = 'Carpenters_Landing',
        zoneBoss =
        {
            name             = 'Droseraceae',
            packetName       = 'ZB Droseraceae',
            displayName      = 'Droseraceae',
            groupId          = 50,
            groupZoneId      = 82,
            level            = 40,
            maxHp            = 12000,
            hitboxScale      = 1.5,
            damageMultiplier = 125,
            cosmeticLevel    = 40,
            xpPerPoint       = 10,
            xpCap            = 3000,
            fallbackItem     = xi.item.MIRATETES_MEMOIRS,
            spawn =
            {
                x        = -149.21,
                y        = -2.73,
                z        = 29.25,
                rotation = 51,
            },
        },
        mobs =
        {
            {
                key                = 'battrap',
                mobName            = 'Battrap',
                packetName         = 'Battrap',
                variantPacketName  = 'V Battrap',
                variantDisplayName = 'Variant Battrap',
                chainbreaker =
                {
                    name         = 'Bloodpetal',
                    packetName   = 'CB Bloodpetal',
                    displayName  = 'Bloodpetal',
                    groupId      = 20,
                    groupZoneId  = 2,
                    look         = '0x0000050200000000000000000000000000000000',
                    baseHitbox   = 1.0,
                    animationSub = 6,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'birdtrap',
                mobName            = 'Birdtrap',
                packetName         = 'Birdtrap',
                variantPacketName  = 'V Birdtrap',
                variantDisplayName = 'Variant Birdtrap',
                chainbreaker =
                {
                    name         = 'Vociferous_Vine',
                    packetName   = 'CB Vociferous Vine',
                    displayName  = 'Vociferous Vine',
                    groupId      = 33,
                    groupZoneId  = 2,
                    look         = '0x0000F60900000000000000000000000000000000',
                    baseHitbox   = 0.8,
                    animationSub = 16,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.ROLANBERRY_FIELDS,
        zoneName = 'Rolanberry_Fields',
        zoneBoss =
        {
            name             = 'Crawler_Kingpin',
            packetName       = 'ZB Crawler Kingpin',
            displayName      = 'Crawler Kingpin',
            groupId          = 42,
            groupZoneId      = 48,
            level            = 24,
            maxHp            = 7500,
            hitboxScale      = 2.0,
            damageMultiplier = 125,
            cosmeticLevel    = 20,
            xpPerPoint       = 10,
            xpCap            = 1500,
            fallbackItem     = xi.item.DRAGON_CHRONICLES,
            spawn =
            {
                x        = -63.00,
                y        = -0.74,
                z        = -511.00,
                rotation = 87,
            },
        },
        mobs =
        {
            {
                key                = 'berry_grub',
                mobName            = 'Berry_Grub',
                packetName         = 'Berry Grub',
                variantPacketName  = 'V Berry Grub',
                variantDisplayName = 'Variant Berry Grub',
                chainbreaker =
                {
                    name        = 'Crawler_Queen',
                    packetName  = 'CB Crawler Queen',
                    displayName = 'Crawler Queen',
                    groupId     = 10,
                    groupZoneId = 110,
                    look        = '0x00008D0100000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'death_wasp',
                mobName            = 'Death_Wasp',
                packetName         = 'Death Wasp',
                variantPacketName  = 'V Death Wasp',
                variantDisplayName = 'Variant Death Wasp',
                chainbreaker =
                {
                    name        = 'Ambersting',
                    packetName  = 'CB Ambersting',
                    displayName = 'Ambersting',
                    groupId     = 7,
                    groupZoneId = 110,
                    look        = '0x0000110100000000000000000000000000000000',
                    baseHitbox  = 1.0,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.PASHHOW_MARSHLANDS,
        zoneName = 'Pashhow_Marshlands',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Pashhow_Mirelord',
            groupId     = 36,
            groupZoneId = 109,
            look        = '0x0000D70A00000000000000000000000000000000',
            baseHitbox  = 1.5,
            level       = 30,
            maxHp       = 9000,
            xpCap       = 2000,
            spawn       = { x = -67.638, y = 24.499, z = -10.570, rotation = 47 },
        }),
        mobs =
        {
            {
                key                = 'gadfly',
                mobName            = 'Gadfly',
                packetName         = 'Gadfly',
                variantPacketName  = 'V Gadfly',
                variantDisplayName = 'Variant Gadfly',
                chainbreaker =
                {
                    name        = 'Mirewing',
                    packetName  = 'CB Mirewing',
                    displayName = 'Mirewing',
                    groupId     = 6,
                    groupZoneId = 109,
                    look        = '0x0000C10100000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'marsh_funguar',
                mobName            = 'Marsh_Funguar',
                packetName         = 'Marsh Funguar',
                variantPacketName  = 'V Marsh Funguar',
                variantDisplayName = 'Variant Marsh Funguar',
                chainbreaker =
                {
                    name        = 'Bogcap',
                    packetName  = 'CB Bogcap',
                    displayName = 'Bogcap',
                    groupId     = 36,
                    groupZoneId = 109,
                    look        = '0x0000D70A00000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.BUBURIMU_PENINSULA,
        zoneName = 'Buburimu_Peninsula',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Buburimu_Skyking',
            groupId     = 8,
            groupZoneId = 118,
            look        = '0x0000BC0100000000000000000000000000000000',
            baseHitbox  = 2.0,
            level       = 29,
            maxHp       = 9000,
            xpCap       = 2000,
            spawn       = { x = -334.973, y = -23.445, z = 31.940, rotation = 127 },
        }),
        mobs =
        {
            {
                key                = 'bull_dhalmel',
                mobName            = 'Bull_Dhalmel',
                packetName         = 'Bull Dhalmel',
                variantPacketName  = 'V Bull Dhalmel',
                variantDisplayName = 'Variant Bull Dhalmel',
                chainbreaker =
                {
                    name        = 'Twiga',
                    packetName  = 'CB Twiga',
                    displayName = 'Twiga',
                    groupId     = 16,
                    groupZoneId = 118,
                    look        = '0x00004C0100000000000000000000000000000000',
                    baseHitbox  = 3.7,
                    scale       = 0.5,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'zu',
                mobName            = 'Zu',
                packetName         = 'Zu',
                variantPacketName  = 'V Zu',
                variantDisplayName = 'Variant Zu',
                chainbreaker =
                {
                    name        = 'Stormbeak',
                    packetName  = 'CB Stormbeak',
                    displayName = 'Stormbeak',
                    groupId     = 8,
                    groupZoneId = 118,
                    look        = '0x0000BC0100000000000000000000000000000000',
                    baseHitbox  = 2.0,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.MAZE_OF_SHAKHRAMI,
        zoneName = 'Maze_of_Shakhrami',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Shakhrami_Devourer',
            groupId     = 27,
            groupZoneId = 198,
            look        = '0x0000AA0100000000000000000000000000000000',
            baseHitbox  = 1.2,
            level       = 35,
            maxHp       = 10500,
            xpCap       = 2500,
            spawn       = { x = -92.158, y = 19.531, z = -46.166, rotation = 127 },
        }),
        mobs =
        {
            {
                key                = 'maze_maker',
                mobName            = 'Maze_Maker',
                packetName         = 'Maze Maker',
                variantPacketName  = 'V Maze Maker',
                variantDisplayName = 'Variant Maze Maker',
                chainbreaker =
                {
                    name        = 'Labyrinth_Borer',
                    packetName  = 'CB Labyrinth Borer',
                    displayName = 'Labyrinth Borer',
                    groupId     = 5,
                    groupZoneId = 198,
                    look        = '0x0000580900000000000000000000000000000000',
                    baseHitbox  = 1.1,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'abyss_worm',
                mobName            = 'Abyss_Worm',
                packetName         = 'Abyss Worm',
                variantPacketName  = 'V Abyss Worm',
                variantDisplayName = 'Variant Abyss Worm',
                chainbreaker =
                {
                    name        = 'Dark_Annelid',
                    packetName  = 'CB Dark Annelid',
                    displayName = 'Dark Annelid',
                    groupId     = 27,
                    groupZoneId = 198,
                    look        = '0x0000AA0100000000000000000000000000000000',
                    baseHitbox  = 1.2,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.ORDELLES_CAVES,
        zoneName = 'Ordelles_Caves',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Ordelle_Burrowlord',
            groupId     = 29,
            groupZoneId = 193,
            look        = '0x00009A0100000000000000000000000000000000',
            baseHitbox  = 1.4,
            level       = 36,
            maxHp       = 10500,
            xpCap       = 2500,
            spawn       = { x = -138.700, y = 0.005, z = 202.361, rotation = 59 },
        }),
        mobs =
        {
            {
                key                = 'dung_beetle',
                mobName            = 'Dung_Beetle',
                packetName         = 'Dung Beetle',
                variantPacketName  = 'V Dung Beetle',
                variantDisplayName = 'Variant Dung Beetle',
                chainbreaker =
                {
                    name        = 'Beetle_King',
                    packetName  = 'CB Beetle King',
                    displayName = 'Beetle King',
                    groupId     = 47,
                    groupZoneId = 288,
                    look        = '0x00009A0100000000000000000000000000000000',
                    baseHitbox  = 1.4,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'goliath_beetle',
                mobName            = 'Goliath_Beetle',
                packetName         = 'Goliath Beetle',
                variantPacketName  = 'V Goliath Beetle',
                variantDisplayName = 'Variant Goliath Beetle',
                chainbreaker =
                {
                    name        = 'Ordelle_Dweller',
                    packetName  = 'CB Ordelle Dweller',
                    displayName = 'Ordelle Dweller',
                    groupId     = 47,
                    groupZoneId = 288,
                    look        = '0x00009A0100000000000000000000000000000000',
                    baseHitbox  = 1.4,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.ATTOHWA_CHASM,
        zoneName = 'Attohwa_Chasm',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Attohwa_Dreadmaw',
            groupId     = 1,
            groupZoneId = 7,
            look        = '0x0000440500000000000000000000000000000000',
            baseHitbox  = 1.5,
            level       = 82,
            maxHp       = 30000,
            xpCap       = 7500,
            spawn       = { x = 211.707, y = 19.751, z = -2.363, rotation = 210 },
        }),
        mobs =
        {
            {
                key      = 'antlion_family',
                mobNames =
                {
                    'Tracer_Antlion',
                    'Burrow_Antlion',
                    'Hunter_Antlion',
                    'Pit_Antlion',
                    'Tracker_Antlion',
                    'Trench_Antlion',
                    'Cave_Antlion',
                },
                chainbreaker =
                {
                    name        = 'Pit_Fiend',
                    packetName  = 'CB Pit Fiend',
                    displayName = 'Pit Fiend',
                    groupId     = 1,
                    groupZoneId = 7,
                    look        = '0x0000440500000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'flesh_eater',
                mobName            = 'Flesh_Eater',
                packetName         = 'Flesh Eater',
                variantPacketName  = 'V Flesh Eater',
                variantDisplayName = 'Variant Flesh Eater',
                chainbreaker =
                {
                    name        = 'Chasm_Creeper',
                    packetName  = 'CB Chasm Creeper',
                    displayName = 'Chasm Creeper',
                    groupId     = 25,
                    groupZoneId = 7,
                    look        = '0x0000A80100000000000000000000000000000000',
                    baseHitbox  = 1.1,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.CASTLE_OZTROJA,
        zoneName = 'Castle_Oztroja',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Oztroja_Hierophant',
            groupId     = 32,
            groupZoneId = 151,
            look        = '0x00005E0200000000000000000000000000000000',
            baseHitbox  = 1.1,
            level       = 75,
            maxHp       = 24000,
            xpCap       = 6500,
            spawn       = { x = -103.000, y = -72.231, z = -124.000, rotation = 72 },
        }),
        mobs =
        {
            {
                key      = 'yagudo_family',
                mobNames =
                {
                    'Yagudo_Votary',
                    'Yagudo_Theologist',
                    'Yagudo_Priest',
                    'Yagudo_Herald',
                    'Yagudo_Oracle',
                    'Yagudo_Interrogator',
                    'Yagudo_Drummer',
                    'Yagudo_Zealot',
                    'Yagudo_Prior',
                    'Yagudo_Conquistador',
                    'Yagudo_Lutenist',
                    'Yagudo_Sentinel',
                    'Yagudo_Abbot',
                    'Yagudo_Chanter',
                    'Yagudo_Inquisitor',
                    'Yagudo_Parasite',
                    'Yagudo_Flagellant',
                    'Yagudo_Prelate',
                    'Yagudo_Conductor',
                    'Yagudo_Assassin',
                },
                chainbreaker =
                {
                    name        = 'Yagudo_Bishop',
                    packetName  = 'CB Yagudo Bishop',
                    displayName = 'Yagudo Bishop',
                    groupId     = 4,
                    groupZoneId = 151,
                    look        = '0x00005E0200000000000000000000000000000000',
                    baseHitbox  = 1.1,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'cutter',
                mobName            = 'Cutter',
                packetName         = 'Cutter',
                variantPacketName  = 'V Cutter',
                variantDisplayName = 'Variant Cutter',
                chainbreaker =
                {
                    name        = 'Chocoshoe_Crab',
                    packetName  = 'CB Chocoshoe Crab',
                    displayName = 'Chocoshoe Crab',
                    groupId     = 14,
                    groupZoneId = 151,
                    look        = '0x0000660100000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.GARLAIGE_CITADEL,
        zoneName = 'Garlaige_Citadel',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Garlaige_Revenant',
            groupId     = 36,
            groupZoneId = 200,
            look        = '0x0000070100000000000000000000000000000000',
            baseHitbox  = 1.5,
            level       = 60,
            maxHp       = 18000,
            xpCap       = 5500,
            spawn       = { x = -135.000, y = 19.000, z = 197.000, rotation = 127 },
        }),
        mobs =
        {
            {
                key                = 'funnel_bats',
                mobName            = 'Funnel_Bats',
                packetName         = 'Funnel Bats',
                variantPacketName  = 'V Funnel Bats',
                variantDisplayName = 'Variant Funnel Bats',
                chainbreaker =
                {
                    name        = 'Lesser_Vampire',
                    packetName  = 'CB Lesser Vampire',
                    displayName = 'Lesser Vampire',
                    groupId     = 36,
                    groupZoneId = 200,
                    look        = '0x0000070100000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'oil_spill',
                mobName            = 'Oil_Spill',
                packetName         = 'Oil Spill',
                variantPacketName  = 'V Oil Spill',
                variantDisplayName = 'Variant Oil Spill',
                chainbreaker =
                {
                    name        = 'Funerary_Ichor',
                    packetName  = 'CB Funerary Ichor',
                    displayName = 'Funerary Ichor',
                    groupId     = 6,
                    groupZoneId = 200,
                    look        = '0x0000250100000000000000000000000000000000',
                    baseHitbox  = 1.0,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.MERIPHATAUD_MOUNTAINS,
        zoneName = 'Meriphataud_Mountains',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Meriphataud_Ravager',
            groupId     = 35,
            groupZoneId = 119,
            look        = '0x0000C60800000000000000000000000000000000',
            baseHitbox  = 1.5,
            level       = 31,
            maxHp       = 10500,
            xpCap       = 2500,
            spawn       = { x = 360.584, y = -15.848, z = 158.942, rotation = 127 },
        }),
        mobs =
        {
            {
                key                = 'wandering_sapling',
                mobName            = 'Wandering_Sapling',
                packetName         = 'Wandering Sapling',
                variantPacketName  = 'V Wandering Sapling',
                variantDisplayName = 'Variant Wandering Sapling',
                chainbreaker =
                {
                    name        = 'Lost_Sapling',
                    packetName  = 'CB Lost Sapling',
                    displayName = 'Lost Sapling',
                    groupId     = 1,
                    groupZoneId = 119,
                    look        = '0x0000880100000000000000000000000000000000',
                    baseHitbox  = 1.1,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'raptor',
                mobName            = 'Raptor',
                packetName         = 'Raptor',
                variantPacketName  = 'V Raptor',
                variantDisplayName = 'Variant Raptor',
                chainbreaker =
                {
                    name        = 'Drogaroga_Stalker',
                    packetName  = 'CB Drogaroga Stalker',
                    displayName = 'Drogaroga Stalker',
                    groupId     = 20,
                    groupZoneId = 119,
                    look        = '0x00003D0100000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'coeurl',
                mobName            = 'Coeurl',
                packetName         = 'Coeurl',
                variantPacketName  = 'V Coeurl',
                variantDisplayName = 'Variant Coeurl',
                chainbreaker =
                {
                    name        = 'Hrothgrel',
                    packetName  = 'CB Hrothgrel',
                    displayName = 'Hrothgrel',
                    groupId     = 35,
                    groupZoneId = 119,
                    look        = '0x0000C60800000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.SAUROMUGUE_CHAMPAIGN,
        zoneName = 'Sauromugue_Champaign',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Sauromugue_Warchief',
            groupId     = 22,
            groupZoneId = 120,
            look        = '0x0000CB0200000000000000000000000000000000',
            baseHitbox  = 1.1,
            level       = 41,
            maxHp       = 12000,
            xpCap       = 3500,
            spawn       = { x = 221.956, y = 40.095, z = 353.715, rotation = 5 },
        }),
        mobs =
        {
            {
                key      = 'goblin_family',
                mobNames =
                {
                    'Goblin_Mugger',
                    'Goblin_Pathfinder',
                    'Goblin_Leecher',
                    'Goblin_Furrier',
                    'Goblin_Gambler',
                    'Goblin_Smithy',
                    'Goblin_Shaman',
                    'Goblin_Digger',
                },
                chainbreaker =
                {
                    name        = 'Goblin_Postman',
                    packetName  = 'CB Goblin Postman',
                    displayName = 'Goblin Postman',
                    groupId     = 22,
                    groupZoneId = 120,
                    look        = '0x0000CB0200000000000000000000000000000000',
                    baseHitbox  = 1.1,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key                = 'sabertooth_tiger',
                mobName            = 'Sabertooth_Tiger',
                packetName         = 'Sabertooth Tiger',
                variantPacketName  = 'V Sabertooth Tiger',
                variantDisplayName = 'Variant Sabertooth Tiger',
                chainbreaker =
                {
                    name        = 'Machairo',
                    packetName  = 'CB Machairo',
                    displayName = 'Machairo',
                    groupId     = 30,
                    groupZoneId = 120,
                    look        = '0x0000C80800000000000000000000000000000000',
                    baseHitbox  = 1.5,
                    specialCosmetics =
                    {
                    },
                },
            },
        },
    },
    {
        zoneId   = xi.zone.THE_BOYAHDA_TREE,
        zoneName = 'The_Boyahda_Tree',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Boyahda_Matriarch',
            groupId     = 30,
            groupZoneId = 153,
            look        = '0x0000390100000000000000000000000000000000',
            baseHitbox  = 1.1,
            level       = 82,
            maxHp       = 30000,
            xpCap       = 7500,
            spawn       = { x = -209.400, y = 13.800, z = 64.683, rotation = 222 },
        }),
        mobs =
        {
            variantWithChainbreaker('bark_spider', 'Bark_Spider', 'Ungolia', 5, 153,
                '0x0000380100000000000000000000000000000000', 1.1),
            variantWithChainbreaker('death_cap', 'Death_Cap', 'Kabouter', 6, 153,
                '0x0000C90800000000000000000000000000000000', 1.5),
            variantWithChainbreaker('mourioche', 'Mourioche', 'Maskinganna', 8, 153,
                '0x00002D0100000000000000000000000000000000', 0.9),
            variantWithChainbreaker('skimmer', 'Skimmer', 'Nain_Rouge', 20, 153,
                '0x0000C10100000000000000000000000000000000', 1.5),
            variantWithChainbreaker('bark_tarantula', 'Bark_Tarantula', 'Shelob', 30, 153,
                '0x0000390100000000000000000000000000000000', 1.1),
        },
    },
    {
        zoneId   = xi.zone.KUFTAL_TUNNEL,
        zoneName = 'Kuftal_Tunnel',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Kuftal_Tyrant',
            groupId     = 18,
            groupZoneId = 174,
            look        = '0x0000520900000000000000000000000000000000',
            baseHitbox  = 4.6,
            level       = 82,
            maxHp       = 30000,
            xpCap       = 7500,
            spawn       = { x = 50.299, y = 2.377, z = -17.803, rotation = 251 },
        }),
        mobs =
        {
            variantWithChainbreaker('sand_lizard', 'Sand_Lizard', 'Beithir', 7, 174,
                '0x0000490100000000000000000000000000000000', 1.3),
            variantWithChainbreaker('kuftal_digger', 'Kuftal_Digger', 'Gordian_Worm', 31, 174,
                '0x0000AB0100000000000000000000000000000000', 3.3),
            variantWithChainbreaker('ovinnik', 'Ovinnik', 'Bannik', 18, 174,
                '0x0000520900000000000000000000000000000000', 4.6),
        },
    },
    {
        zoneId   = xi.zone.EASTERN_ALTEPA_DESERT,
        zoneName = 'Eastern_Altepa_Desert',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Duneweaver_Empress',
            groupId     = 6,
            groupZoneId = 114,
            look        = '0x0000370100000000000000000000000000000000',
            baseHitbox  = 0.6,
            level       = 49,
            maxHp       = 15000,
            xpCap       = 4000,
            spawn       = { x = 386.000, y = -5.000, z = -57.000, rotation = 124 },
        }),
        mobs =
        {
            variantWithChainbreaker('giant_spider', 'Giant_Spider', 'Primeval_Spider', 6, 114,
                '0x0000370100000000000000000000000000000000', 0.6),
            variantWithChainbreaker('sand_beetle', 'Sand_Beetle', 'Boot_Thief', 8, 114,
                '0x0000980100000000000000000000000000000000', 1.2),
            variantWithChainbreaker('flesh_eater', 'Flesh_Eater', 'Dung_Eater', 13, 114,
                '0x0000580900000000000000000000000000000000', 3.3),
            variantWithChainbreaker('desert_dhalmel', 'Desert_Dhalmel', 'Okapi', 7, 114,
                '0x00004C0100000000000000000000000000000000', 3.7),
        },
    },
    {
        zoneId   = xi.zone.WESTERN_ALTEPA_DESERT,
        zoneName = 'Western_Altepa_Desert',
        zoneBoss = makeZoneBoss(
        {
            name        = 'Zepwell_Sandscourge',
            groupId     = 11,
            groupZoneId = 125,
            look        = '0x00003B0800000000000000000000000000000000',
            baseHitbox  = 3.9,
            level       = 61,
            maxHp       = 18000,
            xpCap       = 5500,
            spawn       = { x = 528.000, y = -0.020, z = 274.000, rotation = 110 },
        }),
        mobs =
        {
            variantWithChainbreaker('desert_worm', 'Desert_Worm', 'Zepwell_Digger', 7, 125,
                '0x0000AA0100000000000000000000000000000000', 1.8),
            variantWithChainbreaker('desert_dhalmel', 'Desert_Dhalmel', 'Bunyip', 6, 125,
                '0x00004C0100000000000000000000000000000000', 3.7),
            variantWithChainbreaker('desert_beetle', 'Desert_Beetle', 'Stinkbug', 12, 125,
                '0x0000100100000000000000000000000000000000', 1.1),
            variantWithChainbreaker('tulwar_scorpion', 'Tulwar_Scorpion', 'Dust_Devil', 11, 125,
                '0x00003B0800000000000000000000000000000000', 3.9),
        },
    },
    {
        zoneId   = xi.zone.RUAUN_GARDENS,
        zoneName = 'RuAun_Gardens',
        zoneBoss = makeZoneBoss(
        {
            name        = 'RuAun_Ascendant',
            groupId     = 3,
            groupZoneId = 130,
            look        = '0x0000310100000000000000000000000000000000',
            baseHitbox  = 3.0,
            level       = 83,
            maxHp       = 30000,
            xpCap       = 7500,
            spawn       = { x = 150.816, y = -30.958, z = -365.575, rotation = 75 },
        }),
        mobs =
        {
            variantWithChainbreaker('flamingo', 'Flamingo', 'Argentavis', 2, 130,
                '0x0000BD0100000000000000000000000000000000', 2.2),
            variantWithChainbreaker('groundskeeper', 'Groundskeeper', 'Ancient_Idol', 3, 130,
                '0x0000310100000000000000000000000000000000', 3.0),
        },
    },
    {
        zoneId   = xi.zone.THE_SHRINE_OF_RUAVITAU,
        zoneName = 'The_Shrine_of_RuAvitau',
        zoneBoss = makeZoneBoss(
        {
            name        = 'RuAvitau_Archon',
            groupId     = 11,
            groupZoneId = 178,
            look        = '0x0000B10100000000000000000000000000000000',
            baseHitbox  = 2.7,
            level       = 86,
            maxHp       = 33000,
            xpCap       = 8000,
            spawn       = { x = 713.000, y = -99.000, z = -588.000, rotation = 120 },
        }),
        mobs =
        {
            variantWithChainbreaker('aura_pot', 'Aura_Pot', 'Lebes', 2, 178,
                '0x00009D0100000000000000000000000000000000', 4.3),
            variantWithChainbreaker('aura_statue', 'Aura_Statue', 'Blood_Golem', 11, 178,
                '0x0000B10100000000000000000000000000000000', 2.7),
        },
    },
    {
        zoneId   = xi.zone.FORT_GHELSBA,
        zoneName = 'Fort_Ghelsba',
        zoneBoss = makeZoneBoss(
        {
            name          = 'Ghelsba_Overlord',
            groupId       = 16,
            groupZoneId   = 150,
            look          = '0x0000F30300000000000000000000000000000000',
            baseHitbox    = 1.7,
            level         = 22,
            maxHp         = 6000,
            cosmeticLevel = 20,
            xpCap         = 1500,
            spawn         = { x = 47.264, y = -49.375, z = 21.902, rotation = 127 },
        }),
        mobs =
        {
            {
                key      = 'orcish_infantry',
                minLevel = 14,
                maxLevel = 17,
                mobNames =
                {
                    'Orcish_Grunt',
                    'Orcish_Neckchopper',
                    'Orcish_Stonechucker',
                },
                chainbreaker =
                {
                    name        = 'Orcish_Warmonger',
                    packetName  = 'CB Orcish Warmonger',
                    displayName = 'Orcish Warmonger',
                    groupId     = 6,
                    groupZoneId = 155,
                    look        = '0x0000F60700000000000000000000000000000000',
                    baseHitbox  = 1.7,
                    specialCosmetics =
                    {
                    },
                },
            },
            withLevelRange(
                variantWithChainbreaker(
                    'orcish_flamethrower',
                    'Orcish_Flamethrower',
                    'Orcish_Siege_Engine',
                    46,
                    80,
                    '0x0000720800000000000000000000000000000000',
                    3.8),
                14,
                17),
        },
    },
    {
        zoneId   = xi.zone.ROMAEVE,
        zoneName = 'RoMaeve',
        zoneBoss = makeZoneBoss(
        {
            name        = 'RoMaeve_Warmaster',
            groupId     = 18,
            groupZoneId = 122,
            look        = '0x0000DE0100000000000000000000000000000000',
            baseHitbox  = 2.2,
            level       = 84,
            maxHp       = 30000,
            xpCap       = 7500,
            spawn       = { x = -120.799, y = -8.500, z = 59.911, rotation = 127 },
        }),
        mobs =
        {
            {
                key      = 'low_level_weapons',
                mobNames =
                {
                    'Killing_Weapon',
                    'Ominous_Weapon',
                },
                chainbreaker =
                {
                    name        = 'Sinister_Weapon',
                    packetName  = 'CB Sinister Weapon',
                    displayName = 'Sinister Weapon',
                    groupId     = 1,
                    groupZoneId = 177,
                    look        = '0x0000DD0100000000000000000000000000000000',
                    baseHitbox  = 2.0,
                    specialCosmetics =
                    {
                    },
                },
            },
            {
                key      = 'high_level_weapons',
                mobNames =
                {
                    'Apocalyptic_Weapon',
                    'Infernal_Weapon',
                },
                chainbreaker =
                {
                    name        = 'Catastrophic_Weapon',
                    packetName  = 'CB Catastrophic Weapon',
                    displayName = 'Catastrophic Weapon',
                    groupId     = 15,
                    groupZoneId = 206,
                    look        = '0x0000DF0100000000000000000000000000000000',
                    baseHitbox  = 2.2,
                    specialCosmetics =
                    {
                    },
                },
            },
            variantWithChainbreaker('cursed_puppet', 'Cursed_Puppet', 'Haunted_Doll', 12, 158,
                '0x0000300100000000000000000000000000000000', 3.4),
        },
    },
}

for _, zoneConfig in ipairs(zones) do
    zoneConfig.zoneBoss.packetName = getPacketAlias(zoneConfig.zoneBoss.packetName)

    for _, mobConfig in ipairs(zoneConfig.mobs) do
        if mobConfig.variantPacketName ~= nil then
            mobConfig.variantPacketName = getPacketAlias(mobConfig.variantPacketName)
        end

        if mobConfig.mobNames ~= nil then
            mobConfig.variantPacketNames = {}

            for _, mobName in ipairs(mobConfig.mobNames) do
                local packetName = mobName:gsub('_', ' ')
                local fullName   = 'V ' .. packetName
                local alias      = getPacketAlias(fullName)

                if alias ~= fullName then
                    mobConfig.variantPacketNames[mobName]    = alias
                    mobConfig.variantPacketNames[packetName] = alias
                end
            end
        end

        if mobConfig.chainbreaker ~= nil then
            mobConfig.chainbreaker.packetName = getPacketAlias(mobConfig.chainbreaker.packetName)
        end
    end
end

return zones
