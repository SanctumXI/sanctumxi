describe('Berserk', function()
    local player

    before_each(function()
        player = xi.test.world:spawnPlayer(
            {
                job   = xi.job.WAR,
                level = 49, -- Berserk is 25% ATTP until 50
            })
    end)

    it('increases attack by 25%', function()
        player.actions:useAbility(player, xi.jobAbility.BERSERK)
        xi.test.world:tick()

        player.assert
            :hasEffect(xi.effect.BERSERK)
            :hasModifier(xi.mod.ATTP, 25)
    end)

    it('decreases defense by 25%', function()
        player.actions:useAbility(player, xi.jobAbility.BERSERK)
        xi.test.world:tick()

        player.assert:hasModifier(xi.mod.DEFP, -25)
    end)

    it('overwrites Defender', function()
        player.actions:useAbility(player, xi.jobAbility.DEFENDER)
        xi.test.world:tick()
        player.actions:useAbility(player, xi.jobAbility.BERSERK)
        xi.test.world:tick()

        player.assert
            :hasEffect(xi.effect.BERSERK)
            .no:hasEffect(xi.effect.DEFENDER)
    end)

    it('is overwritten by Defender', function()
        player.actions:useAbility(player, xi.jobAbility.BERSERK)
        xi.test.world:tick()
        player.actions:useAbility(player, xi.jobAbility.DEFENDER)
        xi.test.world:tick()

        player.assert
            :hasEffect(xi.effect.DEFENDER)
            .no:hasEffect(xi.effect.BERSERK)
    end)

    -- TODO: Test Level scaling, Conqueror, Calligae, Job points etc
end)
