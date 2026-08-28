describe('Sanctum Dancer expansion-dependent announcements', function()
    local abysseaEnabled

    before_each(function()
        abysseaEnabled = true
        stub('xi.module.isContentEnabled', function(contentTag)
            assert(contentTag == 'ABYSSEA')
            return abysseaEnabled
        end)
    end)

    local function getAnnouncements(level)
        local announcements = {}
        local player = {}

        function player:getMainJob()
            return xi.job.DNC
        end

        function player:getMainLvl()
            return level
        end

        function player:timer(delay, callback)
            assert(delay == 1500)
            callback(self)
        end

        function player:printToPlayer(message, channel)
            assert(channel == xi.msg.channel.SYSTEM_3)
            table.insert(announcements, message)
        end

        local module = dofile('modules/sanctum/new_systems/level_up.lua')
        local onLevelUp = module.overrides[1].func
        setfenv(onLevelUp, setmetatable(
        {
            super = function()
            end,
        }, { __index = getfenv(onLevelUp) }))
        onLevelUp(player)

        return table.concat(announcements, '\n')
    end

    it('announces Conserve TP at level 50 when Abyssea content is enabled', function()
        assert(getAnnouncements(50):find('Learned job trait: [Conserve TP].', 1, true))
    end)

    it('announces Subtle Blow IV at level 70 when Abyssea content is enabled', function()
        assert(getAnnouncements(70):find('Learned job trait: [Subtle Blow IV].', 1, true))
    end)

    it('hides Conserve TP without suppressing level 50 abilities when Abyssea is disabled', function()
        abysseaEnabled = false
        local announcements = getAnnouncements(50)
        assert(not announcements:find('Conserve TP', 1, true))
        assert(announcements:find('Learned job ability: [Building Flourish].', 1, true))
        assert(announcements:find('Learned job ability: [Contradance].', 1, true))
    end)

    it('hides Subtle Blow IV without suppressing Curing Waltz IV when Abyssea is disabled', function()
        abysseaEnabled = false
        local announcements = getAnnouncements(70)
        assert(not announcements:find('Subtle Blow IV', 1, true))
        assert(announcements:find('Learned job ability: [Curing Waltz IV].', 1, true))
    end)

    it('preserves the earlier Subtle Blow announcements regardless of Abyssea settings', function()
        abysseaEnabled = false
        assert(getAnnouncements(15):find('Learned job trait: [Subtle Blow].', 1, true))
        assert(getAnnouncements(35):find('Learned job trait: [Subtle Blow II].', 1, true))
        assert(getAnnouncements(55):find('Learned job trait: [Subtle Blow III].', 1, true))
    end)
end)
