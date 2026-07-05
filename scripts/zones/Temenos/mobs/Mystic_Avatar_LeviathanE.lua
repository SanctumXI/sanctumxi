-----------------------------------
-- Area: Temenos Eastern Tower
--  Mob: Mystic Avatar (Leviathan)
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    xi.mix.jobSpecial.config(mob, {
        delay = math.randomInt(45, 90),
        specials =
        {
            { id = 866, hpp = math.randomInt(30, 55) }, -- uses Tidal Wave once while near 50% HPP.
        },
    })
end

return entity
