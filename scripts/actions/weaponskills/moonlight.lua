-----------------------------------
-- Moonlight
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

local function applyMoonlightEffects(player, member)
    if not member:isDead() and member:checkDistance(player) <= 6 then
        member:addStatusEffect(xi.effect.REFRESH, { power = 1, duration = 45, origin = player })
        member:addStatusEffect(xi.effect.REGEN, { power = 3, duration = 45, origin = player })
    end
end

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local lvl       = player:getSkillLevel(xi.skill.CLUB)
    local damage    = lvl / 7
    local damagemod = damage * ((50 + (tp * 0.12)) / 160)
    damagemod = damagemod * xi.settings.main.WEAPON_SKILL_POWER

    applyMoonlightEffects(player, player)

    for _, member in pairs(player:getPartyWithTrusts()) do
        if member:getID() ~= player:getID() then
            applyMoonlightEffects(player, member)
        end
    end

    return 1, 0, false, damagemod
end

return weaponskillObject
