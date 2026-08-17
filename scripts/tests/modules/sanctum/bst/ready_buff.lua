describe('Sanctum Ready Buff', function()
    it('leaves buff duration unchanged without merits', function()
        local owner = {
            getMerit = function(_, merit)
                assert(merit == xi.merit.READY_BUFF)
                return 0
            end,
        }

        assert(xi.job_utils.beastmaster.getReadyBuffDuration(owner, 90) == 90)
    end)

    it('adds five percent duration per merit', function()
        local owner = {
            getMerit = function(_, merit)
                assert(merit == xi.merit.READY_BUFF)
                return 5
            end,
        }
        local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 90)

        assert(math.abs(duration - 112.5) < 0.001)
    end)
end)
