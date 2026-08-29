-----------------------------------
-- Sanctum Dragoon jump fixes
-----------------------------------
require('modules/module_utils')
require('scripts/globals/weaponskills')
-----------------------------------

local m = Module:new('sanctum_dragoon_jumps')

-- Jumps zero extraHitsLanded for the TP math, but that happens before the damage is
-- recorded, so a jump that only lands its double attack swing reports a miss.
-- Keep the count and put it back.
m:addOverride('xi.weaponskills.takeWeaponskillDamage', function(defender, attacker, wsParams, primaryMsg, attack, wsResults, action)
    if not wsParams.isJump then
        return super(defender, attacker, wsParams, primaryMsg, attack, wsResults, action)
    end

    local hitsLanded = wsResults.extraHitsLanded or 0
    local damage     = super(defender, attacker, wsParams, primaryMsg, attack, wsResults, action)

    wsResults.extraHitsLanded = hitsLanded

    return damage
end)

return m
