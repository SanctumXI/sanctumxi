-----------------------------------
-- Area: Aht Urhgan Whitegate (50)
-- NPC: Linkshell Concierge
-- !pos -80.674 0.000 -63.628 50
-----------------------------------
local concierge = require('scripts/globals/sanctum/linkshell_concierge')

---@type TNpcEntity
local entity = {}

entity.onTrigger = concierge.onTrigger

return entity
