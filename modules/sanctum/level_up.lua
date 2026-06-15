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
            [75] = { 'Warriors Charge', 'Tomahawk' },
            [77] = { 'Restraint' },
            [87] = { 'Blood Rage' },
            [96] = { 'Brazen Rush' },
        },

        traits =
        {
            [5] = { 'Resist Virus' },
            [10] = { 'Defense Bonus' },
            [25] = { 'Double Attack' },
            [30] = { 'Attack Bonus', 'Max HP Boost' },
            [35] = { 'Shield Mastery', 'Resist Virus II', 'Smite' },
            [40] = { 'Damage Limit+' },
            [45] = { 'Defense Bonus II', 'Fencer' },
            [50] = { 'Max HP Boost II', 'Double Attack II' },
            [55] = { 'Resist Virus III' },
            [58] = { 'Fencer II' },
            [60] = { 'Shield Mastery II' },
            [65] = { 'Attack Bonus II', 'Smite II' },
            [70] = { 'Max HP Boost III', 'Resist Virus IV' },
            [71] = { 'Fencer III' },
            [75] = { 'Double Attack III', 'Shield Mastery III', 'Savagery', 'Aggressive Aim' },
            [78] = { 'Crit. Atk. Bonus' },
            [80] = { 'Shield Def. Bonus', 'Damage Limit+ II' },
            [81] = { 'Resist Virus V' },
            [84] = { 'Fencer IV' },
            [85] = { 'Double Attack IV' },
            [86] = { 'Defense Bonus III', 'Crit. Atk. Bonus II' },
            [88] = { 'Shield Def. Bonus II' },
            [90] = { 'Attack Bonus III', 'Max HP Boost IV' },
            [95] = { 'Smite III' },
            [97] = { 'Fencer V' },
            [99] = { 'Double Attack V', 'Shield Def. Bonus III' },
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
            [75] = { 'Mantra', 'Formless Strikes' },
            [76] = { 'Perfect Counter' },
            [88] = { 'Impetus' },
            [96] = { 'Inner Strength' },
        },

        traits =
        {
            [1] = { 'Martial Arts' },
            [5] = { 'Subtle Blow' },
            [10] = { 'Counter' },
            [15] = { 'Max HP Boost' },
            [16] = { 'Martial Arts II' },
            [25] = { 'Max HP Boost II', 'Subtle Blow II' },
            [30] = { 'Damage Limit+' },
            [31] = { 'Martial Arts III' },
            [35] = { 'Max HP Boost III' },
            [40] = { 'Subtle Blow III', 'Smite' },
            [45] = { 'Max HP Boost IV' },
            [46] = { 'Martial Arts IV' },
            [50] = { 'Counter II' },
            [51] = { 'Kick Attacks' },
            [55] = { 'Max HP Boost V' },
            [60] = { 'Tactical Guard', 'Damage Limit+ II' },
            [61] = { 'Martial Arts V' },
            [65] = { 'Max HP Boost VI', 'Subtle Blow IV' },
            [71] = { 'Kick Attacks II' },
            [75] = { 'Martial Arts VI', 'Subtle Blow V', 'Invigorate', 'Penance', 'Tactical Guard II', 'Max HP Boost II' },
            [76] = { 'Kick Attacks III' },
            [80] = { 'Smite II' },
            [82] = { 'Martial Arts VII' },
            [85] = { 'Skillchain Bonus', 'Max HP Boost II' },
            [90] = { 'Damage Limit+ III' },
            [95] = { 'Skillchain Bonus II', 'Max HP Boost II' },
            [97] = { 'Tactical Guard III' },
        },
    },

    [xi.job.WHM] =
    {
        abilities =
        {
            [15] = { 'Divine Seal' },
            [40] = { 'Afflatus Solace', 'Afflatus Misery' },
            [65] = { 'Sacrosanctity' },
            [75] = { 'Martyr', 'Devotion' },
            [83] = { 'Divine Caress' },
            [96] = { 'Asylum' },
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
            [80] = { 'Clear Mind V', 'Divine Benison IV' },
            [81] = { 'Magic Def. Bonus V' },
            [85] = { 'Shield Def. Bonus' },
            [90] = { 'Divine Benison V' },
            [91] = { 'Magic Def. Bonus VI' },
            [95] = { 'Shield Def. Bonus II' },
            [96] = { 'Clear Mind VI' },
        },
    },

    [xi.job.BLM] =
    {
        abilities =
        {
            [15] = { 'Elemental Seal' },
            [76] = { 'Mana Wall' },
            [85] = { 'Cascade' },
            [87] = { 'Enmity Douse' },
            [95] = { 'Manawell' },
            [96] = { 'Subtle Sorcery' },
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
            [76] = { 'Conserve MP II' },
            [80] = { 'Elemental Celerity IV' },
            [81] = { 'Magic Atk. Bonus V' },
            [84] = { 'Mag. Burst Bonus IV' },
            [86] = { 'Conserve MP III' },
            [90] = { 'Elemental Celerity V' },
            [91] = { 'Magic Atk. Bonus VI' },
            [95] = { 'Occult Acumen II' },
            [96] = { 'Clear Mind VI' },
            [97] = { 'Mag. Burst Bonus V' },
        },
    },

    [xi.job.RDM] =
    {
        abilities =
        {
            [40] = { 'Convert' },
            [50] = { 'Composure' },
            [83] = { 'Saboteur' },
            [95] = { 'Spontaneity' },
            [96] = { 'Stymie' },
        },

        traits =
        {
            [10] = { 'Resist Petrify' },
            [15] = { 'Fast Cast' },
            [20] = { 'Magic Atk. Bonus' },
            [25] = { 'Magic Def. Bonus' },
            [26] = { 'Tranquil Heart' },
            [30] = { 'Resist Petrify II' },
            [31] = { 'Clear Mind' },
            [35] = { 'Fast Cast II' },
            [40] = { 'Magic Atk. Bonus II' },
            [45] = { 'Magic Def. Bonus II' },
            [50] = { 'Resist Petrify III' },
            [53] = { 'Clear Mind II' },
            [55] = { 'Fast Cast III' },
            [60] = { 'Damage Limit+' },
            [70] = { 'Resist Petrify IV' },
            [75] = { 'Clear Mind III' },
            [76] = { 'Fast Cast IV' },
            [81] = { 'Resist Petrify V' },
            [85] = { 'Mag. Burst Bonus' },
            [86] = { 'Magic Atk. Bonus III' },
            [87] = { 'Shield Mastery' },
            [89] = { 'Fast Cast V' },
            [91] = { 'Clear Mind IV' },
            [95] = { 'Mag. Burst Bonus II' },
            [96] = { 'Magic Def. Bonus III' },
            [97] = { 'Shield Mastery II' },
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
            [75] = { 'Assassins Charge', 'Feint' },
            [77] = { 'Despoil' },
            [87] = { 'Conspirator' },
            [96] = { 'Larceny' },
        },

        traits =
        {
            [5] = { 'Gilfinder' },
            [10] = { 'Evasion Bonus' },
            [15] = { 'Treasure Hunter' },
            [20] = { 'Resist Gravity' },
            [30] = { 'Evasion Bonus II' },
            [40] = { 'Dual Wield', 'Resist Gravity II' },
            [45] = { 'Treasure Hunter II', 'Assassin' },
            [50] = { 'Evasion Bonus III', 'Damage Limit+' },
            [55] = { 'Triple Attack' },
            [66] = { 'Resist Gravity III' },
            [70] = { 'Evasion Bonus IV' },
            [75] = { 'Resist Gravity IV', 'Aura Steal', 'Ambush' },
            [76] = { 'Evasion Bonus V', 'Dual Wield II' },
            [78] = { 'Crit. Atk. Bonus' },
            [81] = { 'Resist Gravity V' },
            [84] = { 'Crit. Atk. Bonus II' },
            [88] = { 'Evasion Bonus VI' },
            [90] = { 'Gilfinder II', 'Treasure Hunter III' },
            [91] = { 'Crit. Atk. Bonus III' },
            [95] = { 'Triple Attack II' },
            [97] = { 'Crit. Atk. Bonus IV' },
            [98] = { 'Dual Wield III' },
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
            [75] = { 'Fealty', 'Chivalry' },
            [78] = { 'Divine Emblem' },
            [87] = { 'Sepulcher' },
            [96] = { 'Intervene' },
        },

        traits =
        {
            [5] = { 'Undead Killer' },
            [10] = { 'Defense Bonus' },
            [20] = { 'Resist Sleep' },
            [25] = { 'Shield Mastery' },
            [30] = { 'Defense Bonus II' },
            [35] = { 'Auto Refresh' },
            [40] = { 'Resist Sleep II' },
            [45] = { 'Max HP Boost' },
            [50] = { 'Defense Bonus III', 'Shield Mastery II' },
            [60] = { 'Shield Mastery III', 'Resist Sleep III' },
            [70] = { 'Defense Bonus IV', 'Shield Barrier' },
            [75] = { 'Shield Mastery IV', 'Resist Sleep IV', 'Iron Will', 'Guardian', 'Challenge' },
            [76] = { 'Defense Bonus V' },
            [77] = { 'Shield Def. Bonus' },
            [79] = { 'Crit. Def. Bonus' },
            [81] = { 'Resist Sleep V' },
            [82] = { 'Shield Def. Bonus II' },
            [85] = { 'Max HP Boost II', 'Crit. Def. Bonus II' },
            [86] = { 'Undead Killer II' },
            [88] = { 'Shield Def. Bonus III' },
            [91] = { 'Defense Bonus VI', 'Crit. Def. Bonus III' },
            [93] = { 'Shield Def. Bonus IV' },
            [96] = { 'Crit. Def. Bonus IV' },
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
            [75] = { 'Dark Seal', 'Diabolic Eye', 'Nether Void' },
            [87] = { 'Arcane Crest' },
            [95] = { 'Scarlet Delirium' },
            [96] = { 'Soul Enslavement' },
        },

        traits =
        {
            [10] = { 'Attack Bonus' },
            [15] = { 'Desperate Blows', 'Smite' },
            [20] = { 'Resist Paralyze', 'Damage Limit+' },
            [25] = { 'Arcana Killer' },
            [30] = { 'Attack Bonus II', 'Desperate Blows II' },
            [35] = { 'Smite II' },
            [40] = { 'Resist Paralyze II', 'Damage Limit+ II' },
            [45] = { 'Desperate Blows III', 'Occult Acumen', 'Stalwart Soul' },
            [50] = { 'Attack Bonus III' },
            [55] = { 'Smite III', 'Damage Limit+ III' },
            [58] = { 'Occult Acumen II' },
            [60] = { 'Resist Paralyze III', 'Stalwart Soul II' },
            [70] = { 'Attack Bonus IV', 'Damage Limit+ IV' },
            [71] = { 'Occult Acumen III' },
            [75] = { 'Resist Paralyze IV', 'Blood Discipline', 'Stalwart Soul III', 'Smite IV' },
            [76] = { 'Attack Bonus V' },
            [80] = { 'Damage Limit+ V' },
            [81] = { 'Resist Paralyze V' },
            [83] = { 'Attack Bonus VI' },
            [84] = { 'Occult Acumen IV' },
            [85] = { 'Crit. Atk. Bonus' },
            [86] = { 'Arcana Killer II' },
            [88] = { 'Tactical Parry' },
            [90] = { 'Stalwart Soul IV' },
            [91] = { 'Attack Bonus VII' },
            [95] = { 'Crit. Atk. Bonus II', 'Smite V' },
            [97] = { 'Occult Acumen V' },
            [98] = { 'Tactical Parry II' },
            [99] = { 'Attack Bonus VIII' },
        },
    },

    [xi.job.BST] =
    {
        abilities =
        {
            [1] = { 'Charm', 'Pet Commands', 'Fight' },
            [10] = { 'Gauge', 'Heel' },
            [12] = { 'Reward', 'Call Beast', 'Foot Kick' },
            [15] = { 'Stay', 'Big Scissors' },
            [19] = { 'Lamb Chop' },
            [23] = { 'Bestial Loyalty' },
            [25] = { 'Sic', 'Ready', 'Dust Cloud', 'Whirl Claws', 'Head Butt', 'Dream Flower', 'Wild Oats', 'Leaf Dagger', 'Scream', 'Roar', 'Razor Fang', 'Claw Cyclone', 'Tail Blow', 'Fireball', 'Blockhead', 'Brain Crush', 'Infrasonics', 'Secretion', 'Rage', 'Sheep Charge', 'Sheep Song', 'Bubble Shower', 'Bubble Curtain', 'Scissor Guard', 'Metallic Body', 'Needleshot', 'Random Needles', 'Frogkick', 'Spore', 'Queasyshroom', 'Numbshroom', 'Shakeshroom', 'Silence Gas', 'Dark Spore', 'Power Attack', 'Hi-freq Field', 'Rhino Attack', 'Rhino Guard', 'Spoil', 'Cursed Sphere', 'Venom', 'Sandblast', 'Sandpit', 'Venom Spray', 'Mandibular Bite', 'Soporific', 'Gloeosuccus', 'Palsy Pollen', 'Geist Wall', 'Numbing Noise', 'Nimble Snap', 'Cyclotail', 'Toxic Spit', 'Double Claw', 'Grapple', 'Spinning Top', 'Filamented Hold', 'Chaotic Eye', 'Blaster', 'Suction', 'Drainkiss', 'Snow Cloud', 'Wild Carrot', 'Sudden Lunge', 'Spiral Spin', 'Noisome Powder', 'Chomp Rush', 'Purulent Ooze', 'Corrosive Ooze', 'Back Heel', 'Jettatura', 'Choke Breath', 'Fantod', 'Tortoise Stomp', 'Harden Shell', 'Aqua Breath', 'Wing Slap', 'Beak Lunge', 'Intimidate', 'Recoil Dive', 'Water Wall', 'Sensilla Blades', 'Tegmina Buffet', 'Molting Plumage', 'Swooping Frenzy', 'Sweeping Gouge', 'Zealous Snort', 'Pentapeck', 'Tickling Tendrils', 'Stink Bomb', 'Nectarous Deluge', 'Nepenthic Plunge', 'Somersault', 'Foul Waters', 'Pestilent Plume', 'Pecking Flurry', 'Sickle Slash', 'Acid Spray', 'Spider Web', 'Infected Leech', 'Gloom Spray', 'Disembowel', 'Extirpating Salvo', 'Venom Shower', 'Mega Scissors', 'Frenzied Rage', 'Rhinowrecker', 'Fluid Toss', 'Fluid Spread', 'Digest', 'Crossthrash', 'Predatory Glare', 'Hoof Volley', 'Nihility Song' },
            [26] = { 'Scythe Tail', 'Ripper Fang', 'Charged Whisker' },
            [30] = { 'Tame' },
            [35] = { 'Leave' },
            [45] = { 'Snarl' },
            [65] = { 'Feral Howl' },
            [75] = { 'Killer Instinct', 'Run Wild' },
            [83] = { 'Spur' },
            [96] = { 'Unleash' },
        },

        traits =
        {
            [10] = { 'Vermin Killer' },
            [15] = { 'Resist Slow', 'Resist Amnesia' },
            [20] = { 'Bird Killer' },
            [30] = { 'Amorph Killer', 'Tandem Strike' },
            [35] = { 'Resist Slow II', 'Resist Amnesia II' },
            [40] = { 'Lizard Killer', 'Tandem Blow' },
            [45] = { 'Damage Limit+', 'Tandem Strike II' },
            [50] = { 'Aquan Killer' },
            [55] = { 'Resist Slow III', 'Resist Amnesia III' },
            [60] = { 'Plantoid Killer', 'Tandem Strike III', 'Tandem Blow II' },
            [70] = { 'Beast Killer' },
            [75] = { 'Resist Slow IV', 'Resist Amnesia IV', 'Beast Affinity', 'Beast Healer', 'Tandem Strike IV', 'Tandem Blow III' },
            [76] = { 'Vermin Killer II' },
            [78] = { 'Stout Servant' },
            [79] = { 'Bird Killer II' },
            [80] = { 'Fencer' },
            [81] = { 'Resist Slow V' },
            [82] = { 'Amorph Killer II' },
            [85] = { 'Lizard Killer II' },
            [87] = { 'Fencer II' },
            [88] = { 'Aquan Killer II', 'Stout Servant II' },
            [90] = { 'Damage Limit+ II', 'Tandem Strike V' },
            [91] = { 'Plantoid Killer II' },
            [94] = { 'Beast Killer II', 'Fencer III' },
            [95] = { 'Resist Amnesia V' },
            [98] = { 'Stout Servant III' },
        },
    },

    [xi.job.BRD] =
    {
        abilities =
        {
            [20] = { 'Pianissimo' },
            [25] = { 'Acid Mist', 'TP Drainkiss' },
            [75] = { 'Nightingale', 'Troubadour', 'Marcato' },
            [83] = { 'Tenuto' },
            [96] = { 'Clarion Call' },
        },

        traits =
        {
            [5] = { 'Resist Silence' },
            [25] = { 'Resist Silence II' },
            [45] = { 'Resist Silence III' },
            [65] = { 'Resist Silence IV' },
            [75] = { 'Eloquence' },
            [80] = { 'Crit. Def. Bonus' },
            [81] = { 'Resist Silence V' },
            [85] = { 'Fencer' },
            [91] = { 'Crit. Def. Bonus II' },
            [95] = { 'Fencer II' },
        },
    },

    [xi.job.RNG] =
    {
        abilities =
        {
            [1] = { 'Sharpshot' },
            [10] = { 'Scavenge' },
            [20] = { 'Camouflage' },
            [30] = { 'Barrage' },
            [40] = { 'Shadowbind' },
            [45] = { 'Velocity Shot' },
            [51] = { 'Unlimited Shot' },
            [70] = { 'Double Shot' },
            [75] = { 'Stealth Shot', 'Flashy Shot' },
            [87] = { 'Bounty Shot' },
            [95] = { 'Decoy Shot' },
            [96] = { 'Overkill' },
        },

        traits =
        {
            [5] = { 'Alertness' },
            [10] = { 'Accuracy Bonus' },
            [15] = { 'Rapid Shot' },
            [20] = { 'Resist Poison', 'Recycle' },
            [30] = { 'Accuracy Bonus II', 'Damage Limit+' },
            [35] = { 'Recycle II' },
            [40] = { 'Resist Poison II' },
            [50] = { 'Accuracy Bonus III', 'Recycle III', 'Dead Aim' },
            [60] = { 'Resist Poison III', 'Dead Aim II', 'Damage Limit+ II' },
            [70] = { 'Accuracy Bonus IV', 'Dead Aim III' },
            [71] = { 'Rapid Shot II' },
            [75] = { 'Snapshot', 'Vision' },
            [80] = { 'Conserve TP', 'Dead Aim IV' },
            [81] = { 'Resist Poison IV' },
            [86] = { 'Accuracy Bonus V' },
            [90] = { 'Dead Aim V', 'Damage Limit+ III' },
            [91] = { 'Conserve TP II' },
            [96] = { 'Accuracy Bonus VI' },
            [99] = { 'Dead Aim VI' },
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
            [65] = { 'Konzen-ittai' },
            [75] = { 'Shikikoyo', 'Blade Bash' },
            [77] = { 'Sengikori' },
            [87] = { 'Hamanoha' },
            [95] = { 'Hagakure' },
            [96] = { 'Yaegasumi' },
        },

        traits =
        {
            [5] = { 'Resist Blind' },
            [10] = { 'Store TP' },
            [20] = { 'Zanshin' },
            [25] = { 'Resist Blind II' },
            [30] = { 'Store TP II' },
            [35] = { 'Zanshin II' },
            [40] = { 'Demon Killer', 'Damage Limit+' },
            [45] = { 'Resist Blind III' },
            [50] = { 'Store TP III', 'Zanshin III' },
            [65] = { 'Resist Blind IV' },
            [70] = { 'Store TP IV' },
            [75] = { 'Zanshin IV', 'Ikishoten', 'Overwhelm' },
            [78] = { 'Skillchain Bonus' },
            [80] = { 'Damage Limit+ II' },
            [81] = { 'Resist Blind V' },
            [86] = { 'Demon Killer II' },
            [88] = { 'Skillchain Bonus II' },
            [90] = { 'Store TP V' },
            [95] = { 'Zanshin V' },
            [98] = { 'Skillchain Bonus III' },
        },
    },

    [xi.job.NIN] =
    {
        abilities =
        {
            [15] = { 'Yonin', 'Innin' },
            [75] = { 'Sange' },
            [77] = { 'Futae' },
            [95] = { 'Issekigan' },
            [96] = { 'Mikage' },
        },

        traits =
        {
            [5] = { 'Stealth' },
            [10] = { 'Dual Wield', 'Resist Bind' },
            [15] = { 'Subtle Blow' },
            [20] = { 'Max HP Boost' },
            [25] = { 'Dual Wield II', 'Daken' },
            [30] = { 'Resist Bind II', 'Subtle Blow II' },
            [40] = { 'Max HP Boost II', 'Daken II' },
            [45] = { 'Dual Wield III', 'Subtle Blow III' },
            [50] = { 'Resist Bind III', 'Damage Limit+' },
            [55] = { 'Daken III' },
            [60] = { 'Max HP Boost III', 'Subtle Blow IV' },
            [65] = { 'Dual Wield IV' },
            [70] = { 'Resist Bind IV', 'Daken IV' },
            [75] = { 'Subtle Blow V', 'Ninja Tool Expert.' },
            [77] = { 'Tactical Parry' },
            [80] = { 'Max HP Boost IV', 'Mag. Burst Bonus' },
            [85] = { 'Dual Wield V', 'Skillchain Bonus' },
            [87] = { 'Tactical Parry II' },
            [90] = { 'Resist Bind V', 'Mag. Burst Bonus II' },
            [91] = { 'Subtle Blow VI' },
            [95] = { 'Skillchain Bonus II', 'Daken V' },
            [97] = { 'Tactical Parry III' },
            [99] = { 'Max HP Boost V' },
        },
    },

    [xi.job.DRG] =
    {
        abilities =
        {
            [1] = { 'Call Wyvern', 'Dismiss' },
            [5] = { 'Ancient Circle' },
            [10] = { 'Jump' },
            [25] = { 'Spirit Link' },
            [30] = { 'Steady Wing' },
            [35] = { 'High Jump' },
            [50] = { 'Super Jump' },
            [65] = { 'Spirit Bond' },
            [75] = { 'Deep Breathing', 'Angon' },
            [77] = { 'Spirit Jump' },
            [85] = { 'Soul Jump' },
            [87] = { 'Dragon Breaker' },
            [90] = { 'Smiting Breath', 'Restoring Breath' },
            [96] = { 'Fly High' },
        },

        traits =
        {
            [10] = { 'Attack Bonus' },
            [20] = { 'Strafe' },
            [25] = { 'Dragon Killer' },
            [30] = { 'Accuracy Bonus', 'Damage Limit+' },
            [40] = { 'Strafe II', 'Smite' },
            [45] = { 'Conserve TP', 'Ws Damage Boost' },
            [55] = { 'Ws Damage Boost II' },
            [58] = { 'Conserve TP II' },
            [60] = { 'Accuracy Bonus II', 'Strafe III', 'Damage Limit+ II' },
            [65] = { 'Ws Damage Boost III' },
            [71] = { 'Conserve TP III' },
            [75] = { 'Empathy', 'Ws Damage Boost IV' },
            [76] = { 'Accuracy Bonus III' },
            [80] = { 'Strafe IV', 'Smite II' },
            [84] = { 'Conserve TP IV' },
            [85] = { 'Crit. Def. Bonus', 'Ws Damage Boost V' },
            [86] = { 'Dragon Killer II' },
            [90] = { 'Damage Limit+ III' },
            [91] = { 'Attack Bonus II' },
            [95] = { 'Crit. Def. Bonus II', 'Ws Damage Boost VI' },
            [97] = { 'Conserve TP V' },
        },
    },

    [xi.job.SMN] =
    {
        abilities =
        {
            [1] = { 'Assault', 'Retreat', 'Release', 'Blood Pact Rage', 'Blood Pact Ward', 'Healing Ruby', 'Searing Light', 'Regal Scratch', 'Altana S Favor', 'Howling Moon', 'Punch', 'Inferno', 'Rock Throw', 'Earthen Fury', 'Barracuda Dive', 'Tidal Wave', 'Claw', 'Aerial Blast', 'Axe Kick', 'Diamond Dust', 'Shock Strike', 'Judgment Bolt', 'Camisado', 'Ruinous Omen', 'Clarsach Call', 'Welt' },
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
            [70] = { 'Apogee', 'Flaming Crush', 'Mountain Buster', 'Spinning Dive', 'Predator Claws', 'Rush', 'Chaotic Strike' },
            [75] = { 'Level X Holy', 'Meteor Strike', 'Geocrush', 'Grand Fall', 'Wind Blade', 'Heavenly Strike', 'Thunderstorm', 'Deconstruction', 'Chronoshift', 'Perfect Defense', 'Tornado II' },
            [76] = { 'Holy Mist' },
            [78] = { 'Lunar Bay' },
            [80] = { 'Night Terror' },
            [82] = { 'Earthen Armor' },
            [84] = { 'Tidal Roar' },
            [86] = { 'Fleet Wind' },
            [87] = { 'Mana Cede' },
            [88] = { 'Inferno Howl' },
            [90] = { 'Diamond Storm' },
            [92] = { 'Shock Squall' },
            [94] = { 'Soothing Ruby' },
            [96] = { 'Astral Conduit', 'Heavenward Howl' },
            [98] = { 'Pavor Nocturnus' },
            [99] = { 'Impact', 'Conflag Strike', 'Crag Throw', 'Soothing Current', 'Hastega II', 'Crystal Blessing', 'Volt Strike', 'Blindside', 'Pacifying Ruby', 'Hysteric Assault' },
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
            [76] = { 'Max MP Boost V' },
            [80] = { 'Blood Boon III' },
            [81] = { 'Resist Slow IV' },
            [85] = { 'Stout Servant' },
            [90] = { 'Auto Refresh II', 'Blood Boon IV' },
            [91] = { 'Clear Mind VI' },
            [95] = { 'Stout Servant II' },
            [96] = { 'Max MP Boost VI' },
        },
    },

    [xi.job.BLU] =
    {
        abilities =
        {
            [25] = { 'Burst Affinity' },
            [40] = { 'Chain Affinity' },
            [75] = { 'Convergence', 'Diffusion' },
            [83] = { 'Efflux' },
            [95] = { 'Unbridled Learning' },
            [96] = { 'Unbridled Wisdom' },
        },

        traits =
        {
            [75] = { 'Enchainment', 'Assimilation' },
        },
    },

    [xi.job.COR] =
    {
        abilities =
        {
            [5] = { 'Phantom Roll', 'Corsairs Roll', 'Double-up' },
            [8] = { 'Ninja Roll' },
            [11] = { 'Hunters Roll' },
            [14] = { 'Chaos Roll' },
            [17] = { 'Maguss Roll' },
            [20] = { 'Healers Roll' },
            [23] = { 'Drachen Roll' },
            [26] = { 'Choral Roll' },
            [31] = { 'Monks Roll' },
            [34] = { 'Beast Roll', 'Samurai Roll' },
            [40] = { 'Evokers Roll', 'Quick Draw', 'Fire Shot', 'Ice Shot', 'Wind Shot', 'Earth Shot', 'Thunder Shot', 'Water Shot', 'Light Shot', 'Dark Shot' },
            [43] = { 'Rogues Roll' },
            [46] = { 'Warlocks Roll' },
            [49] = { 'Fighters Roll' },
            [50] = { 'Random Deal' },
            [52] = { 'Puppet Roll' },
            [55] = { 'Gallants Roll' },
            [58] = { 'Wizards Roll' },
            [61] = { 'Dancers Roll' },
            [64] = { 'Scholars Roll' },
            [67] = { 'Naturalists Roll' },
            [70] = { 'Runeists Roll' },
            [75] = { 'Bolters Roll', 'Snake Eye', 'Fold' },
            [79] = { 'Casters Roll' },
            [81] = { 'Coursers Roll' },
            [83] = { 'Blitzers Roll' },
            [86] = { 'Tacticians Roll' },
            [87] = { 'Triple Shot' },
            [89] = { 'Allies Roll' },
            [92] = { 'Misers Roll' },
            [95] = { 'Companions Roll', 'Crooked Cards' },
            [96] = { 'Cutting Cards' },
            [97] = { 'Avengers Roll' },
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
            [75] = { 'Winning Streak', 'Loaded Deck' },
            [81] = { 'Resist Paralyze V' },
            [90] = { 'Resist Amnesia IV' },
            [91] = { 'Rapid Shot II' },
            [95] = { 'Recycle III' },
        },
    },

    [xi.job.PUP] =
    {
        abilities =
        {
            [1] = { 'Activate', 'Deploy', 'Deactivate', 'Fire Maneuver', 'Ice Maneuver', 'Wind Maneuver', 'Earth Maneuver', 'Thunder Maneuver', 'Water Maneuver', 'Light Maneuver', 'Dark Maneuver' },
            [5] = { 'Deus Ex Automata' },
            [10] = { 'Retrieve' },
            [15] = { 'Repair' },
            [30] = { 'Maintenance' },
            [75] = { 'Role Reversal', 'Ventriloquy' },
            [79] = { 'Tactical Switch' },
            [95] = { 'Cooldown' },
            [96] = { 'Heady Artifice' },
        },

        traits =
        {
            [10] = { 'Resist Slow' },
            [15] = { 'Resist Amnesia' },
            [20] = { 'Evasion Bonus' },
            [25] = { 'Martial Arts' },
            [35] = { 'Resist Amnesia II' },
            [40] = { 'Evasion Bonus II' },
            [45] = { 'Damage Limit+' },
            [50] = { 'Martial Arts II', 'Resist Slow II' },
            [55] = { 'Resist Amnesia III' },
            [60] = { 'Evasion Bonus III', 'Smite' },
            [70] = { 'Resist Slow III' },
            [75] = { 'Martial Arts III', 'Resist Amnesia IV', 'Fine-tuning', 'Optimization' },
            [76] = { 'Evasion Bonus IV' },
            [78] = { 'Stout Servant' },
            [80] = { 'Tactical Guard' },
            [81] = { 'Resist Slow IV' },
            [85] = { 'Crit. Def. Bonus' },
            [87] = { 'Martial Arts IV' },
            [88] = { 'Stout Servant II' },
            [90] = { 'Tactical Guard II', 'Damage Limit+ II' },
            [95] = { 'Resist Amnesia V', 'Crit. Def. Bonus II' },
            [97] = { 'Martial Arts V' },
            [98] = { 'Stout Servant III' },
        },
    },

    [xi.job.DNC] =
    {
        abilities =
        {
            [5] = { 'Sambas', 'Drain Samba' },
            [15] = { 'Waltzes', 'Curing Waltz' },
            [20] = { 'Steps', 'Flourishes I', 'Quickstep', 'Animated Flourish' },
            [25] = { 'Aspir Samba', 'Divine Waltz', 'Spectral Jig', 'Jigs' },
            [30] = { 'Curing Waltz II', 'Box Step', 'Desperate Flourish' },
            [35] = { 'Drain Samba II', 'Healing Waltz' },
            [40] = { 'Stutter Step', 'Reverse Flourish', 'Flourishes II' },
            [45] = { 'Haste Samba', 'Curing Waltz III', 'Violent Flourish' },
            [50] = { 'Building Flourish', 'Contradance' },
            [55] = { 'Chocobo Jig' },
            [60] = { 'Aspir Samba II', 'Wild Flourish' },
            [65] = { 'Drain Samba III' },
            [70] = { 'Curing Waltz IV', 'Chocobo Jig II' },
            [75] = { 'Saber Dance', 'Fan Dance', 'No Foot Rise' },
            [77] = { 'Presto' },
            [78] = { 'Divine Waltz II' },
            [80] = { 'Flourishes III', 'Climactic Flourish' },
            [83] = { 'Feather Step' },
            [87] = { 'Curing Waltz V' },
            [89] = { 'Striking Flourish' },
            [93] = { 'Ternary Flourish' },
            [96] = { 'Grand Pas' },
        },

        traits =
        {
            [15] = { 'Evasion Bonus' },
            [20] = { 'Dual Wield', 'Resist Slow' },
            [25] = { 'Subtle Blow' },
            [30] = { 'Accuracy Bonus' },
            [40] = { 'Dual Wield II' },
            [45] = { 'Evasion Bonus II', 'Subtle Blow II', 'Skillchain Bonus', 'Damage Limit+' },
            [55] = { 'Resist Slow II' },
            [58] = { 'Skillchain Bonus II' },
            [60] = { 'Accuracy Bonus II', 'Dual Wield III' },
            [65] = { 'Subtle Blow III' },
            [71] = { 'Skillchain Bonus III' },
            [75] = { 'Evasion Bonus III', 'Closed Position' },
            [76] = { 'Accuracy Bonus III' },
            [77] = { 'Tactical Parry', 'Conserve TP' },
            [80] = { 'Dual Wield IV', 'Crit. Atk. Bonus' },
            [81] = { 'Resist Slow III' },
            [84] = { 'Tactical Parry II', 'Skillchain Bonus IV' },
            [86] = { 'Evasion Bonus IV', 'Subtle Blow IV' },
            [87] = { 'Conserve TP II' },
            [88] = { 'Crit. Atk. Bonus II' },
            [90] = { 'Damage Limit+ II' },
            [91] = { 'Tactical Parry III' },
            [97] = { 'Tactical Parry IV', 'Skillchain Bonus IV', 'Conserve TP III' },
            [99] = { 'Crit. Atk. Bonus III' },
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
            [75] = { 'Altruism', 'Focalization', 'Tranquility', 'Equanimity', 'Enlightenment' },
            [76] = { 'Libra' },
            [87] = { 'Perpetuance', 'Immanence' },
            [96] = { 'Caper Emissarius' },
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
            [75] = { 'Stormsurge' },
            [76] = { 'Clear Mind V' },
            [78] = { 'Occult Acumen' },
            [79] = { 'Mag. Burst Bonus' },
            [81] = { 'Resist Silence IV' },
            [88] = { 'Max MP Boost II', 'Occult Acumen II' },
            [89] = { 'Mag. Burst Bonus II' },
            [96] = { 'Clear Mind VI' },
            [98] = { 'Occult Acumen III' },
            [99] = { 'Mag. Burst Bonus III' },
        },
    },

    [xi.job.GEO] =
    {
        abilities =
        {
            [1] = { 'Bolster' },
            [5] = { 'Full Circle' },
            [25] = { 'Lasting Emanation', 'Ecliptic Attrition' },
            [40] = { 'Collimated Fervor' },
            [50] = { 'Life Cycle' },
            [60] = { 'Blaze Of Glory' },
            [70] = { 'Dematerialize' },
            [75] = { 'Mending Halation', 'Radial Arcana', 'Entrust' },
            [80] = { 'Theurgic Focus' },
            [90] = { 'Concentric Pulse' },
            [96] = { 'Widened Compass' },
        },

        traits =
        {
            [10] = { 'Conserve MP' },
            [20] = { 'Clear Mind' },
            [25] = { 'Conserve MP II', 'Cardinal Chant' },
            [30] = { 'Max MP Boost' },
            [40] = { 'Conserve MP III', 'Clear Mind II' },
            [45] = { 'Cardinal Chant II' },
            [55] = { 'Conserve MP IV', 'Elemental Celerity' },
            [60] = { 'Max MP Boost II', 'Clear Mind III' },
            [65] = { 'Cardinal Chant III' },
            [70] = { 'Conserve MP V' },
            [75] = { 'Elemental Celerity II', 'Curative Recantation', 'Primeval Zeal' },
            [80] = { 'Clear Mind IV' },
            [85] = { 'Conserve MP VI', 'Cardinal Chant IV' },
            [90] = { 'Max MP Boost III' },
            [95] = { 'Elemental Celerity III' },
            [99] = { 'Conserve MP VII', 'Clear Mind V' },
        },
    },

    [xi.job.RUN] =
    {
        abilities =
        {
            [1] = { 'Ward', 'Effusion' },
            [5] = { 'Rune Enchantment', 'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda', 'Lux', 'Tenebrae' },
            [10] = { 'Vallation' },
            [20] = { 'Swordplay' },
            [25] = { 'Swipe', 'Lunge' },
            [40] = { 'Pflug' },
            [50] = { 'Valiance' },
            [60] = { 'Embolden' },
            [65] = { 'Vivacious Pulse' },
            [70] = { 'Gambit' },
            [75] = { 'Rayke', 'Battuta' },
            [85] = { 'Liement' },
            [95] = { 'One For All' },
            [96] = { 'Odyllic Subterfuge' },
        },

        traits =
        {
            [5] = { 'Tenacity' },
            [10] = { 'Magic Def. Bonus' },
            [15] = { 'Inquartata' },
            [20] = { 'Max HP Boost' },
            [25] = { 'Tenacity II' },
            [30] = { 'Magic Def. Bonus II' },
            [35] = { 'Auto Regen' },
            [40] = { 'Max HP Boost II', 'Tactical Parry' },
            [45] = { 'Tenacity III', 'Inquartata II' },
            [50] = { 'Accuracy Bonus', 'Magic Def. Bonus III' },
            [60] = { 'Max HP Boost III', 'Tactical Parry II' },
            [65] = { 'Auto Regen II' },
            [70] = { 'Accuracy Bonus II', 'Magic Def. Bonus IV' },
            [75] = { 'Tenacity IV', 'Inquartata III' },
            [76] = { 'Magic Def. Bonus V' },
            [80] = { 'Max HP Boost IV', 'Tenacity V' },
            [85] = { 'Tactical Parry III' },
            [90] = { 'Accuracy Bonus III', 'Inquartata IV' },
            [91] = { 'Magic Def. Bonus VI' },
            [95] = { 'Auto Regen III', 'Tenacity VI' },
            [99] = { 'Magic Def. Bonus VII', 'Max HP Boost V' },
        },
    },

    [23] =
    {
        abilities =
        {
            [1] = { 'Relinquish' },
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
