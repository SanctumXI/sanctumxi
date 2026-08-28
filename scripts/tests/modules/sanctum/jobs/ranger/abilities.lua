describe('Sanctum Ranger abilities', function()
    local player
    local target
    local ability
    local action
    local shouldUseAmmo
    local rangedBody
    local eagleEyeBody

    local function makeEffect()
        local effect = { detectable = true }

        function effect:delEffectFlag(flag)
            if flag == xi.effectFlag.DETECTABLE then
                self.detectable = false
            end
        end

        function effect:addEffectFlag(flag)
            if flag == xi.effectFlag.DETECTABLE then
                self.detectable = true
            end
        end

        return effect
    end

    local function makeEntity(id)
        local entity =
        {
            id = id, effects = {}, mods = {}, merits = {}, jobPoints = {}, locals = {},
            ammoId = 18153, level = 75, distance = 5, hitbox = 1, behind = true, beside = false,
        }

        function entity:getID()
            return self.id
        end

        function entity:isPC()
            return true
        end

        function entity:getMod(mod)
            return self.mods[mod] or 0
        end

        function entity:addMod(mod, value)
            self.mods[mod] = self:getMod(mod) + value
        end

        function entity:delMod(mod, value)
            self:addMod(mod, -value)
        end

        function entity:getMerit(merit)
            return self.merits[merit] or 0
        end

        function entity:getJobPointLevel(category)
            return self.jobPoints[category] or 0
        end

        function entity:hasStatusEffect(effect)
            return self.effects[effect] ~= nil
        end

        function entity:getStatusEffect(effect)
            return self.effects[effect]
        end

        function entity:delStatusEffect(effect)
            self.effects[effect] = nil
        end

        function entity:addStatusEffect(effect, params)
            if self.rejectStatus then
                return false
            end

            self.effects[effect] = makeEffect()
            self.effects[effect].params = params
            return true
        end

        function entity:getEquipID(slot)
            return slot == xi.slot.AMMO and self.ammoId or 0
        end

        function entity:getLocalVar(name)
            return self.locals[name] or 0
        end

        function entity:setLocalVar(name, value)
            self.locals[name] = value
        end

        function entity:getMainLvl()
            return self.level
        end

        function entity:getWeaponSkillType(slot)
            return self.weaponSkillType or xi.skill.ARCHERY
        end

        function entity:removeAmmo(quantity)
            self.ammoRemoved = (self.ammoRemoved or 0) + quantity
        end

        function entity:addItem(itemId, quantity)
            self.addedItem = { id = itemId, quantity = quantity }
            return self.itemResult
        end

        function entity:getHitboxSize()
            return self.hitbox
        end

        function entity:checkDistance(other)
            return self.distance
        end

        function entity:isBehind(other, angle)
            return self.behind
        end

        function entity:isBeside(other, angle)
            return self.beside
        end

        return entity
    end

    local function applyModule(path)
        local module = dofile(path)
        for _, override in ipairs(module.overrides) do
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

    local function replaceFunction(path, func)
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
        player = makeEntity(1)
        target = makeEntity(2)
        target.vit = 100
        shouldUseAmmo = true
        rangedBody = function()
            return 100, false, 1, 0, 0
        end

        eagleEyeBody = function()
            return 500
        end

        ability = {}
        function ability:setMsg(message)
            self.message = message
        end

        action = { animation = 10 }
        function action:getAnimation(id)
            return self.animation
        end

        function action:setAnimation(id, animation)
            self.animation = animation
        end

        function action:messageID(id, message)
            self.message = message
        end

        function action:additionalEffect(id, effect)
            self.additional = effect
        end

        function action:addEffectParam(id, value)
            self.effectParam = value
        end

        replaceFunction('xi.combat.ranged.shouldUseAmmo', function()
            return shouldUseAmmo
        end)

        replaceFunction('xi.weaponskills.doRangedWeaponskill', function(...)
            return rangedBody(...)
        end)

        replaceFunction('xi.job_utils.ranger.useEagleEyeShot', function(...)
            return eagleEyeBody(...)
        end)

        replaceFunction('xi.job_utils.ranger.tryScavengeQuestItem', function()
            return false
        end)

        stub('math.randomInt', function(low, high)
            return low
        end)

        applyModule('modules/sanctum/jobs/ranger/abilities.lua')
    end)

    it('retains Unlimited Shot on a ranged WS miss and consumes it on a hit', function()
        player.effects[xi.effect.UNLIMITED_SHOT] = makeEffect()
        local ammoUsed

        rangedBody = function(attacker)
            ammoUsed = xi.combat.ranged.shouldUseAmmo(attacker)
            return 0, false, 0, 0, 0
        end

        xi.weaponskills.doRangedWeaponskill(player, target, 1, {}, 1000, action, true)
        assert(not ammoUsed)
        assert(player:hasStatusEffect(xi.effect.UNLIMITED_SHOT))

        rangedBody = function(attacker)
            ammoUsed = xi.combat.ranged.shouldUseAmmo(attacker)
            return 100, false, 1, 0, 0
        end

        xi.weaponskills.doRangedWeaponskill(player, target, 1, {}, 1000, action, true)
        assert(not ammoUsed)
        assert(not player:hasStatusEffect(xi.effect.UNLIMITED_SHOT))
    end)

    it('records only ammunition that Recycle did not save', function()
        xi.combat.ranged.shouldUseAmmo(player)
        assert(player:getLocalVar('ArrowsUsed') == player.ammoId * 10000 + 1)

        shouldUseAmmo = false
        xi.combat.ranged.shouldUseAmmo(player)
        assert(player:getLocalVar('ArrowsUsed') == player.ammoId * 10000 + 1)
    end)

    it('keeps Barrage bonuses out of ranged weapon skills without consuming Barrage', function()
        player.effects[xi.effect.BARRAGE] = makeEffect()
        player.mods[xi.mod.BARRAGE_ACC] = 20
        player.mods[xi.mod.RATT] = 160
        player.jobPoints[xi.jp.BARRAGE_EFFECT] = 20

        rangedBody = function(attacker)
            assert(attacker:getMod(xi.mod.BARRAGE_ACC) == 0)
            assert(attacker:getMod(xi.mod.RATT) == 100)
            return 100, false, 1, 0, 0
        end

        xi.weaponskills.doRangedWeaponskill(player, target, 1, {}, 1000, action, true)
        assert(player:getMod(xi.mod.BARRAGE_ACC) == 20)
        assert(player:getMod(xi.mod.RATT) == 160)
        assert(player:hasStatusEffect(xi.effect.BARRAGE))
    end)

    it('retains Camouflage at a safe distance and removes it at close range', function()
        player.effects[xi.effect.CAMOUFLAGE] = makeEffect()
        player.distance = 5

        rangedBody = function(attacker)
            assert(not attacker:getStatusEffect(xi.effect.CAMOUFLAGE).detectable)
            return 100, false, 1, 0, 0
        end

        xi.weaponskills.doRangedWeaponskill(player, target, 1, {}, 1000, action, true)
        assert(player:getStatusEffect(xi.effect.CAMOUFLAGE).detectable)

        player.effects[xi.effect.CAMOUFLAGE] = makeEffect()
        player.distance = 4.1
        xi.weaponskills.doRangedWeaponskill(player, target, 1, {}, 1000, action, true)
        assert(not player:hasStatusEffect(xi.effect.CAMOUFLAGE))
    end)

    it('interpolates Camouflage retention from both combatant hitboxes', function()
        target.hitbox = 2
        player.distance = 5.35
        player.effects[xi.effect.CAMOUFLAGE] = makeEffect()
        math.randomInt = function()
            return 69
        end

        xi.weaponskills.doRangedWeaponskill(player, target, 1, {}, 1000, action, true)
        assert(player:hasStatusEffect(xi.effect.CAMOUFLAGE))

        player.effects[xi.effect.CAMOUFLAGE] = makeEffect()
        math.randomInt = function()
            return 70
        end

        xi.weaponskills.doRangedWeaponskill(player, target, 1, {}, 1000, action, true)
        assert(not player:hasStatusEffect(xi.effect.CAMOUFLAGE))
    end)

    it('restores temporary ranged WS state when damage calculation fails', function()
        player.effects[xi.effect.CAMOUFLAGE] = makeEffect()
        player.effects[xi.effect.BARRAGE] = makeEffect()
        player.mods[xi.mod.BARRAGE_ACC] = 20
        player.mods[xi.mod.RATT] = 60
        player.jobPoints[xi.jp.BARRAGE_EFFECT] = 20
        rangedBody = function()
            error('expected ranged WS failure')
        end

        local ok, message = pcall(xi.weaponskills.doRangedWeaponskill, player, target, 1, {}, 1000, action, true)
        assert(not ok and message:find('expected ranged WS failure', 1, true))
        assert(player:getStatusEffect(xi.effect.CAMOUFLAGE).detectable)
        assert(player:getMod(xi.mod.BARRAGE_ACC) == 20)
        assert(player:getMod(xi.mod.RATT) == 60)
    end)

    it('removes only the Eagle Eye Shot Job Point bonus on success and error', function()
        player.jobPoints[xi.jp.EAGLE_EYE_SHOT_EFFECT] = 20
        player.mods[xi.mod.ALL_WSDMG_ALL_HITS] = 7
        eagleEyeBody = function(ranger)
            ranger:addMod(xi.mod.ALL_WSDMG_ALL_HITS, 60)
            return 500
        end

        assert(xi.job_utils.ranger.useEagleEyeShot(player, target, ability, action) == 500)
        assert(player:getMod(xi.mod.ALL_WSDMG_ALL_HITS) == 7)

        eagleEyeBody = function(ranger)
            ranger:addMod(xi.mod.ALL_WSDMG_ALL_HITS, 60)
            error('expected Eagle Eye Shot failure')
        end

        local ok, message = pcall(xi.job_utils.ranger.useEagleEyeShot, player, target, ability, action)
        assert(not ok and message:find('expected Eagle Eye Shot failure', 1, true))
        assert(player:getMod(xi.mod.ALL_WSDMG_ALL_HITS) == 7)
    end)

    it('keeps Scavenge credit when inventory insertion fails', function()
        player.locals.ArrowsUsed = player.ammoId * 10000 + 10
        player.itemResult = nil

        assert(xi.job_utils.ranger.useScavenge(player, player, ability, action) == nil)
        assert(player:getLocalVar('ArrowsUsed') == player.ammoId * 10000 + 10)
        assert(action.message == xi.msg.basic.SCAVENGE_FIND_NOTHING)

        player.itemResult = {}
        assert(xi.job_utils.ranger.useScavenge(player, player, ability, action) == player.ammoId)
        assert(player:getLocalVar('ArrowsUsed') == 0)
        assert(player.addedItem.quantity == 3)
        assert(action.message == xi.msg.basic.SCAVENGE_FIND_ITEMS)
    end)

    it('reports Shadowbind resistance and tracks its consumed ammunition', function()
        target.rejectStatus = true
        xi.job_utils.ranger.useShadowbind(player, target, ability, action)
        assert(ability.message == xi.msg.basic.JA_MISS)
        assert(player.ammoRemoved == 1)
        assert(player:getLocalVar('ArrowsUsed') == player.ammoId * 10000 + 1)

        target.rejectStatus = false
        xi.job_utils.ranger.useShadowbind(player, target, ability, action)
        assert(ability.message == xi.msg.basic.IS_EFFECT)
        assert(target:hasStatusEffect(xi.effect.BIND))
    end)

    it('preserves Shadowbind Unlimited Shot behavior outside ranged WS', function()
        player.effects[xi.effect.UNLIMITED_SHOT] = makeEffect()

        xi.job_utils.ranger.useShadowbind(player, target, ability, action)
        assert(not player:hasStatusEffect(xi.effect.UNLIMITED_SHOT))
        assert(player.ammoRemoved == nil)
        assert(player:getLocalVar('ArrowsUsed') == 0)
    end)
end)
