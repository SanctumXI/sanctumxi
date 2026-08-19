# Sanctum Nameplates

Ashita v4 addon that draws crisp, depth-tested names over rendered entities. Labels automatically anchor above each model's live skeleton bounds, avoid one another on screen, and can include exact levels, conditional HP bars, and an optional HP percentage.

## Install and test

Copy this directory to `addons/SanctumNameplates`, then run:

```text
/addon load sanctumnameplates
```

Open the live settings window with:

```text
/snp
```

The default profile keeps original player nameplates, uses the addon renderer for pets, mobs, and NPCs up to 100 yalms, and applies a hard distance cutoff without opacity fading. Labels use a fixed 16-pixel normal size, a configurable size at 5 yalms or closer, and an independently configurable 20-pixel targeted size. Mob levels, automatic model-top placement, overlap prevention, HP bars, and HP percentages are enabled. Unloading or disabling the addon restores all original nameplates.

The original-nameplate selector offers `Off`, `On`, and `Players Only`. `Players Only` keeps native player plates and addon-rendered pet plates, so pets use the same selected font, Font Size, and Target Font Size as mobs. `On` restores all native plates, including native pet plates that do not use the addon's font settings.

The settings window includes a nameplate font selector populated from supported fonts installed on the client. Ashita Default is always available as a safe fallback. The current target has independent name size/color, HP percentage size/color, and HP bar size/color controls.

HP bars and percentages can be limited independently by distance. Their Targeted, Damaged, and Engaged conditions use "any enabled condition" behavior; disabling all three conditions makes HP information always visible within its distance limit. These rules never hide or resize the name itself.

Mob names are always colored by claim state: unclaimed, claimed by your party, claimed by someone else, or engaged by your party. All four colors are configurable. Optional relative-difficulty coloring applies a separate configurable color to the `Lv.X` prefix, leaving the mob name's claim color intact. The current target color overrides both.

Variant names receive a strong animated violet/cyan glow with several small independently pulsing twinkles around the label edges. Chainbreakers use a stronger gold/orange version with additional twinkles. The effect and its intensity can be changed in the settings window. Variant detection supports both the server `V ...` alias and the expanded `Variant ...` name; known Chainbreaker display names are listed near the top of the addon file for easy expansion.

Useful commands:

```text
/snp size 20
/snp targetsize 24
/snp closesize 20
/snp hptextsize 12
/snp font verdana
/snp glimmer on
/snp glimmerstrength 0.85
/snp max 100
/snp height 0.25
/snp autobounds on
/snp native players
/snp targetcolor 255 184 61
/snp levels off
/snp hp off
/snp hppercent off
/snp overlap on
/snp difficulty on
/snp hptargeted on
/snp hpdamaged on
/snp hpengaged on
/snp status
```

`/snp height` adjusts the gap above the detected top of the model. Maximum distance is limited to 25–100 yalms, and outline width is limited to 0–2 pixels. The fallback model height setting is used for models whose skeleton bounds cannot be read. Name text, HP displays, glows, and twinkles all use the scene depth buffer, so intervening terrain and collision meshes hide the complete nameplate.
