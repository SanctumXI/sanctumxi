-----------------------------------
-- Moonlight
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local lvl = player:getSkillLevel(11) -- get club skill
    local damage = (lvl / 7) 
    local damagemod = damage * ((50 + (tp * 0.12)) / 160)
    damagemod = damagemod * xi.settings.main.WEAPON_SKILL_POWER
    return 1, 0, false, damagemod
end

return weaponskillObject
