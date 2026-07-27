-----------------------------------
-- NM Hitbox Scale
--
-- Companion to the client-side "SanctumSize" Ashita addon, which enlarges
-- the *visual* model of configured NMs for players who have it installed.
-- That addon is purely cosmetic and client-local; it cannot change how
-- melee, weaponskills, spells, abilities, or aura ranges are actually
-- calculated, since all of that runs here on the server against
-- modelHitboxSize (see src/map/entities/mobentity.cpp,
-- src/map/ai/states/ability_state.cpp, src/map/ai/states/magic_state.cpp,
-- and src/map/status_effect_container.cpp, which all add modelHitboxSize
-- into their range checks).
--
-- This module scales that server-authoritative value to match, so the
-- bigger model is backed by a bigger real hitbox for every player, not
-- just those with the client addon installed.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('nm_hitbox_scale')
m:setEnabled(true)

-- NOTE: These names are as they are as filenames.
-- Example: Behemoth's Dominion => Behemoths_Dominion
-- Example: King Behemoth       => King_Behemoth
-- { zone name, mob name, base hitbox in yalms (mob_pools.modelHitboxSize / 10), scale }
--
-- To add another NM: add a row here AND a matching entry in the client's
-- scaled_mobs table (E:\FFXI\addons\SanctumSize\SanctumSize.lua) so the
-- visual and the real hitbox stay in sync.
local nmsToScale =
{
    -- mob_pools poolid 2255 'King_Behemoth': modelHitboxSize = 45 (raw byte) => 4.5 yalms baseline.
    { 'Behemoths_Dominion', 'King_Behemoth', 4.5, 1.5 },
}

for _, entry in pairs(nmsToScale) do
    local zoneName     = entry[1]
    local mobName      = entry[2]
    local baseHitbox   = entry[3]
    local scale        = entry[4]
    local targetHitbox = baseHitbox * scale

    -- onMobInitialize fires once when the persistent mob entity is created
    -- (not on every respawn), so this sets the hitbox exactly once and it
    -- sticks across pops without compounding on repeated overrides.
    m:addOverride(string.format('xi.zones.%s.mobs.%s.onMobInitialize', zoneName, mobName),
    function(mob)
        super(mob)

        mob:setHitboxSize(targetHitbox)
        print(string.format('[nm_hitbox_scale] %s hitbox set to %.2f yalms (%.0f%% of %.2f baseline)',
            mob:getPacketName(), targetHitbox, scale * 100, baseHitbox))
    end)
end

return m
