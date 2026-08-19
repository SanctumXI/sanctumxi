require('modules/module_utils')

local m = Module:new('sanctum_exp_curve_2011_75pct')

m:addOverride('xi.expDifficultyCurve.loadExpDifficultyCurve', function()
    local expToDifficultyTable =
    {
        [300] = xi.mobDifficulty.INCREDIBLY_TOUGH,
        [262] = xi.mobDifficulty.VERY_TOUGH,
        [165] = xi.mobDifficulty.TOUGH,
        [150] = xi.mobDifficulty.EVEN_MATCH,
        [120] = xi.mobDifficulty.DECENT_CHALLENGE,
        [45]  = xi.mobDifficulty.EASY_PREY,
    }

    LoadExpDifficultyCurves(expToDifficultyTable, 56, 1)
end)

return m
