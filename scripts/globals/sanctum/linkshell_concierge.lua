-----------------------------------
-- Shared Linkshell Concierge behaviour for city placements.
-----------------------------------
local libraryInstance = require('scripts/globals/library_instance')

local concierge = {}
local dialogueName = 'LS Concierge'

-- Custom-menu selections echo the title through a 128-byte tell packet.
-- Keep menu titles short and put the full Concierge dialogue in chat.
local function say(player, npc, message)
    player:printToPlayer(message, 0, dialogueName)
end

local function formatGil(amount)
    local formatted = tostring(amount)

    while true do
        local replacements
        formatted, replacements = formatted:gsub('^(%d+)(%d%d%d)', '%1,%2')
        if replacements == 0 then
            return formatted
        end
    end
end

local function showMenuAfterSelection(player, menu)
    -- Let the current custom menu close before installing its replacement.
    player:timer(100, function(playerArg)
        playerArg:customMenu(menu)
    end)
end

local function showRegistrationConfirmation(player, npc)
    local linkshellId = libraryInstance.getEquippedLinkshellID(player)
    if linkshellId == 0 then
        say(player, npc, 'You are not wearing a linkshell in slot 1. Equip one and speak with me again.')
        return
    end

    local linkshellName = player:getLinkshellName(1)
    if not linkshellName or linkshellName == '' then
        say(player, npc, 'I could not read that linkshell name. Re-equip it in slot 1 and try again.')
        return
    end

    say(player, npc, string.format('Linkshell slot 1: %s.', linkshellName))
    showMenuAfterSelection(player,
    {
        title = 'Register this linkshell?',
        options =
        {
            {
                'Yes',
                function(confirmingPlayer)
                    local registered, message = libraryInstance.register(confirmingPlayer, linkshellId)
                    if not registered then
                        say(confirmingPlayer, npc, message or 'Unable to register that linkshell.')
                        return
                    end

                    say(confirmingPlayer, npc, string.format(
                        'Registration complete. You are now registered with %s.',
                        libraryInstance.getRegisteredLinkshellName(confirmingPlayer)
                    ))
                end,
            },
            {
                'No',
                function(confirmingPlayer)
                    say(confirmingPlayer, npc, 'Come back if you change your mind.')
                end,
            },
        },
        onCancelled = function(confirmingPlayer)
            say(confirmingPlayer, npc, 'Come back if you change your mind.')
        end,
    })
end

local function showRegistrationMenu(player, npc)
    say(player, npc, "You aren't registered yet. Would you like to register?")
    player:customMenu(
    {
        title = 'Register a linkshell?',
        options =
        {
            {
                'Yes',
                function(registeringPlayer)
                    showRegistrationConfirmation(registeringPlayer, npc)
                end,
            },
            {
                'No',
                function(registeringPlayer)
                    say(registeringPlayer, npc, 'Come back if you change your mind.')
                end,
            },
        },
        onCancelled = function(registeringPlayer)
            say(registeringPlayer, npc, 'Come back if you change your mind.')
        end,
    })
end

local function showLinkshellAccessMenu(player, npc, linkshellId, linkshellName, oldOwnedId, oldOwnedName)
    say(player, npc, string.format(
        '%s is not registered for Library access. Register it for %s gil?',
        linkshellName,
        formatGil(libraryInstance.linkshellAccessCost)
    ))

    if oldOwnedId ~= 0 and oldOwnedId ~= linkshellId then
        say(player, npc, string.format(
            'Warning: %s will be de-registered if you continue.',
            oldOwnedName
        ))
        say(player, npc, 'Its members will lose access to that Library and any items stored inside it.')
    end

    player:customMenu(
    {
        title = oldOwnedId ~= 0 and oldOwnedId ~= linkshellId and
            'Replace your LS Library?' or
            'Register this linkshell?',
        options =
        {
            {
                'Yes',
                function(purchasingPlayer)
                    local result = libraryInstance.purchaseLinkshellAccess(purchasingPlayer, linkshellId)

                    if
                        result == libraryInstance.purchaseResult.SUCCESS or
                        result == libraryInstance.purchaseResult.ALREADY_UNLOCKED
                    then
                        if result == libraryInstance.purchaseResult.SUCCESS then
                            say(purchasingPlayer, npc, string.format(
                                '%s now has Library access. Its members may now register.',
                                linkshellName
                            ))
                        end

                        purchasingPlayer:timer(100, function(playerArg)
                            concierge.onTrigger(playerArg, npc)
                        end)
                    elseif result == libraryInstance.purchaseResult.NO_LINKSHELL then
                        say(purchasingPlayer, npc, 'The linkshell in slot 1 changed. Please speak with me again.')
                    elseif result == libraryInstance.purchaseResult.NOT_HOLDER then
                        say(purchasingPlayer, npc, 'Only the linkshell holder can purchase Library access.')
                    elseif result == libraryInstance.purchaseResult.INSUFFICIENT_GIL then
                        say(purchasingPlayer, npc, string.format(
                            'You need %s gil to register this linkshell.',
                            formatGil(libraryInstance.linkshellAccessCost)
                        ))
                    elseif result == libraryInstance.purchaseResult.COOLDOWN_ACTIVE then
                        local cooldownRemaining = libraryInstance.getRegistrationCooldownRemaining(purchasingPlayer)
                        say(purchasingPlayer, npc, string.format(
                            'You can register a new linkshell in %s.',
                            libraryInstance.formatRegistrationCooldown(cooldownRemaining)
                        ))
                    else
                        say(purchasingPlayer, npc, 'The Library registration could not be completed. Please try again.')
                    end
                end,
            },
            {
                'No',
                function(purchasingPlayer)
                    say(purchasingPlayer, npc, 'Come back if you change your mind.')
                end,
            },
        },
        onCancelled = function(purchasingPlayer)
            say(purchasingPlayer, npc, 'Come back if you change your mind.')
        end,
    })
end

local function showRegistrationChangeMenu(player, npc, linkshellId, linkshellName)
    say(player, npc, string.format(
        'You are wearing %s instead. Would you like to register it as your new linkshell?',
        linkshellName
    ))

    player:customMenu(
    {
        title = 'Change registration?',
        options =
        {
            {
                'Yes',
                function(changingPlayer)
                    local registered, message = libraryInstance.register(changingPlayer, linkshellId)
                    if not registered then
                        say(changingPlayer, npc, message or 'Unable to change your linkshell registration.')
                        return
                    end

                    say(changingPlayer, npc, string.format(
                        'Registration changed. You are now registered with %s.',
                        libraryInstance.getRegisteredLinkshellName(changingPlayer)
                    ))
                end,
            },
            {
                'No',
                function(changingPlayer)
                    say(changingPlayer, npc, 'Just let me know if you change your mind.')
                end,
            },
        },
        onCancelled = function(changingPlayer)
            say(changingPlayer, npc, 'Just let me know if you change your mind.')
        end,
    })
end

local function showEntryMenu(player, npc)
    local registeredId = libraryInstance.getRegisteredLinkshellID(player)
    local registeredName = libraryInstance.getRegisteredLinkshellName(player)
    local equippedId = libraryInstance.getEquippedLinkshellID(player)
    local cooldownRemaining = libraryInstance.getRegistrationCooldownRemaining(player)

    say(player, npc, string.format(
        'You are already registered with %s.',
        registeredName
    ))

    if equippedId == 0 then
        say(player, npc, 'Equip that linkshell in slot 1 to enter, or equip a new linkshell to change your registration.')
        return
    end

    if equippedId ~= registeredId then
        local equippedName = player:getLinkshellName(1)
        if not equippedName or equippedName == '' then
            say(player, npc, 'I could not read the linkshell in slot 1. Re-equip it and try again.')
            return
        end

        if cooldownRemaining > 0 then
            say(player, npc, string.format(
                'You can register %s in %s.',
                equippedName,
                libraryInstance.formatRegistrationCooldown(cooldownRemaining)
            ))
            return
        end

        showRegistrationChangeMenu(player, npc, equippedId, equippedName)
        return
    end

    player:customMenu(
    {
        title = 'Enter your linkshell Library?',
        options =
        {
            {
                'Yes',
                function(enteringPlayer)
                    libraryInstance.enterRegistered(enteringPlayer)
                end,
            },
            {
                'No',
                function(enteringPlayer)
                    say(enteringPlayer, npc, 'Just let me know if you change your mind.')
                end,
            },
        },
        onCancelled = function(enteringPlayer)
            say(enteringPlayer, npc, 'Just let me know if you change your mind.')
        end,
    })
end

concierge.onTrigger = function(player, npc)
    local refundedGil = libraryInstance.claimPendingRefund(player)
    if refundedGil > 0 then
        say(player, npc, string.format(
            '%s gil from a reversed Library registration has been returned to you.',
            formatGil(refundedGil)
        ))
    end

    local equippedId = libraryInstance.getEquippedLinkshellID(player)
    if equippedId ~= 0 and not libraryInstance.hasLinkshellAccess(player, equippedId) then
        local linkshellName = player:getLinkshellName(1)
        if not linkshellName or linkshellName == '' then
            say(player, npc, 'I could not read the linkshell in slot 1. Re-equip it and try again.')
            return
        end

        if libraryInstance.getEquippedLinkshellType(player) == libraryInstance.linkshellHolderType then
            local registeredId = libraryInstance.getRegisteredLinkshellID(player)
            if registeredId ~= 0 and registeredId ~= equippedId then
                local cooldownRemaining = libraryInstance.getRegistrationCooldownRemaining(player)
                if cooldownRemaining > 0 then
                    say(player, npc, string.format(
                        'You can register a new linkshell in %s.',
                        libraryInstance.formatRegistrationCooldown(cooldownRemaining)
                    ))
                    return
                end
            end

            local oldOwnedId = libraryInstance.getOwnedLinkshellLibraryID(player)
            local oldOwnedName = libraryInstance.getLinkshellNameByID(player, oldOwnedId) or 'Your previous linkshell'
            showLinkshellAccessMenu(player, npc, equippedId, linkshellName, oldOwnedId, oldOwnedName)
        else
            say(player, npc, string.format(
                '%s has not registered for Library access. Its linkshell holder must purchase access for %s gil.',
                linkshellName,
                formatGil(libraryInstance.linkshellAccessCost)
            ))
        end

        return
    end

    if libraryInstance.getRegisteredLinkshellID(player) == 0 then
        showRegistrationMenu(player, npc)
    else
        showEntryMenu(player, npc)
    end
end

return concierge
