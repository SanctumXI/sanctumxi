describe('Sanctum Frog Cheer', function()
    it('buffs Slippery Silas and its master without an enemy target', function()
        local player = xi.test.world:spawnPlayer(
            {
                job   = xi.job.BST,
                level = 75,
            })

        player:spawnPet(xi.petId.SLIPPERY_SILAS)
        local pet = player:getPet()

        assert(pet, 'Slippery Silas did not spawn')

        player.actions:useAbility(player, 739)
        xi.test.world:skipTime(5)

        assert(pet:hasStatusEffect(xi.effect.FROG_CHEER), 'Slippery Silas did not receive Frog Cheer')
        assert(player:hasStatusEffect(xi.effect.FROG_CHEER), 'player did not receive Frog Cheer')
    end)
end)
