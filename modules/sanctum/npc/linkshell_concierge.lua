local concierge = require('scripts/globals/sanctum/linkshell_concierge')

local m = Module:new('linkshell_concierge')
local entity = {}

entity.onTrigger = function(player, npc)
    concierge.onTrigger(player, npc)
end

xi.module.ensureTable('xi.zones.Lower_Jeuno.npcs')
xi.zones.Lower_Jeuno.npcs.Linkshell_Concierge = entity

-- Keep the Adoulin entry dormant until that content is opened.
m:addOverride('xi.zones.Eastern_Adoulin.npcs.Eppel-Treppel.onTrigger', function()
end)

return m
