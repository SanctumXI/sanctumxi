describe('Sanctum Dancer effect lifecycle', function()
    local player

    before_each(function()
        player = xi.test.world:spawnPlayer({ job = xi.job.DNC, level = 75 })
    end)

    it('does not accumulate Saber Dance double attack across repeated applications', function()
        local originalDA = player:getMod(xi.mod.DOUBLE_ATTACK)
        local originalDuration = player:getMod(xi.mod.SAMBA_PDURATION)

        for _ = 1, 10 do
            player:addStatusEffect(xi.effect.SABER_DANCE, { power = 50, subPower = 22, duration = 300, tick = 3, origin = player })
            xi.test.world:skipTime(30)
            player:delStatusEffect(xi.effect.SABER_DANCE)
            assert(player:getMod(xi.mod.DOUBLE_ATTACK) == originalDA)
            assert(player:getMod(xi.mod.SAMBA_PDURATION) == originalDuration)
        end
    end)

    it('removes the entire Fan Dance enmity bonus on replacement and expiration', function()
        local originalEnmity = player:getMod(xi.mod.ENMITY)

        for _ = 1, 10 do
            player:addStatusEffect(xi.effect.FAN_DANCE, { power = 9500, subPower = 40, duration = 300, origin = player })
            assert(player:getMod(xi.mod.ENMITY) == originalEnmity + 40)
        end

        player:delStatusEffect(xi.effect.FAN_DANCE)
        assert(player:getMod(xi.mod.ENMITY) == originalEnmity)
        player:addStatusEffect(xi.effect.FAN_DANCE, { power = 9500, subPower = 40, duration = 1, origin = player })
        xi.test.world:skipTime(2)
        assert(player:getMod(xi.mod.ENMITY) == originalEnmity)
    end)

    it('reduces Fan Dance by ten percentage points per physical hit to a fixed twenty percent floor', function()
        for startingPower = 7500, 9500, 500 do
            player:addStatusEffect(xi.effect.FAN_DANCE, { power = startingPower, subPower = 15, duration = 300, origin = player })
            local expectedPower = startingPower

            for _ = 1, 12 do
                local damage = player:physicalDmgTaken(10000)
                assert(math.abs(damage - (10000 - expectedPower)) <= 1)
                expectedPower = math.max(2000, expectedPower - 1000)
                assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == expectedPower)
            end

            assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 2000)
        end
    end)

    it('shares Fan Dance decay between melee, ranged, and monster-skill damage', function()
        player:addStatusEffect(xi.effect.FAN_DANCE, { power = 9500, subPower = 15, duration = 300, origin = player })
        player:physicalDmgTaken(1000)
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 8500)
        player:rangedDmgTaken(1000)
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 7500)
        player:handleFanDance(1000)
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 6500)
    end)

    it('keeps Fan Dance at twenty percent over time and resets on reapplication', function()
        player:addStatusEffect(xi.effect.FAN_DANCE, { power = 2000, subPower = 15, duration = 300, origin = player })
        xi.test.world:skipTime(30)
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 2000)
        assert(player:handleFanDance(1000) == 800)
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 2000)
        player:addStatusEffect(xi.effect.FAN_DANCE, { power = 9500, subPower = 15, duration = 300, origin = player })
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 9500)
    end)

    it('does not reduce damage when Fan Dance is absent', function()
        assert(player:handleFanDance(1000) == 1000)
    end)

    it('does not decay Fan Dance when a monster attack misses', function()
        local defender = xi.test.world:spawnPlayer({ job = xi.job.DNC, level = 75, zone = xi.zone.WEST_SARUTABARUTA })
        local mob = defender.entities:moveTo('Tiny_Mandragora')
        local hitCheck = stub('xi.combat.physicalHitRate.getPhysicalHitRate', 0)
        defender:addStatusEffect(xi.effect.FAN_DANCE, { power = 9500, subPower = 15, duration = 300, origin = defender })
        defender:addStatusEffect(xi.effect.ALL_MISS, { power = 1, duration = 60, origin = defender })
        mob:updateEnmity(defender)
        xi.test.world:tickEntity(mob)
        xi.test.world:skipTime(10)
        assert(#hitCheck.calls > 0)
        assert(defender:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 9500)
    end)

    it('clamps the last partial decay step without dropping below twenty percent', function()
        player:addStatusEffect(xi.effect.FAN_DANCE, { power = 2500, subPower = 15, duration = 300, origin = player })
        player:physicalDmgTaken(1000)
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 2000)
        player:physicalDmgTaken(1000)
        assert(player:getStatusEffect(xi.effect.FAN_DANCE):getPower() == 2000)
    end)

    it('cleans up Daze debuffs without changing unrelated enspell damage', function()
        local originalAttack = player:getMod(xi.mod.ATTP)
        local originalMagicAttack = player:getMod(xi.mod.MATT)
        player:setMod(xi.mod.ENSPELL_DMG, 37)
        player:addStatusEffect(xi.effect.DRAIN_DAZE, { power = 1, duration = 10, origin = player })
        assert(player:getMod(xi.mod.ATTP) == originalAttack - 10)
        player:delStatusEffect(xi.effect.DRAIN_DAZE)
        assert(player:getMod(xi.mod.ATTP) == originalAttack)
        assert(player:getMod(xi.mod.ENSPELL_DMG) == 37)
        player:addStatusEffect(xi.effect.ASPIR_DAZE, { power = 1, duration = 1, origin = player })
        assert(player:getMod(xi.mod.MATT) == originalMagicAttack - 10)
        xi.test.world:skipTime(2)
        assert(player:getMod(xi.mod.MATT) == originalMagicAttack)
    end)

    it('applies Chocobo Jig to nearby party members but not outsiders', function()
        local member = xi.test.world:spawnPlayer()
        local outsider = xi.test.world:spawnPlayer()
        member.actions:move(player:getXPos(), player:getYPos(), player:getZPos())
        outsider.actions:move(player:getXPos(), player:getYPos(), player:getZPos())
        player.actions:inviteToParty(member)
        member.actions:acceptPartyInvite()
        player.actions:useAbility(player, xi.jobAbility.CHOCOBO_JIG)
        xi.test.world:tick()
        player.assert:hasEffect(xi.effect.QUICKENING)
        member.assert:hasEffect(xi.effect.QUICKENING)
        outsider.assert.no:hasEffect(xi.effect.QUICKENING)
    end)
end)
