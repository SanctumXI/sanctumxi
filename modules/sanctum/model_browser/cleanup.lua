-----------------------------------
-- Sanctum model browser cleanup
-----------------------------------
require('modules/module_utils')

local m = Module:new('sanctum_model_browser_cleanup')

m:addOverride('xi.zones.GM_Home.Zone.onZoneOut', function(player)
    local api = rawget(_G, 'SanctumModelBrowser')
    if api ~= nil then
        api.clear(player)
    end

    super(player)
end)

return m
