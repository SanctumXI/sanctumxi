-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Hugo
-- Sanctum Linkshell HNM Treasury
-----------------------------------

local treasuryNpc = require('scripts/globals/sanctum/linkshell_treasury_npc')

---@type TNpcEntity
local entity = {}

entity.onTrade = treasuryNpc.onTrade
entity.onTrigger = treasuryNpc.onTrigger

return entity
