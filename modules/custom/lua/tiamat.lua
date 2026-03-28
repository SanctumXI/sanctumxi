require('modules/module_utils')

local ID = zones[xi.zone.ATTOHWA_CHASM]

local m = Module:new('tiamat')
m:setEnabled(true)

local EARTH_CRYSTAL = xi.item.EARTH_CRYSTAL or 4099

m:addOverride('xi.zones.Attohwa_Chasm.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = '???',
        x        = -530.0,
        y        = -12.0,
        z        = -60.0,
        rotation = 128,

        onTrigger = function(player, npc)
            player:printToPlayer('The ground feels warm. Perhaps something might react to a crystal...', 0)
        end,

        onTrade = function(player, npc, trade)
            local mobId = ID.mob.TIAMAT

            if not mobId then
                player:printToPlayer('Tiamat mob ID not found.', 0)
                return
            end

            -- Require exactly 1 Earth Crystal
            if not trade:hasItemQty(EARTH_CRYSTAL, 1) or trade:getItemCount() ~= 1 then
                player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)
                return
            end

            local mob = GetMobByID(mobId)
            if not mob then
                player:printToPlayer('Tiamat mob object not found.', 0)
                return
            end

            -- Already up
            if mob:isSpawned() then
                player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)
                return
            end

            -- Local cooldown on the QM itself
            if npc:getLocalVar('tiamat_cooldown') > os.time() then
                player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)
                return
            end

            -- Important: clear any old respawn timer
            mob:setRespawnTime(0)

            if npcUtil.popFromQM(player, npc, mobId, {
                claim = true,
                hide  = 0,
                look  = true,
            }) then
                player:confirmTrade()
                npc:setLocalVar('tiamat_cooldown', os.time() + 300) -- 5 min cooldown
                player:printToPlayer('Tiamat appears!', 0)
            else
                player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)
            end
        end,
    })
end)

-- Clear Tiamat's respawn after death/despawn so the QM can pop it again later.
m:addOverride('xi.zones.Attohwa_Chasm.mobs.Tiamat.onMobDespawn', function(mob)
    super(mob)
    mob:setRespawnTime(0)
end)

m:addOverride('xi.zones.Attohwa_Chasm.mobs.Tiamat.onMobDeath', function(mob, player, optParams)
    super(mob, player, optParams)
    mob:setRespawnTime(0)
end)

return m