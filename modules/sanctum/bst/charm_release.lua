-----------------------------------
-- Sanctum Beastmaster charm release
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_charm_release')

m:addOverride('xi.job_utils.beastmaster.useLeave', function(player, target, ability)
    local pet          = player:getPet()
    local isCharmedMob = pet and pet:isCharmed()

    super(player, target, ability)

    if isCharmedMob then
        -- Detachment restores the mob controller, whose disengage clears hate and its battle target.
        pet:disengage()
    end
end)

return m
