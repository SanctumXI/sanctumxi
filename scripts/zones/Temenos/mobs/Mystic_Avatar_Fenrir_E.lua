-----------------------------------
-- Area: Temenos Eastern Tower
--  Mob: Mystic Avatar (Fenrir)
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
            { id = 838, hpp = math.randomInt(15, 55) }, -- uses Howling Moon once while near 50% HPP.
        },
    })
end

return entity
