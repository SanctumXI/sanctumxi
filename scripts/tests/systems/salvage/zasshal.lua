describe('Zasshal Remnants Permit purchase', function()
    ---@type CClientEntityPair
    local player

    local leujaoam = xi.assault.assaultArea.LEUJAOAM_SANCTUM

    before_each(function()
        player = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.AHT_URHGAN_WHITEGATE,
            level = 65,
        })

        player:addMission(xi.mission.log_id.TOAU, xi.mission.id.toau.GUESTS_OF_THE_EMPIRE)
        player:completeMission(xi.mission.log_id.TOAU, xi.mission.id.toau.GUESTS_OF_THE_EMPIRE)
        player:setCharVar('LAST_PERMIT', 0)
    end)

    it('charges Assault Points and grants the first permit', function()
        player:addAssaultPoint(leujaoam, 500)

        player.entities:gotoAndTrigger('Zasshal',
        {
            eventId      = 818,
            updates      = { 10 },
            finishOption = 100,
        })

        player.assert:hasKI(xi.ki.REMNANTS_PERMIT)
        assert(player:getAssaultPoint(leujaoam) == 0, 'expected the permit cost to be deducted')
        assert(player:getCharVar('LAST_PERMIT') > 0, 'expected the permit reset period to be recorded')
    end)

    it('uses the repeat-purchase event after the reset boundary', function()
        player:setCharVar('LAST_PERMIT', GetSystemTime() - (24 * 60 * 60))
        player:addAssaultPoint(leujaoam, 500)

        player.entities:gotoAndTrigger('Zasshal',
        {
            eventId      = 820,
            updates      = { 10 },
            finishOption = 100,
        })

        player.assert:hasKI(xi.ki.REMNANTS_PERMIT)
        assert(player:getAssaultPoint(leujaoam) == 0, 'expected the repeat permit cost to be deducted')
    end)

    it('rejects a forged purchase without enough points', function()
        player.entities:gotoAndTrigger('Zasshal',
        {
            eventId      = 818,
            updates      = { 10 },
            finishOption = 100,
        })

        player.assert.no:hasKI(xi.ki.REMNANTS_PERMIT)
        assert(player:getCharVar('LAST_PERMIT') == 0, 'failed purchases must not start the cooldown')
    end)

    it('clears a funded selection when an unfunded area is selected afterward', function()
        player:addAssaultPoint(leujaoam, 500)

        player.entities:gotoAndTrigger('Zasshal',
        {
            eventId      = 818,
            updates      = { 10, 11 },
            finishOption = 100,
        })

        player.assert.no:hasKI(xi.ki.REMNANTS_PERMIT)
        assert(player:getAssaultPoint(leujaoam) == 500, 'an invalid final selection must not be charged')
    end)

    it('clears a funded selection after an unknown update option', function()
        player:addAssaultPoint(leujaoam, 500)

        player.entities:gotoAndTrigger('Zasshal',
        {
            eventId      = 818,
            updates      = { 10, 99 },
            finishOption = 100,
        })

        player.assert.no:hasKI(xi.ki.REMNANTS_PERMIT)
        assert(player:getAssaultPoint(leujaoam) == 500, 'an unknown final selection must not be charged')
    end)

    it('keeps the Japanese-midnight cooldown with Rhapsody in Azure', function()
        player:addKeyItem(xi.ki.RHAPSODY_IN_AZURE)
        player:setCharVar('LAST_PERMIT', GetSystemTime())
        player.entities:gotoAndTrigger('Zasshal')
        player.events:expectNotInEvent()
    end)

    it('shows the locked event below level 65', function()
        player:setLevel(64)
        player.entities:gotoAndTrigger('Zasshal', { eventId = 817 })
    end)

    it('shows the already-owned event while holding a permit', function()
        player:addKeyItem(xi.ki.REMNANTS_PERMIT)
        player.entities:gotoAndTrigger('Zasshal', { eventId = 821 })
    end)
end)
