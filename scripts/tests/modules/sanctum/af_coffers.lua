describe('Sanctum artifact coffers', function()
    local cofferLevelByZone =
    {
        [xi.zone.SEA_SERPENT_GROTTO]   = 55,
        [xi.zone.QUICKSAND_CAVES]      = 55,
        [xi.zone.KUFTAL_TUNNEL]        = 60,
        [xi.zone.TORAIMARAI_CANAL]     = 60,
        [xi.zone.THE_BOYAHDA_TREE]     = 60,
        [xi.zone.IFRITS_CAULDRON]      = 60,
        [xi.zone.TEMPLE_OF_UGGALEPIH] = 60,
        [xi.zone.DEN_OF_RANCOR]        = 65,
    }

    it('contains a balanced and level-appropriate 45-piece distribution', function()
        local distribution = xi.sanctum.afCoffers
        local zoneCounts   = {}
        local jobZones     = {}

        assert(#distribution.classicDistribution == 30)
        assert(#distribution.additionalDistribution == 15)

        local function validateEntry(entry)
            local cofferLevel = cofferLevelByZone[entry.zone]

            assert(cofferLevel)
            assert(entry.level <= cofferLevel)
            assert(cofferLevel - entry.level <= 7)

            zoneCounts[entry.zone] = (zoneCounts[entry.zone] or 0) + 1
            jobZones[entry.job] = jobZones[entry.job] or {}
            assert(not jobZones[entry.job][entry.zone])
            jobZones[entry.job][entry.zone] = true
        end

        for _, entry in ipairs(distribution.classicDistribution) do
            validateEntry(entry)
        end

        local seenBits = {}
        for _, entry in ipairs(distribution.additionalDistribution) do
            validateEntry(entry)
            assert(not seenBits[entry.bit])
            seenBits[entry.bit] = true
        end

        for zoneId, _ in pairs(cofferLevelByZone) do
            assert(zoneCounts[zoneId] >= 5)
            assert(zoneCounts[zoneId] <= 6)
        end

        assert(zoneCounts[xi.zone.DEN_OF_RANCOR] == 6)
    end)

    it('selects only Dancer armor the character can equip', function()
        local player       = xi.test.world:spawnPlayer({ job = xi.job.DNC, level = 99 })
        local distribution = xi.sanctum.afCoffers

        for _, entry in ipairs(distribution.additionalDistribution) do
            if entry.job == xi.job.DNC then
                local rewardId = distribution.resolveReward(player, entry)

                assert(rewardId)
                assert(player:canEquipItem(rewardId, false))
                assert(rewardId == entry.items[1] or rewardId == entry.items[2])
            end
        end
    end)

    it('awards and records an additional AF piece through a real coffer trade', function()
        local player = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.SEA_SERPENT_GROTTO,
            job   = xi.job.BLU,
            level = 99,
        })

        player:addQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.TRANSFORMATIONS)
        player:setCharVar('[BLUAF]Current', 2)
        player:addItem(xi.item.GROTTO_COFFER_KEY)

        xi.test.world:skipTime(6)
        player.actions:tradeNpc('Treasure_Coffer',
        {
            {
                itemId   = xi.item.GROTTO_COFFER_KEY,
                quantity = 1,
            },
        })
        xi.test.world:skipTime(3)

        player.assert:hasItem(xi.item.MAGUS_SHALWAR)
        assert(utils.mask.getBit(player:getCharVar(xi.sanctum.afCoffers.cofferVar), 0))
    end)

    it('keeps Dancer coffer rewards after the WotG-free quest override loads', function()
        local player = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.QUICKSAND_CAVES,
            job   = xi.job.DNC,
            level = 99,
        })
        local dancerEntry = xi.sanctum.afCoffers.additionalDistribution[10]
        local rewardId    = xi.sanctum.afCoffers.resolveReward(player, dancerEntry)

        player:addQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_ROAD_TO_DIVADOM)
        player:completeQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_ROAD_TO_DIVADOM)
        player:addItem(xi.item.QUICKSAND_COFFER_KEY)

        xi.test.world:skipTime(6)
        player.actions:tradeNpc('Treasure_Coffer',
        {
            {
                itemId   = xi.item.QUICKSAND_COFFER_KEY,
                quantity = 1,
            },
        })
        xi.test.world:skipTime(3)

        player.assert:hasItem(rewardId)
        assert(utils.mask.getBit(player:getCharVar(xi.sanctum.afCoffers.cofferVar), dancerEntry.bit))
    end)

    it('keeps Scholar coffer rewards after the WotG-free quest override loads', function()
        local player = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.SEA_SERPENT_GROTTO,
            job   = xi.job.SCH,
            level = 99,
        })
        local scholarEntry = xi.sanctum.afCoffers.additionalDistribution[13]

        player:addQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DOWNWARD_HELIX)
        player:completeQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DOWNWARD_HELIX)
        player:addItem(xi.item.GROTTO_COFFER_KEY)

        xi.test.world:skipTime(6)
        player.actions:tradeNpc('Treasure_Coffer',
        {
            {
                itemId   = xi.item.GROTTO_COFFER_KEY,
                quantity = 1,
            },
        })
        xi.test.world:skipTime(3)

        player.assert:hasItem(scholarEntry.item)
        assert(utils.mask.getBit(player:getCharVar(xi.sanctum.afCoffers.cofferVar), scholarEntry.bit))
    end)

    it('does not accept materials for a legacy Blue Mage commission', function()
        local player = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.AHT_URHGAN_WHITEGATE,
            job   = xi.job.BLU,
            level = 99,
        })
        local materials =
        {
            xi.item.GOLD_CHAIN,
            xi.item.SQUARE_OF_VELVET_CLOTH,
            xi.item.CHUNK_OF_FLAN_MEAT,
            xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH,
        }

        player:setCharVar('[BLUAF]Remaining', 7)
        player:setCharVar('[BLUAF]Current', 2)
        player:setCharVar('[BLUAF]CraftingStage', 0)

        for _, itemId in ipairs(materials) do
            player:addItem(itemId)
        end

        player.actions:tradeNpc('Lathuya', materials)

        assert(player:getCharVar('[BLUAF]CraftingStage') == 0)
        for _, itemId in ipairs(materials) do
            player.assert:hasItem(itemId)
        end
    end)
end)
