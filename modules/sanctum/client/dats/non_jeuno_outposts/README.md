# Non-Jeuno native outpost DATs

This package gives the custom Outpost Liaison actors in Tavnazian Safehold and Aht Urhgan Whitegate the complete native outpost menu.

It patches three client resources per zone:

- The entity list adds the `Outpost Liaison` actor name and actor-ID mapping.
- The event file adds Northern San d'Oria's native outpost event as event `10000`.
- The English dialogue file adds the native outpost menu text used by that event.

## Install

1. Close every running FFXI client.
2. Back up the six matching files under the FFXI installation folder.
3. Copy the contents of `package` into the FFXI installation folder and allow the `ROM3` and `ROM4` folders to merge.
4. Restart the map server after the Sanctum Lua and SQL changes are installed.

The package contains:

- `ROM3/3/8.DAT`
- `ROM3/0/92.DAT`
- `ROM3/2/36.DAT`
- `ROM4/1/49.DAT`
- `ROM4/0/55.DAT`
- `ROM4/0/123.DAT`

## Rebuild after an FFXI update

Run:

```powershell
.\build.ps1
```

To use a different FFXI installation:

```powershell
.\build.ps1 -FfxiRoot 'D:\Games\SquareEnix\FINAL FANTASY XI'
```

The builder starts from the installed retail DATs, writes a fresh `package`, verifies all actor/event/dialogue mappings, and updates `manifest.sha256`.
