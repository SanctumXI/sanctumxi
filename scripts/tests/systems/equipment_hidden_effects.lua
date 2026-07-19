describe('hidden equipment effects', function()
    it('activates Drake Ring at exactly 2000 TP without an HP requirement', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE, job = xi.job.DRG, level = 75 })
        local target = player.entities:moveTo('Wild_Rabbit')

        target:respawn()

        player:addItem(xi.item.DRAKE_RING)
        player:equipItem(xi.item.DRAKE_RING)
        player:setHP(player:getMaxHP())

        player:addTP(1999)
        assert(player:getMod(xi.mod.JUMP_CRIT_RATE) == 0, 'Drake Ring should be inactive below 2000 TP')

        player:addTP(1)
        assert(player:getMod(xi.mod.JUMP_CRIT_RATE) == 5, 'Drake Ring should grant Jump critical hit rate +5 at 2000 TP')

        local jumpParams
        local ability =
        {
            getID = function()
                return xi.jobAbility.JUMP
            end,
        }
        local action =
        {
            messageID = function()
            end,
        }

        stub('xi.weaponskills.doPhysicalWeaponskill', function(_, _, _, params)
            jumpParams = params
            return 0, false, 0, 0
        end)

        xi.job_utils.dragoon.useJump(player, target, ability, action)
        assert(jumpParams.critVaries[1] == 0.05, 'Drake Ring should add 5% critical hit rate to Jump')
    end)

    it('stacks the Moliones set with normal Souleater gear up to 12% total', function()
        local player = xi.test.world:spawnPlayer({ job = xi.job.DRK, level = 75 })

        player:addItem(xi.item.GLOOM_BREASTPLATE)
        player:addItem(xi.item.MOLIONESS_SICKLE)
        player:addItem(xi.item.MOLIONESS_RING)
        player:equipItem(xi.item.GLOOM_BREASTPLATE)
        player:equipItem(xi.item.MOLIONESS_SICKLE)
        player:equipItem(xi.item.MOLIONESS_RING)

        assert(player:getMod(xi.mod.ACC) == 10, 'Moliones set should grant accuracy +10')
        assert(player:getMod(xi.mod.SOULEATER_EFFECT_STACKABLE) == 2, 'Moliones set should grant stackable Souleater +2')

        player:addStatusEffect(xi.effect.SOULEATER, { duration = 60, origin = player })
        player:setHP(player:getMaxHP())

        local initialHP = player:getHP()
        local bonusDamage = xi.combat.damage.souleaterAddition(player)
        assert(bonusDamage == math.floor(initialHP * 0.12), 'Gloom and Moliones should respect the 12% Souleater cap')

        player:addMod(xi.mod.SOULEATER_EFFECT_STACKABLE, 20)
        player:setHP(player:getMaxHP())

        initialHP = player:getHP()
        bonusDamage = xi.combat.damage.souleaterAddition(player)
        assert(bonusDamage == math.floor(initialHP * 0.12), 'normal Souleater gear bonuses should cap at 12% total')
    end)

    it('grants pet attack and accuracy from Affinity and Fidelity Earrings at 1000 TP', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE, job = xi.job.SMN, level = 75 })

        player:spawnPet(xi.petId.CARBUNCLE)
        player:addItem(xi.item.AFFINITY_EARRING)
        player:addItem(xi.item.FIDELITY_EARRING)
        player:equipItem(xi.item.AFFINITY_EARRING)
        player:equipItem(xi.item.FIDELITY_EARRING)

        local pet              = player:getPet()
        local baselineAttack   = pet:getMod(xi.mod.ATT)
        local baselineAccuracy = pet:getMod(xi.mod.ACC)

        player:addTP(999)
        assert(pet:getMod(xi.mod.ATT) == baselineAttack, 'Affinity Earring should be inactive below 1000 TP')
        assert(pet:getMod(xi.mod.ACC) == baselineAccuracy, 'Fidelity Earring should be inactive below 1000 TP')

        player:addTP(1)
        assert(pet:getMod(xi.mod.ATT) == baselineAttack + 10, 'Affinity Earring should grant pet attack +10 at 1000 TP')
        assert(pet:getMod(xi.mod.ACC) == baselineAccuracy + 10, 'Fidelity Earring should grant pet accuracy +10 at 1000 TP')

        player:despawnPet()
        player:spawnPet(xi.petId.CARBUNCLE)
        pet = player:getPet()

        assert(pet:getMod(xi.mod.ATT) == baselineAttack + 10, 'Affinity Earring should apply to newly summoned pets')
        assert(pet:getMod(xi.mod.ACC) == baselineAccuracy + 10, 'Fidelity Earring should apply to newly summoned pets')

        player:delTP(1)
        assert(pet:getMod(xi.mod.ATT) == baselineAttack, 'Affinity Earring should be removed below 1000 TP')
        assert(pet:getMod(xi.mod.ACC) == baselineAccuracy, 'Fidelity Earring should be removed below 1000 TP')
    end)

    it('leaves a Reacton Arm user alive at 5% HP after Mijin Gakure', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE, job = xi.job.NIN, level = 75 })
        local target = player.entities:moveTo('Wild_Rabbit')

        target:respawn()

        player:addItem(xi.item.REACTON_ARM)
        player:equipItem(xi.item.REACTON_ARM)
        player:setHP(player:getMaxHP())

        local expectedHP = math.max(1, math.floor(player:getMaxHP() * 0.05))
        xi.job_utils.ninja.useMijinGakure(player, target)

        assert(player:getHP() == expectedHP, string.format('Reacton Arm should leave %d HP, got %d', expectedHP, player:getHP()))
        assert(player:getHP() > 0, 'Reacton Arm should prevent Mijin Gakure from killing its user')
    end)
end)
