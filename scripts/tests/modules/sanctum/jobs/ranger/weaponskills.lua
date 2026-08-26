describe('Sanctum ranged weapon skills', function()
    local attacker
    local target
    local captured
    local rangedBody

    local function makeEntity(id)
        local entity = { id = id, dex = 180, vit = 110, rank = 13, skill = xi.skill.ARCHERY, distance = 4 }

        function entity:getID()
            return self.id
        end

        function entity:isPC()
            return true
        end

        function entity:isMob()
            return self.mob or false
        end

        function entity:isPet()
            return self.pet or false
        end

        function entity:getStat(stat)
            if stat == xi.mod.DEX then
                return self.dex
            elseif stat == xi.mod.VIT then
                return self.vit
            end

            return 600
        end

        function entity:getRangedDmgRank()
            return self.rank
        end

        function entity:getWeaponDmgRank()
            error('Ranged WS must not read the main-hand rank')
        end

        function entity:getRACC()
            return 440
        end

        function entity:getEquippedItem(slot)
            return {}
        end

        function entity:getWeaponSkillType(slot)
            return self.skill
        end

        function entity:getWeaponSubSkillType(slot)
            return 1
        end

        function entity:getHitboxSize()
            return 1
        end

        function entity:checkDistance(other)
            return self.distance
        end

        return entity
    end

    local function applyModule(path, distanceOnly)
        local module = dofile(path)
        for _, override in ipairs(module.overrides) do
            if not distanceOnly or override.name:find('DistancePenalty', 1, true) then
                local parts = {}
                for part in override.name:gmatch('[^.]+') do
                    table.insert(parts, part)
                end

                local parent = _G
                for index = 1, #parts - 1 do
                    parent = parent[parts[index]]
                end

                applyOverride(parent, parts[#parts], override.func, override.name, path)
            end
        end
    end

    local function replaceFunction(path, func)
        -- Register automatic restoration, then use a Lua function rather than the runner's userdata stub.
        stub(path, func)
        local parts = {}
        for part in path:gmatch('[^.]+') do
            table.insert(parts, part)
        end

        local parent = _G
        for index = 1, #parts - 1 do
            parent = parent[parts[index]]
        end

        parent[parts[#parts]] = func
    end

    before_each(function()
        attacker = makeEntity(1)
        target = makeEntity(2)
        captured = nil
        rangedBody = function(_, _, _, params)
            captured = params
            return 37, false, 1, 0, nil
        end

        replaceFunction('xi.combat.physical.calculateRangedStatFactor', function()
            return -123
        end)

        replaceFunction('xi.combat.ranged.attackDistancePenalty', function()
            return 0
        end)

        replaceFunction('xi.combat.ranged.accuracyDistancePenalty', function()
            return 0
        end)

        replaceFunction('xi.weaponskills.doRangedWeaponskill', function(...)
            return rangedBody(...)
        end)

        replaceFunction('xi.weaponskills.doMagicWeaponskill', function(_, _, _, params)
            captured = params
            return 29, 1, 0
        end)

        applyModule('modules/sanctum/CombatRework/Lua/Core/ranged_changes.lua', true)
        applyModule('modules/sanctum/jobs/ranger/weaponskills.lua')
    end)

    local function ranged(wsID, params)
        return xi.weaponskills.doRangedWeaponskill(attacker, target, wsID, params or {}, 1000, {}, true)
    end

    it('uses ranged rank for the stat bonus and its upper cap', function()
        assert(xi.combat.physical.calculateRangedStatFactor(attacker, target) == 37)
        attacker.dex = 220
        assert(xi.combat.physical.calculateRangedStatFactor(attacker, target) == 42)
        attacker.rank = 14
        assert(xi.combat.physical.calculateRangedStatFactor(attacker, target) == 44)
    end)

    it('retains the ranged lower caps for weak weapons', function()
        attacker.dex = 0
        attacker.rank = 0
        assert(xi.combat.physical.calculateRangedStatFactor(attacker, target) == -2)
        attacker.rank = 1
        assert(xi.combat.physical.calculateRangedStatFactor(attacker, target) == -3)
    end)

    it('preserves the existing mob and pet stat calculations', function()
        attacker.mob = true
        assert(xi.combat.physical.calculateRangedStatFactor(attacker, target) == -123)
        attacker.mob = false
        attacker.pet = true
        assert(xi.combat.physical.calculateRangedStatFactor(attacker, target) == -123)
    end)

    it('moves ranged STR modifiers into DEX without losing an existing DEX modifier', function()
        local params = { str_wsc = 0.25, dex_wsc = 0.4, agi_wsc = 0.25 }
        ranged(xi.weaponskill.SIDEWINDER, params)
        assert(captured.str_wsc == nil)
        assert(math.abs(captured.dex_wsc - 0.65) < 0.0001)
        assert(captured.agi_wsc == 0.25)
        ranged(xi.weaponskill.SIDEWINDER, params)
        assert(math.abs(captured.dex_wsc - 0.65) < 0.0001)
    end)

    it('converts magical ranged modifiers without changing magical melee modifiers', function()
        local params = { skill = xi.skill.MARKSMANSHIP, str_wsc = 0.4 }
        xi.weaponskills.doMagicWeaponskill(attacker, target, xi.weaponskill.TRUEFLIGHT, params, 1000, {}, true)
        assert(captured.str_wsc == nil and captured.dex_wsc == 0.4)
        params = { skill = xi.skill.SWORD, str_wsc = 0.4 }
        xi.weaponskills.doMagicWeaponskill(attacker, target, xi.weaponskill.RED_LOTUS_BLADE, params, 1000, {}, true)
        assert(captured.str_wsc == 0.4 and captured.dex_wsc == nil)
    end)

    it('enables TP-based criticals for Arching Arrow and Sniper Shot only', function()
        ranged(xi.weaponskill.ARCHING_ARROW)
        assert(captured.critVaries[1] == 0.1 and captured.critVaries[3] == 0.5)
        ranged(xi.weaponskill.SNIPER_SHOT)
        assert(captured.critVaries[1] == 0.25 and captured.critVaries[3] == 0.75)
        ranged(xi.weaponskill.SIDEWINDER)
        assert(captured.critVaries == nil)
    end)

    it('exempts every Blast Arrow hit without exempting another actor or later shots', function()
        rangedBody = function(actor, defender, wsID, params)
            for _ = 1, 2 do
                assert(xi.combat.ranged.attackDistancePenalty(actor, defender) == 0)
                assert(xi.combat.ranged.accuracyDistancePenalty(actor, defender) == 0)
            end

            assert(xi.combat.ranged.attackDistancePenalty(target, attacker) == 180)
            assert(xi.combat.ranged.accuracyDistancePenalty(target, attacker) == 132)
            assert(params.ftpMod[1] == 2.3)
            return 37, false, 1, 0, nil
        end

        local damage, critical, tpHits, extraHits, shadows = ranged(xi.weaponskill.BLAST_ARROW)
        assert(damage == 37 and critical == false and tpHits == 1 and extraHits == 0 and shadows == nil)
        assert(xi.combat.ranged.attackDistancePenalty(attacker, target) == 180)
        assert(xi.combat.ranged.accuracyDistancePenalty(attacker, target) == 132)
    end)

    it('restores distance penalties when Blast Arrow raises an error', function()
        rangedBody = function(actor, defender)
            assert(xi.combat.ranged.attackDistancePenalty(actor, defender) == 0)
            error('expected Blast Arrow failure')
        end

        local ok, message = pcall(ranged, xi.weaponskill.BLAST_ARROW)
        assert(not ok and message:find('expected Blast Arrow failure', 1, true))
        assert(xi.combat.ranged.attackDistancePenalty(attacker, target) == 180)
        assert(xi.combat.ranged.accuracyDistancePenalty(attacker, target) == 132)
    end)

    it('keeps other close-range bow skills penalized and guns exempt', function()
        rangedBody = function(actor, defender)
            local expected = actor.skill == xi.skill.ARCHERY and 180 or 0
            assert(xi.combat.ranged.attackDistancePenalty(actor, defender) == expected)
            return 0, false, 0, 0, 0
        end

        ranged(xi.weaponskill.SIDEWINDER)
        attacker.skill = xi.skill.MARKSMANSHIP
        ranged(xi.weaponskill.SLUG_SHOT)
    end)
end)
