-----------------------------------
-- Announce new abilities/traits on level up
-- Generated from abilities.sql and traits.sql
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('level_up_unlock_notice')

local unlocks =
{
    [xi.job.WAR] =
    {
        abilities =
        {
            [5] = { 'Provoke' },
            [15] = { 'Berserk' },
            [25] = { 'Defender', 'Retaliation' },
            [35] = { 'Warcry' },
            [45] = { 'Aggressor' },
        },

        traits =
        {
            [5] = { 'Resist Virus' },
            [10] = { 'Defense Bonus' },
            [25] = { 'Double Attack' },
            [30] = { 'Attack Bonus' },
            [35] = { 'Shield Mastery', 'Resist Virus II' },
            [55] = { 'Resist Virus III' },
            [60] = { 'Shield Mastery II' },
            [70] = { 'Resist Virus IV' },
            [75] = { 'Double Attack III', 'Shield Mastery III' },
        },
    },

    [xi.job.MNK] =
    {
        abilities =
        {
            [5] = { 'Boost' },
            [15] = { 'Iron Guard' },
            [25] = { 'Focus' },
            [35] = { 'Chakra' },
            [41] = { 'Chi Blast' },
            [45] = { 'Counterstance' },
            [65] = { 'Footwork' },
        },

        traits =
        {
            [1] = { 'Martial Arts' },
            [5] = { 'Subtle Blow' },
            [10] = { 'Counter' },
            [15] = { 'Max HP Boost' },
            [16] = { 'Martial Arts II' },
            [25] = { 'Max HP Boost II', 'Subtle Blow II' },
            [31] = { 'Martial Arts III' },
            [35] = { 'Max HP Boost III' },
            [40] = { 'Subtle Blow III' },
            [45] = { 'Max HP Boost IV' },
            [46] = { 'Martial Arts IV' },
            [50] = { 'Counter II' },
            [51] = { 'Kick Attacks' },
            [55] = { 'Max HP Boost V' },
            [60] = { 'Tactical Guard' },
            [61] = { 'Martial Arts V' },
            [65] = { 'Max HP Boost VI', 'Subtle Blow IV' },
            [71] = { 'Kick Attacks II' },
            [75] = { 'Martial Arts VI', 'Subtle Blow V', 'Tactical Guard II' },
        },
    },

    [xi.job.WHM] =
    {
        abilities =
        {
            [15] = { 'Divine Seal' },
            [40] = { 'Afflatus Solace', 'Afflatus Misery' },
            [65] = { 'Sacrosanctity' },
        },

        traits =
        {
            [10] = { 'Magic Def. Bonus' },
            [20] = { 'Clear Mind' },
            [21] = { 'Tranquil Heart' },
            [25] = { 'Auto Regen' },
            [30] = { 'Magic Def. Bonus II' },
            [35] = { 'Clear Mind II' },
            [50] = { 'Magic Def. Bonus III', 'Clear Mind III', 'Divine Veil', 'Divine Benison' },
            [60] = { 'Divine Benison II' },
            [65] = { 'Clear Mind IV' },
            [70] = { 'Magic Def. Bonus IV', 'Divine Benison III' },
            [75] = { 'Auto Regen II' },
        },
    },

    [xi.job.BLM] =
    {
        abilities =
        {
            [15] = { 'Elemental Seal' },
        },

        traits =
        {
            [10] = { 'Magic Atk. Bonus' },
            [15] = { 'Clear Mind' },
            [20] = { 'Conserve MP' },
            [30] = { 'Magic Atk. Bonus II', 'Clear Mind II' },
            [45] = { 'Clear Mind III', 'Mag. Burst Bonus' },
            [50] = { 'Magic Atk. Bonus III', 'Elemental Celerity' },
            [58] = { 'Mag. Burst Bonus II' },
            [60] = { 'Clear Mind IV', 'Elemental Celerity II' },
            [70] = { 'Magic Atk. Bonus IV', 'Elemental Celerity III' },
            [71] = { 'Mag. Burst Bonus III' },
            [75] = { 'Clear Mind V', 'Occult Acumen' },
        },
    },

    [xi.job.RDM] =
    {
        abilities =
        {
            [40] = { 'Convert' },
            [50] = { 'Composure' },
        },

        traits =
        {
            [10] = { 'Resist Petrify' },
            [12] = { 'Fencer' },
            [15] = { 'Fast Cast' },
            [20] = { 'Magic Atk. Bonus' },
            [25] = { 'Magic Def. Bonus' },
            [26] = { 'Tranquil Heart' },
            [30] = { 'Resist Petrify II' },
            [31] = { 'Clear Mind' },
            [35] = { 'Fast Cast II' },
            [37] = { 'Fencer II' },
            [40] = { 'Magic Atk. Bonus II' },
            [45] = { 'Magic Def. Bonus II' },
            [50] = { 'Resist Petrify III' },
            [53] = { 'Clear Mind II' },
            [55] = { 'Fast Cast III' },
            [65] = { 'Fencer III' },
            [70] = { 'Resist Petrify IV' },
            [75] = { 'Clear Mind III' },
        },
    },

    [xi.job.THF] =
    {
        abilities =
        {
            [5] = { 'Steal' },
            [15] = { 'Sneak Attack' },
            [25] = { 'Flee' },
            [30] = { 'Trick Attack' },
            [35] = { 'Mug' },
            [45] = { 'Hide' },
            [50] = { 'Bully' },
            [65] = { 'Accomplice', 'Collaborator' },
        },

        traits =
        {
            [5] = { 'Gilfinder' },
            [10] = { 'Evasion Bonus' },
            [15] = { 'Treasure Hunter' },
            [20] = { 'Resist Gravity' },
            [30] = { 'Evasion Bonus II' },
            [37] = { 'Resist Gravity II' },
            [40] = { 'Dual Wield' },
            [45] = { 'Treasure Hunter II II', 'Assassin' },
            [50] = { 'Evasion Bonus III' },
            [55] = { 'Triple Attack' },
            [66] = { 'Resist Gravity III' },
            [70] = { 'Evasion Bonus IV' },
            [75] = { 'Resist Gravity IV' },
        },
    },

    [xi.job.PLD] =
    {
        abilities =
        {
            [5] = { 'Holy Circle' },
            [15] = { 'Shield Bash', 'Majesty' },
            [30] = { 'Sentinel' },
            [35] = { 'Cover' },
            [45] = { 'Palisade' },
            [62] = { 'Rampart' },
        },

        traits =
        {
            [5] = { 'Undead Killer' },
            [10] = { 'Defense Bonus' },
            [20] = { 'Resist Sleep' },
            [25] = { 'Shield Mastery' },
            [30] = { 'Defense Bonus II' },
            [35] = { 'Auto Refresh' },
            [37] = { 'Resist Sleep II' },
            [50] = { 'Defense Bonus III', 'Shield Mastery II' },
            [60] = { 'Shield Mastery III', 'Resist Sleep III' },
            [70] = { 'Defense Bonus IV' },
            [75] = { 'Shield Mastery IV', 'Resist Sleep IV' },
        },
    },

    [xi.job.DRK] =
    {
        abilities =
        {
            [5] = { 'Arcane Circle' },
            [15] = { 'Last Resort' },
            [20] = { 'Weapon Bash' },
            [30] = { 'Souleater' },
            [55] = { 'Consume Mana' },
        },

        traits =
        {
            [10] = { 'Attack Bonus' },
            [15] = { 'Desperate Blows' },
            [20] = { 'Resist Paralyze' },
            [25] = { 'Arcana Killer' },
            [30] = { 'Attack Bonus II' },
            [40] = { 'Resist Paralyze II' },
            [45] = { 'Occult Acumen', 'Stalwart Soul' },
            [50] = { 'Attack Bonus III' },
            [58] = { 'Occult Acumen II' },
            [60] = { 'Resist Paralyze III', 'Stalwart Soul II' },
            [70] = { 'Attack Bonus IV' },
            [71] = { 'Occult Acumen III' },
            [75] = { 'Resist Paralyze IV', 'Stalwart Soul III' },
        },
    },

    [xi.job.BST] =
    {
        abilities =
        {
            [10] = { 'Gauge', 'Heel' },
            [12] = { 'Reward', 'Call Beast', 'Foot Kick' },
            [15] = { 'Stay', 'Big Scissors' },
            [19] = { 'Lamb Chop' },
            [23] = { 'Bestial Loyalty' },
            [25] = { 'Sic', 'Ready'},
            [30] = { 'Tame' },
            [35] = { 'Leave' },
            [45] = { 'Snarl' },
            [65] = { 'Feral Howl' },
        },

        traits =
        {
            [10] = { 'Vermin Killer' },
            [15] = { 'Resist Slow', 'Resist Amnesia' },
            [20] = { 'Bird Killer', 'Predator' },
            [30] = { 'Amorph Killer' },
            [35] = { 'Resist Slow II', 'Resist Amnesia II' },
            [40] = { 'Lizard Killer', 'Tandem Blow' },
            [50] = { 'Aquan Killer' },
            [55] = { 'Resist Slow III', 'Resist Amnesia III' },
            [60] = { 'Plantoid Killer', 'Tandem Blow II' },
            [70] = { 'Beast Killer' },
            [75] = { 'Resist Slow IV', 'Resist Amnesia IV', 'Tandem Blow III' },
        },
    },

    [xi.job.BRD] =
    {
        abilities =
        {
            [20] = { 'Pianissimo' },
        },

        traits =
        {
            [5] = { 'Resist Silence' },
            [25] = { 'Resist Silence II' },
            [45] = { 'Resist Silence III' },
            [65] = { 'Resist Silence IV' },
        },
    },

    [xi.job.RNG] =
    {
        abilities =
        {
            [10] = { 'Scavenge' },
            [20] = { 'Camouflage' },
            [30] = { 'Barrage' },
            [40] = { 'Shadowbind' },
            [45] = { 'Velocity Shot' },
            [51] = { 'Unlimited Shot' },
            [70] = { 'Double Shot' },
        },

        traits =
        {
            [5] = { 'Alertness' },
            [10] = { 'Accuracy Bonus' },
            [15] = { 'Rapid Shot' },
            [20] = { 'Resist Poison', 'Recycle' },
            [30] = { 'Accuracy Bonus II' },
            [35] = { 'Recycle II' },
            [37] = { 'Resist Poison II' },
            [50] = { 'Accuracy Bonus III', 'Recycle III' },
            [60] = { 'Resist Poison III' },
            [70] = { 'Accuracy Bonus IV' },
        },
    },

    [xi.job.SAM] =
    {
        abilities =
        {
            [5] = { 'Warding Circle' },
            [15] = { 'Third Eye' },
            [25] = { 'Hasso' },
            [30] = { 'Meditate' },
            [35] = { 'Seigan' },
            [40] = { 'Sekkanoki' },
            [65] = { 'Konzen-Ittai' },
        },

        traits =
        {
            [5] = { 'Resist Blind' },
            [10] = { 'Store TP' },
            [20] = { 'Zanshin' },
            [25] = { 'Resist Blind II' },
            [30] = { 'Store TP II' },
            [35] = { 'Zanshin II' },
            [40] = { 'Demon Killer' },
            [45] = { 'Resist Blind III' },
            [50] = { 'Store TP III', 'Zanshin III' },
            [65] = { 'Resist Blind IV' },
            [70] = { 'Store TP IV' },
            [75] = { 'Zanshin IV' },
        },
    },

    [xi.job.NIN] =
    {
        abilities =
        {
            [15] = { 'Yonin', 'Innin' },
        },

        traits =
        {
            [5] = { 'Stealth' },
            [10] = { 'Dual Wield', 'Resist Bind' },
            [15] = { 'Subtle Blow' },
            [25] = { 'Dual Wield II', 'Daken' },
            [30] = { 'Resist Bind II', 'Subtle Blow II' },
            [40] = { 'Daken II' },
            [45] = { 'Dual Wield III', 'Subtle Blow III' },
            [50] = { 'Resist Bind III' },
            [60] = { 'Subtle Blow IV' },
            [65] = { 'Dual Wield IV' },
            [70] = { 'Resist Bind IV' },
            [75] = { 'Subtle Blow V' },
        },
    },

    [xi.job.DRG] =
    {
        abilities =
        {
            [5] = { 'Ancient Circle' },
            [10] = { 'Jump' },
            [25] = { 'Spirit Link' },
            [30] = { 'Steady Wing' },
            [35] = { 'High Jump' },
            [50] = { 'Super Jump' },
        },

        traits =
        {
            [10] = { 'Attack Bonus' },
            [20] = { 'Strafe' },
            [25] = { 'Dragon Killer' },
            [30] = { 'Accuracy Bonus' },
            [45] = { 'Conserve TP' },
            [58] = { 'Conserve TP II' },
            [60] = { 'Accuracy Bonus II' },
            [71] = { 'Conserve TP III' },
        },
    },

    [xi.job.SMN] =
    {
        abilities =
        {
            [5] = { 'Poison Nails', 'Moonlit Charge' },
            [10] = { 'Crescent Fang', 'Fire II', 'Stone II', 'Water II', 'Aero II', 'Blizzard II', 'Thunder II' },
            [15] = { 'Raise II' },
            [19] = { 'Thunderspark' },
            [20] = { 'Somnolence' },
            [21] = { 'Lunar Cry', 'Rock Buster' },
            [23] = { 'Burning Strike' },
            [24] = { 'Shining Ruby' },
            [25] = { 'Mewing Lullaby', 'Aerial Armor', 'Roundhouse' },
            [26] = { 'Tail Whip' },
            [28] = { 'Frost Armor' },
            [29] = { 'Nightmare' },
            [30] = { 'Reraise II', 'Double Punch' },
            [31] = { 'Rolling Thunder' },
            [32] = { 'Lunar Roar' },
            [33] = { 'Slowga' },
            [35] = { 'Megalith Throw' },
            [36] = { 'Whispering Wind' },
            [37] = { 'Ultimate Terror' },
            [38] = { 'Crimson Howl' },
            [39] = { 'Sleepga' },
            [42] = { 'Lightning Armor' },
            [43] = { 'Ecliptic Growl' },
            [44] = { 'Glittering Ruby' },
            [46] = { 'Earthen Ward' },
            [47] = { 'Spring Water' },
            [48] = { 'Hastega' },
            [49] = { 'Noctoshield' },
            [50] = { 'Elemental Siphon', 'Double Slap' },
            [54] = { 'Ecliptic Howl' },
            [55] = { 'Avatars Favor', 'Meteorite', 'Eerie Eye' },
            [56] = { 'Dream Shroud' },
            [60] = { 'Fire IV', 'Stone IV', 'Water IV', 'Aero IV', 'Blizzard IV', 'Thunder IV' },
            [65] = { 'Healing Ruby II', 'Eclipse Bite', 'Nether Blast', 'Sonic Buffet' },
            [70] = { 'Flaming Crush', 'Mountain Buster', 'Spinning Dive', 'Predator Claws', 'Rush', 'Chaotic Strike' },
        },

        traits =
        {
            [10] = { 'Max MP Boost' },
            [15] = { 'Clear Mind' },
            [20] = { 'Resist Slow' },
            [25] = { 'Auto Refresh' },
            [30] = { 'Max MP Boost II', 'Clear Mind II' },
            [40] = { 'Resist Slow II' },
            [45] = { 'Clear Mind III' },
            [50] = { 'Max MP Boost III' },
            [60] = { 'Clear Mind IV', 'Resist Slow III', 'Blood Boon' },
            [70] = { 'Max MP Boost IV', 'Clear Mind V', 'Blood Boon II' },
        },
    },

    [xi.job.BLU] =
    {
        abilities =
        {
            [25] = { 'Burst Affinity' },
            [40] = { 'Chain Affinity' },
        },

        traits =
        {
        },
    },

    [xi.job.COR] =
    {
        abilities =
        {
            [5] = { 'Phantom Roll', 'Corsairs Roll', 'Double-Up' },
            [8] = { 'Ninja Roll' },
            [11] = { 'Hunters Roll' },
            [14] = { 'Chaos Roll' },
            [17] = { 'Maguss Roll' },
            [20] = { 'Healers Roll' },
            [23] = { 'Drachen Roll' },
            [26] = { 'Choral Roll' },
            [31] = { 'Monks Roll' },
            [34] = { 'Beast Roll', 'Samurai Roll' },
            [40] = { 'Evokers Roll', 'Quick Draw' },
            [43] = { 'Rogues Roll' },
            [46] = { 'Warlocks Roll' },
            [49] = { 'Fighters Roll' },
            [50] = { 'Random Deal' },
            [52] = { 'Puppet Roll' },
            [55] = { 'Gallants Roll' },
            [58] = { 'Wizards Roll' },
            [61] = { 'Dancers Roll' },
            [64] = { 'Scholars Roll' },
            [75] = { 'Bolters Roll' },
        },

        traits =
        {
            [5] = { 'Resist Paralyze' },
            [15] = { 'Rapid Shot' },
            [25] = { 'Resist Paralyze II' },
            [30] = { 'Resist Amnesia' },
            [35] = { 'Recycle' },
            [45] = { 'Resist Paralyze III' },
            [50] = { 'Resist Amnesia II' },
            [65] = { 'Resist Paralyze IV', 'Recycle II' },
            [70] = { 'Resist Amnesia III' },
        },
    },

    [xi.job.PUP] =
    {
        abilities =
        {
            [5] = { 'Deus Ex Automata' },
            [10] = { 'Retrieve' },
            [15] = { 'Repair' },
            [30] = { 'Maintenance' },
            [60] = { 'Heady Artifice' },
        },

        traits =
        {
            [10] = { 'Resist Slow' },
            [15] = { 'Resist Amnesia' },
            [20] = { 'Evasion Bonus' },
            [25] = { 'Martial Arts' },
            [35] = { 'Resist Amnesia II' },
            [40] = { 'Evasion Bonus II' },
            [45] = { 'Tandem Blow' },
            [50] = { 'Martial Arts II', 'Resist Slow II' },
            [55] = { 'Resist Amnesia III' },
            [60] = { 'Evasion Bonus III' },
            [65] = { 'Tandem Blow II' },
            [70] = { 'Resist Slow III' },
            [75] = { 'Martial Arts III', 'Resist Amnesia IV' },
        },
    },

    [xi.job.DNC] =
    {
        abilities =
        {
            [1] = { 'Steps', 'Quickstep' },
            [5] = { 'Sambas', 'Drain Samba' },
            [10] = { 'Flourishes I', 'Animated Flourish' },
            [15] = { 'Waltzes', 'Curing Waltz' },
            [25] = { 'Aspir Samba', 'Divine Waltz', 'Spectral Jig', 'Jigs' },
            [30] = { 'Curing Waltz II', 'Box Step', 'Desperate Flourish' },
            [35] = { 'Drain Samba II', 'Healing Waltz' },
            [40] = { 'Stutter Step', 'Reverse Flourish', 'Flourishes II' },
            [45] = { 'Haste Samba', 'Curing Waltz III', 'Violent Flourish' },
            [50] = { 'Building Flourish', 'Contradance' },
            [55] = { 'Chocobo Jig' },
            [60] = { 'Aspir Samba II', 'Wild Flourish' },
            [65] = { 'Drain Samba III' },
            [70] = { 'Curing Waltz IV' },
        },

        traits =
        {
            [15] = { 'Evasion Bonus', 'Subtle Blow' },
            [20] = { 'Dual Wield', 'Resist Slow' },
            [30] = { 'Accuracy Bonus' },
            [35] = { 'Subtle Blow II' },
            [40] = { 'Dual Wield II' },
            [45] = { 'Evasion Bonus II', 'Skillchain Bonus' },
            [50] = xi.module.isContentEnabled('ABYSSEA') and { 'Conserve TP' } or nil,
            [55] = { 'Resist Slow II', 'Subtle Blow III' },
            [58] = { 'Skillchain Bonus II' },
            [60] = { 'Accuracy Bonus II', 'Dual Wield III' },
            [70] = xi.module.isContentEnabled('ABYSSEA') and { 'Subtle Blow IV' } or nil,
            [71] = { 'Skillchain Bonus III' },
            [75] = { 'Evasion Bonus III' },
        },
    },

    [xi.job.SCH] =
    {
        abilities =
        {
            [10] = { 'Light Arts', 'Dark Arts', 'Penury', 'Parsimony', 'Stratagems', 'Addendum White' },
            [25] = { 'Celerity', 'Alacrity' },
            [30] = { 'Addendum Black' },
            [35] = { 'Sublimation' },
            [40] = { 'Accession', 'Manifestation' },
            [55] = { 'Rapture', 'Ebullience' },
            [65] = { 'Modus Veritas' },
        },

        traits =
        {
            [10] = { 'Resist Silence' },
            [20] = { 'Clear Mind' },
            [25] = { 'Conserve MP' },
            [30] = { 'Max MP Boost', 'Tranquil Heart' },
            [35] = { 'Clear Mind II' },
            [40] = { 'Resist Silence II' },
            [50] = { 'Clear Mind III' },
            [65] = { 'Clear Mind IV' },
            [70] = { 'Resist Silence III' },
        },
    },

    [xi.job.RUN] =
    {
        abilities =
        {
        },

        traits =
        {
        },
    },

       [xi.job.GEO] =
    {
        abilities =
        {
        },

        traits =
        {
        },
    },
}

local function showUnlocks(player, job, lvl)
    local jobUnlocks = unlocks[job]
    if jobUnlocks == nil then
        return
    end

    local abilities = jobUnlocks.abilities and jobUnlocks.abilities[lvl] or nil
    local traits    = jobUnlocks.traits and jobUnlocks.traits[lvl] or nil

    if abilities ~= nil then
        for _, name in ipairs(abilities) do
            player:printToPlayer(
                string.format(
                    'Learned job ability: [%s].',
                    name
                ),
                xi.msg.channel.SYSTEM_3
            )
        end
    end

    if traits ~= nil then
        for _, name in ipairs(traits) do
            player:printToPlayer(
                string.format(
                    'Learned job trait: [%s].',
                    name
                ),
                xi.msg.channel.SYSTEM_3
            )
        end
    end
end

m:addOverride('xi.player.onPlayerLevelUp', function(player, ...)
    super(player, ...)

    local job = player:getMainJob()
    local lvl = player:getMainLvl()

    player:timer(1500, function(playerArg)
        if playerArg ~= nil then
            showUnlocks(playerArg, job, lvl)
        end
    end)
end)

return m
