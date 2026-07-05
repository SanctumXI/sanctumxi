-----------------------------------
-- Area: Central Temenos 2nd Floor
--  Mob: Mystic Avatar (Ifrit)
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
            { id = 848, hpp = math.randomInt(30, 55) }, -- uses Inferno once while near 50% HPP.
        },
    })
end

return entity
