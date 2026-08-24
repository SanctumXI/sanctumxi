local function standardRules(minLevel, levelCap, waveDelayMs, maxSpawnDistance)
    return
    {
        minPlayers        = 1,
        maxPlayers        = 6,
        minLevel          = minLevel,
        levelCap          = levelCap,
        participantRange = 50,
        timeLimitSeconds  = 30 * 60,
        monitorDelayMs    = 5000,
        waveDelayMs       = waveDelayMs,
        spawn =
        {
            minDistance = 3,
            maxDistance = maxSpawnDistance,
            attempts    = 20,
        },
    }
end

local definitions =
{
    {
        key      = 'westernAltepa',
        zoneName = 'Western_Altepa_Desert',
        zoneId   = xi.zone.WESTERN_ALTEPA_DESERT,
        tier     = 50,
        rift =
        {
            name = 'Gauntlet Rift',
            look = 1045,
            position =
            {
                x        = 290,
                y        = 1.5,
                z        = 101,
                rotation = 0,
            },
        },

        entry =
        {
            itemId   = xi.item.WATER_CRYSTAL,
            quantity = 1,
        },

        rules =
        {
            minPlayers        = 1,
            maxPlayers        = 6,
            minLevel          = 40,
            levelCap          = 50,
            participantRange = 50,
            timeLimitSeconds  = 30 * 60,
            monitorDelayMs    = 5000,
            waveDelayMs       = 90000,
            spawn =
            {
                minDistance = 3,
                maxDistance = 10,
                attempts    = 20,
            },
        },

        waveCount = 7,
        waves =
        {
            {
                mobs =
                {
                    { mob = 'doomWorm', count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'doomWorm', count = 3 },
                },
            },
            {
                mobs =
                {
                    { mob = 'doomWorm', count = 5 },
                },
            },
            {
                mobs =
                {
                    { mob = 'doomWorm', count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'doomWorm', count = 3 },
                },
            },
            {
                reward =
                {
                    exp     = 30000,
                    message = 'You receive bonus EXP for clearing all normal enemy waves.',
                },
                mobs =
                {
                    { mob = 'doomWorm', count = 3 },
                },
            },
            {
                bossWave = true,
                message  = 'A Gauntlet boss has appeared!',
                reward =
                {
                    exp     = 50000,
                    message = 'You receive bonus EXP for defeating the Gauntlet boss!',
                },
                mobs =
                {
                    {
                        mob   = 'bastardWorm',
                        count = 1,
                        drops =
                        {
                            fixed =
                            {
                                { itemId = xi.item.FLINT_STONE, rate = 1000, quantity = 1 },
                            },
                        },
                    },
                },
            },
        },
    },

    {
        key      = 'valkurmLevel30',
        zoneName = 'Valkurm_Dunes',
        zoneId   = xi.zone.VALKURM_DUNES,
        tier     = 30,

        rift =
        {
            name = 'Gauntlet Rift',
            look = 1045,
            position =
            {
                x        = 350.637,
                y        = -9.071,
                z        = 88.798,
                rotation = 0,
            },
        },

        entry =
        {
            itemId   = xi.item.EARTH_CRYSTAL,
            quantity = 1,
        },

        rules = standardRules(25, 30, 75000, 10),

        waveCount = 7,
        waves =
        {
            {
                mobs =
                {
                    { mob = 'duneLizard', count = 3 },
                },
            },
            {
                mobs =
                {
                    { mob = 'duneLizard', count = 2 },
                    { mob = 'duneLeech',  count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'duneLeech', count = 5 },
                },
            },
            {
                bossWave       = true,
                message        = 'The Dune Queen has entered the gauntlet!',
                nextWaveDelayMs = 120000,
                reward =
                {
                    exp     = 5000,
                    message = 'You receive bonus EXP for defeating the Dune Queen!',
                },
                mobs =
                {
                    {
                        mob   = 'duneQueen',
                        count = 1,
                        drops =
                        {
                            fixed =
                            {
                                { itemId = xi.item.BEASTMENS_SEAL, rate = 250 },
                            },
                        },
                    },
                },
            },
            {
                mobs =
                {
                    { mob = 'duneLizard', count = 3 },
                    { mob = 'duneLeech',  count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'duneLizard', count = 2 },
                    { mob = 'duneLeech',  count = 4 },
                },
            },
            {
                bossWave = true,
                message  = 'The Dune Sovereign has appeared!',
                reward =
                {
                    exp     = 10000,
                    message = 'You receive bonus EXP for defeating the Dune Sovereign!',
                },
                mobs =
                {
                    {
                        mob   = 'duneSovereign',
                        count = 1,
                        drops =
                        {
                            fixed =
                            {
                                { itemId = xi.item.BEASTMENS_SEAL,  rate = 500 },
                                { itemId = xi.item.EMPEROR_HAIRPIN, rate = 50 },
                            },
                        },
                    },
                },
            },
        },
    },

    {
        key      = 'kuftalLevel60',
        zoneName = 'Kuftal_Tunnel',
        zoneId   = xi.zone.KUFTAL_TUNNEL,
        tier     = 60,

        rift =
        {
            name = 'Gauntlet Rift',
            look = 1045,
            position =
            {
                x        = -52,
                y        = 0.5,
                z        = 50,
                rotation = 0,
            },
        },

        entry =
        {
            itemId   = xi.item.ICE_CRYSTAL,
            quantity = 1,
        },

        rules = standardRules(55, 60, 75000, 8),

        waveCount = 7,
        waves =
        {
            {
                mobs =
                {
                    { mob = 'kuftalLizard', count = 3 },
                },
            },
            {
                mobs =
                {
                    { mob = 'kuftalLizard', count = 2 },
                    { mob = 'kuftalCrab',   count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'kuftalCrab', count = 5 },
                },
            },
            {
                bossWave       = true,
                message        = 'Kuftal Cancer has entered the gauntlet!',
                nextWaveDelayMs = 120000,
                reward =
                {
                    exp     = 15000,
                    message = 'You receive bonus EXP for defeating Kuftal Cancer!',
                },
                mobs =
                {
                    {
                        mob   = 'kuftalCancer',
                        count = 1,
                        drops =
                        {
                            fixed =
                            {
                                { itemId = xi.item.HIGH_QUALITY_CRAB_SHELL, rate = 250 },
                            },
                        },
                    },
                },
            },
            {
                mobs =
                {
                    { mob = 'kuftalLizard', count = 3 },
                    { mob = 'kuftalCrab',   count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'kuftalLizard', count = 2 },
                    { mob = 'kuftalCrab',   count = 4 },
                },
            },
            {
                bossWave = true,
                message  = 'The Kuftal Tyrant has appeared!',
                reward =
                {
                    exp     = 30000,
                    message = 'You receive bonus EXP for defeating the Kuftal Tyrant!',
                },
                mobs =
                {
                    {
                        mob   = 'kuftalTyrant',
                        count = 1,
                        drops =
                        {
                            fixed =
                            {
                                { itemId = xi.item.LIZARD_SKIN,  rate = 1000, quantity = 2 },
                                { itemId = xi.item.KINDREDS_SEAL, rate = 350 },
                            },
                        },
                    },
                },
            },
        },
    },

    {
        key      = 'ruAunLevel75',
        zoneName = 'RuAun_Gardens',
        zoneId   = xi.zone.RUAUN_GARDENS,
        tier     = 75,

        rift =
        {
            name = 'Gauntlet Rift',
            look = 1045,
            positions =
            {
                {
                    x        = -150,
                    y        = -30,
                    z        = -350.782,
                    rotation = 0,
                },
                {
                    x        = 147.930,
                    y        = -30,
                    z        = -345.017,
                    rotation = 47,
                },
            },
        },

        entry =
        {
            itemId   = xi.item.LIGHT_CRYSTAL,
            quantity = 1,
        },

        rules = standardRules(70, 75, 75000, 8),

        waveCount = 7,
        waves =
        {
            {
                mobs =
                {
                    { mob = 'skyFlamingo', count = 3 },
                },
            },
            {
                mobs =
                {
                    { mob = 'skyFlamingo', count = 2 },
                    { mob = 'skyKeeper',   count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'skyKeeper', count = 5 },
                },
            },
            {
                bossWave       = true,
                message        = 'The Sky Guardian has entered the gauntlet!',
                nextWaveDelayMs = 120000,
                reward =
                {
                    exp     = 30000,
                    message = 'You receive bonus EXP for defeating the Sky Guardian!',
                },
                mobs =
                {
                    {
                        mob   = 'skyGuardian',
                        count = 1,
                        drops =
                        {
                            fixed =
                            {
                                { itemId = xi.item.DOLL_SHARD, rate = 1000 },
                            },
                        },
                    },
                },
            },
            {
                mobs =
                {
                    { mob = 'skyFlamingo', count = 3 },
                    { mob = 'skyKeeper',   count = 2 },
                },
            },
            {
                mobs =
                {
                    { mob = 'skyFlamingo', count = 2 },
                    { mob = 'skyKeeper',   count = 4 },
                },
            },
            {
                bossWave = true,
                message  = 'The Sky Ascendant has appeared!',
                reward =
                {
                    exp     = 60000,
                    message = 'You receive bonus EXP for defeating the Sky Ascendant!',
                },
                mobs =
                {
                    {
                        mob   = 'skyAscendant',
                        count = 1,
                        drops =
                        {
                            fixed =
                            {
                                { itemId = xi.item.DOLL_SHARD,    rate = 1000, quantity = 2 },
                                { itemId = xi.item.KINDREDS_SEAL, rate = 500 },
                            },
                        },
                    },
                },
            },
        },
    },
}

return definitions
