-----------------------------------
-- Sanctum Labyrinth Battlefield
-----------------------------------

local waves = require("scripts/battlefields/custom/sanctum_labyrinth/waves")

local battlefieldObject = {}

-----------------------------------
-- Spawn Wave
-----------------------------------

local function spawnWave(battlefield, waveNumber)

    local wave = waves[waveNumber]

    if wave == nil then
        return
    end

    battlefield:setLocalVar("wave", waveNumber)

    local count = 0

    for _, mobID in pairs(wave.mobs) do

        SpawnMob(mobID)

        count = count + 1

    end

    battlefield:setLocalVar("mobsRemaining", count)

    battlefield:messageText(nil, wave.message)

end

-----------------------------------
-- Battlefield Enter
-----------------------------------

function battlefieldObject.onBattlefieldEnter(player, battlefield)

    if battlefield:getLocalVar("started") == 0 then

        battlefield:setLocalVar("started", 1)

        battlefield:timer(5000, function()

            spawnWave(battlefield, 1)

        end)
    end
end

-----------------------------------
-- Mob Death
-----------------------------------

function battlefieldObject.onMobDeath(battlefield, mob, player)

    local remaining = battlefield:getLocalVar("mobsRemaining")

    remaining = remaining - 1

    battlefield:setLocalVar("mobsRemaining", remaining)

    if remaining <= 0 then

        local currentWave = battlefield:getLocalVar("wave")

        if currentWave < 3 then

            battlefield:timer(8000, function()

                spawnWave(battlefield, currentWave + 1)

            end)

        else

            battlefield:messageText(nil, "The Sanctum has been conquered!")

            SpawnNPC(17800100)

            battlefield:setLocalVar("completed", 1)
            player:setCharVar(
                "sanctum_labyrinth_lockout",
                os.time() + 3600
                )

        end
    end
end

return battlefieldObject