describe('Sanctum Variant cosmetic camps', function()
    local data  = require('modules/sanctum/variant_system/variant_tables')
    local zones = require('modules/sanctum/variant_system/variant_zones')

    it('configures every Chainbreaker camp and assigns each cosmetic once', function()
        local cosmetics = {}
        local linkedCamps = {}
        local campCount = 0

        for _, zoneConfig in ipairs(zones) do
            local zoneCamps = data.cosmeticCamps[zoneConfig.zoneName]

            assert(zoneCamps ~= nil)
            linkedCamps[zoneConfig.zoneName] = {}

            for _, mobConfig in ipairs(zoneConfig.mobs) do
                if mobConfig.chainbreaker ~= nil then
                    local campItems = zoneCamps[mobConfig.key]

                    assert(campItems ~= nil and #campItems > 0)
                    assert(mobConfig.chainbreaker.cosmeticZone == zoneConfig.zoneName)
                    assert(mobConfig.chainbreaker.cosmeticCamp == mobConfig.key)

                    campCount = campCount + 1
                    linkedCamps[zoneConfig.zoneName][mobConfig.key] = true

                    for _, itemId in ipairs(campItems) do
                        assert(cosmetics[itemId] == nil)
                        cosmetics[itemId] = true
                    end
                end
            end
        end

        for zoneName, zoneCamps in pairs(data.cosmeticCamps) do
            assert(linkedCamps[zoneName] ~= nil)

            for campKey in pairs(zoneCamps) do
                assert(linkedCamps[zoneName][campKey] == true)
            end
        end

        local cosmeticCount = 0

        for _ in pairs(cosmetics) do
            cosmeticCount = cosmeticCount + 1
        end

        assert(campCount == 77)
        assert(cosmeticCount == 90)
    end)

    it('builds Zone Boss pools from the camps in that zone', function()
        for _, zoneConfig in ipairs(zones) do
            if zoneConfig.zoneBoss ~= nil then
                assert(zoneConfig.zoneBoss.cosmeticZone == zoneConfig.zoneName)
                assert(#zoneConfig.zoneBoss.cosmeticCamps > 0)

                for _, campKey in ipairs(zoneConfig.zoneBoss.cosmeticCamps) do
                    assert(data.cosmeticCamps[zoneConfig.zoneName][campKey] ~= nil)
                end
            end
        end
    end)

    it('places every activatable cosmetic in a level 60 or higher camp', function()
        local assignedEffects = {}

        for zoneName, zoneCamps in pairs(data.cosmeticCamps) do
            for campKey, campItems in pairs(zoneCamps) do
                for _, itemId in ipairs(campItems) do
                    if data.specialEffectCosmetics[itemId] then
                        assert(data.levelSixtyPlusCosmeticCamps[zoneName] ~= nil)
                        assert(data.levelSixtyPlusCosmeticCamps[zoneName][campKey] == true)
                        assignedEffects[itemId] = true
                    end
                end
            end
        end

        local effectCount = 0

        for itemId in pairs(data.specialEffectCosmetics) do
            assert(assignedEffects[itemId] == true)
            effectCount = effectCount + 1
        end

        assert(effectCount == 33)
    end)

    it('selects Chainbreaker cosmetics by camp without reading mob level', function()
        local rewards = require('modules/sanctum/variant_system/variant_rewards')
        local listener
        local drops = {}
        local boss = {}
        local mob = {}
        local loot = {}

        function boss:addListener(event, name, callback)
            assert(event == 'ITEM_DROPS')
            assert(name == 'SANCTUM_VARIANT_COSMETICS')
            listener = callback
        end

        function mob:getMainLvl()
            error('Cosmetic selection must not read mob level.')
        end

        function loot:addItemFixed(itemId, rate)
            assert(rate == 1000)
            drops[#drops + 1] = itemId
        end

        stub('math.randomInt', function(minimum)
            return minimum
        end)

        rewards.addCosmeticDrops(boss,
        {
            cosmeticZone     = 'Valkurm_Dunes',
            cosmeticCamp     = 'hill_lizard',
            specialCosmetics = {},
        })
        listener(mob, loot)

        assert(#drops == 2)
        assert(drops[1] == xi.item.EGG_HELM)
        assert(drops[2] == xi.item.EGG_HELM)
    end)
end)
