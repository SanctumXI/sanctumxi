-----------------------------------
-- Shared Sanctum hard-mode HNM loot
-----------------------------------
local hardModeLoot = {}

local hardModeRewardRate = 350
local hnmPopItemRate      = 250

local hardModeRewards =
{
    xi.item.FIRE_CRYSTAL, -- TODO: Replace Placeholder Hard Mode Reward A (item ID 4096).
    xi.item.ICE_CRYSTAL,  -- TODO: Replace Placeholder Hard Mode Reward B (item ID 4097).
    xi.item.WIND_CRYSTAL, -- TODO: Replace Placeholder Hard Mode Reward C (item ID 4098).
}

local hnmPopItems =
{
    xi.item.JUG_OF_HONEY_WINE,
    xi.item.CLUMP_OF_BLUE_PONDWEED,
    xi.item.BEASTLY_SHANK,
}

hardModeLoot.register = function(mob)
    mob:addListener('ITEM_DROPS', 'SANCTUM_HARD_MODE_ITEM_DROPS', function(_, loot)
        -- Each hard-mode reward is an independent fixed 35% roll.
        for _, itemId in ipairs(hardModeRewards) do
            loot:addItemFixed(itemId, hardModeRewardRate)
        end

        -- After the other entries, one 25% gate selects at most one HNM pop item.
        if math.randomInt(1, 1000) <= hnmPopItemRate then
            local itemId = hnmPopItems[math.randomInt(1, #hnmPopItems)]

            loot:addItemFixed(itemId, 1000)
        end
    end)
end

return hardModeLoot
