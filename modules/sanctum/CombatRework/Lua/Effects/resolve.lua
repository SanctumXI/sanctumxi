-----------------------------------
-- Sanctum Palisade Resolve status effect
-----------------------------------
require('modules/module_utils')
-----------------------------------

xi.module.ensureTable('xi.effects.resolve')

local m = Module:new('sanctum_combat_resolve_effect')

m:addOverride('xi.effects.resolve.onEffectGain', function(target, effect)
end)

m:addOverride('xi.effects.resolve.onEffectTick', function(target, effect)
end)

m:addOverride('xi.effects.resolve.onEffectLose', function(target, effect)
end)

return m
