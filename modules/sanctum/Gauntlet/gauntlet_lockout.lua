local lockout = {}

local weeklyLimit = 3
local validTiers =
{
    [30] = true,
    [50] = true,
    [60] = true,
    [75] = true,
}

local function getVariableName(tier)
    assert(validTiers[tier], string.format('Invalid gauntlet reward tier: %s.', tostring(tier)))

    return string.format('[Gauntlet]Tier%uRewards', tier)
end

function lockout.getLimit()
    return weeklyLimit
end

function lockout.isValidTier(tier)
    return validTiers[tier] == true
end

function lockout.getClaims(player, tier)
    return math.max(0, math.min(weeklyLimit, player:getCharVar(getVariableName(tier))))
end

function lockout.getRemaining(player, tier)
    return weeklyLimit - lockout.getClaims(player, tier)
end

function lockout.claim(player, tier)
    local claims = lockout.getClaims(player, tier)

    if claims >= weeklyLimit then
        return false, claims
    end

    claims = claims + 1
    player:setCharVar(getVariableName(tier), claims, NextConquestTally())

    return true, claims
end

return lockout
