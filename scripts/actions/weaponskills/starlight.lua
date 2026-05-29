-----------------------------------
-- Starlight
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local lvl = player:getSkillLevel(11) -- get club skill
    local damage = (lvl / 5.5) 
    local damagemod = damage * ((50 + (tp * 0.12)) / 150)
    damagemod = damagemod * xi.settings.main.WEAPON_SKILL_POWER
    player:addStatusEffect(xi.effect.REFRESH, { power = 1, duration = 60, origin = player })
    return 1, 0, false, damagemod
end

return weaponskillObject
