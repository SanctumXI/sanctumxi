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

    local function applyModule(path, distanceOnly, excludePhysical)
        local module = dofile(path)
        for _, override in ipairs(module.overrides) do
            if
                (not distanceOnly or override.name:find('DistancePenalty', 1, true)) and
                (not excludePhysical or override.name ~= 'xi.weaponskills.doPhysicalWeaponskill')
            then
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
        applyModule('modules/sanctum/CombatRework/Lua/WeaponSkills/general.lua', false, true)
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

    it('moves gun STR modifiers into DEX without losing an existing DEX modifier', function()
        attacker.skill = xi.skill.MARKSMANSHIP
        local params = { str_wsc = 0.25, dex_wsc = 0.4, agi_wsc = 0.25 }
        ranged(xi.weaponskill.NUMBING_SHOT, params)
        assert(captured.str_wsc == nil)
        assert(math.abs(captured.dex_wsc - 0.65) < 0.0001)
        assert(captured.agi_wsc == 0.25)
        ranged(xi.weaponskill.NUMBING_SHOT, params)
        assert(math.abs(captured.dex_wsc - 0.65) < 0.0001)
    end)

    it('keeps STR on bows and applies the requested bow formulas', function()
        ranged(xi.weaponskill.FLAMING_ARROW, { agi_wsc = 0.25, hybridWS = true })
        assert(captured.str_wsc == 0.3 and captured.dex_wsc == 0.25 and captured.agi_wsc == nil)
        assert(captured.ftpMod[1] == 1 and captured.ftpMod[2] == 1.25 and captured.hybridWS)

        ranged(xi.weaponskill.PIERCING_ARROW, { rangedAccuracyBonus = 30 })
        assert(captured.str_wsc == 0.2 and captured.dex_wsc == nil and captured.agi_wsc == nil)
        assert(captured.ftpMod[1] == 0.75 and captured.ftpMod[3] == 1.25)
        assert(captured.ignoredDefense[1] == 0.25 and captured.ignoredDefense[3] == 0.75)
        assert(captured.rangedAccuracyBonus == 30)

        ranged(xi.weaponskill.DULLING_ARROW)
        assert(captured.str_wsc == 0.3 and captured.dex_wsc == 0.25 and captured.agi_wsc == nil)
        assert(captured.critVaries[1] == 0.1 and captured.critVaries[3] == 0.5)

        ranged(xi.weaponskill.SIDEWINDER, { accVaries = { -50, -40, -30 } })
        assert(captured.str_wsc == 0.4 and captured.dex_wsc == 0.2 and captured.agi_wsc == nil)
        assert(captured.ftpMod[1] == 4 and captured.ftpMod[3] == 5)
        assert(captured.accVaries[1] == -50 and captured.accVaries[3] == -30)

        ranged(xi.weaponskill.ARCHING_ARROW)
        assert(captured.str_wsc == 0.25 and captured.agi_wsc == 0.25 and captured.dex_wsc == nil)
        assert(captured.ftpMod[1] == 3 and captured.ftpMod[3] == 4)
        assert(captured.rangedAccuracyBonus == 100)

        ranged(xi.weaponskill.EMPYREAL_ARROW, { rangedAccuracyBonus = 100 })
        assert(captured.str_wsc == 0.3 and captured.agi_wsc == 0.2 and captured.dex_wsc == nil)
        assert(captured.atkVaries[1] == 1.5 and captured.rangedAccuracyBonus == 100)

        ranged(xi.weaponskill.NAMAS_ARROW, { rangedAccuracyBonus = 100 })
        assert(captured.str_wsc == 0.4 and captured.dex_wsc == 0.4 and captured.agi_wsc == nil)
        assert(captured.ftpMod[1] == 2 and captured.ftpMod[3] == 3.5)
        assert(captured.atkVaries[1] == 1.5 and captured.rangedAccuracyBonus == 100)

        ranged(xi.weaponskill.REFULGENT_ARROW)
        assert(captured.numHits == 2 and captured.str_wsc == 0.2)
        assert(captured.dex_wsc == nil and captured.agi_wsc == nil)

        ranged(xi.weaponskill.JISHNUS_RADIANCE, { multiHitfTP = true })
        assert(captured.str_wsc == 0.6 and captured.dex_wsc == nil and captured.multiHitfTP)
        assert(captured.ftpMod[1] == 1.5 and captured.ftpMod[2] == 1.75 and captured.ftpMod[3] == 2)
        assert(captured.critVaries[1] == 0.15 and captured.critVaries[3] == 0.45)
    end)

    it('applies magical gun modifiers without changing magical melee modifiers', function()
        local params = { skill = xi.skill.MARKSMANSHIP, str_wsc = 0.4 }
        xi.weaponskills.doMagicWeaponskill(attacker, target, xi.weaponskill.TRUEFLIGHT, params, 1000, {}, true)
        assert(captured.str_wsc == nil and captured.dex_wsc == nil)
        assert(captured.agi_wsc == 0.3 and captured.mnd_wsc == 0.3 and captured.int_wsc == nil)
        assert(captured.ftpMod[1] == 4.6 and captured.ftpMod[2] == 4.9 and captured.ftpMod[3] == 5.5)
        assert(captured.atkVaries == nil)

        params = { skill = xi.skill.MARKSMANSHIP, str_wsc = 0.4 }
        xi.weaponskills.doMagicWeaponskill(attacker, target, xi.weaponskill.LEADEN_SALUTE, params, 1000, {}, true)
        assert(captured.str_wsc == nil and captured.dex_wsc == nil)
        assert(captured.agi_wsc == 0.3 and captured.int_wsc == 0.3 and captured.mnd_wsc == nil)
        assert(captured.ftpMod[1] == 4.6 and captured.ftpMod[2] == 4.9 and captured.ftpMod[3] == 5.5)
        assert(captured.atkVaries == nil)

        params = { skill = xi.skill.SWORD, str_wsc = 0.4 }
        xi.weaponskills.doMagicWeaponskill(attacker, target, xi.weaponskill.RED_LOTUS_BLADE, params, 1000, {}, true)
        assert(captured.str_wsc == 0.4 and captured.dex_wsc == nil)
    end)

    it('enables TP-based criticals for Arching Arrow and Sniper Shot only', function()
        ranged(xi.weaponskill.ARCHING_ARROW)
        assert(captured.critVaries[1] == 0.1 and captured.critVaries[3] == 0.5)
        ranged(xi.weaponskill.SNIPER_SHOT)
        assert(captured.critVaries[1] == 0.25 and captured.critVaries[3] == 1.0)
        ranged(xi.weaponskill.SIDEWINDER)
        assert(captured.critVaries == nil)
    end)

    it('applies the requested gun formulas without adding STR', function()
        attacker.skill = xi.skill.MARKSMANSHIP

        ranged(xi.weaponskill.HOT_SHOT, { str_wsc = 0.2 })
        assert(captured.str_wsc == nil and captured.agi_wsc == 0.2 and captured.int_wsc == 0.2)

        ranged(xi.weaponskill.SNIPER_SHOT)
        assert(captured.ignoredDefense[1] == 0.1 and captured.ignoredDefense[3] == 0.3)

        ranged(xi.weaponskill.SLUG_SHOT, { accVaries = { -50, 0, 0 } })
        assert(captured.ftpMod[1] == 4.5 and captured.ftpMod[3] == 5.5)
        assert(captured.accVaries[1] == -50)

        ranged(xi.weaponskill.BLAST_SHOT, { accVaries = { 0, 30, 60 } })
        assert(captured.ftpMod[1] == 2 and captured.ftpMod[2] == 2.5 and captured.ftpMod[3] == 3)
        assert(captured.accVaries[2] == 30)

        ranged(xi.weaponskill.HEAVY_SHOT, { critVaries = { 0.1, 0.3, 0.5 } })
        assert(captured.ftpMod[1] == 3 and captured.ftpMod[2] == 3.5 and captured.ftpMod[3] == 4)
        assert(captured.critVaries[2] == 0.3)

        ranged(xi.weaponskill.DETONATOR, { rangedAccuracyBonus = 100, atkVaries = { 2, 2, 2 } })
        assert(captured.rangedAccuracyBonus == nil and captured.atkVaries[1] == 2)

        ranged(xi.weaponskill.CORONACH, { dex_wsc = 0.4, agi_wsc = 0.4, rangedAccuracyBonus = 100 })
        assert(captured.ftpMod[1] == 3 and captured.ftpMod[2] == 3.5 and captured.ftpMod[3] == 4)
        assert(captured.dex_wsc == 0.4 and captured.agi_wsc == 0.4)
        assert(captured.rangedAccuracyBonus == 100 and captured.str_wsc == nil)
    end)

    it('exempts every Blast Arrow hit without exempting another actor or later shots', function()
        rangedBody = function(actor, defender, wsID, params)
            for _ = 1, 2 do
                assert(xi.combat.ranged.attackDistancePenalty(actor, defender) == 0)
                assert(xi.combat.ranged.accuracyDistancePenalty(actor, defender) == 0)
            end

            assert(xi.combat.ranged.attackDistancePenalty(target, attacker) == 180)
            assert(xi.combat.ranged.accuracyDistancePenalty(target, attacker) == 132)
            assert(params.numHits == 1)
            assert(params.ftpMod[1] == 2.9 and params.ftpMod[2] == 3.45 and params.ftpMod[3] == 4.05)
            assert(params.str_wsc == 0.3 and params.int_wsc == 0.3)
            assert(params.accVaries[1] == 20 and params.accVaries[3] == 100)
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
