# Upper Jeuno native outpost-menu test

This patch adds one copy of Northern San d'Oria's retail outpost event to a dedicated
Upper Jeuno actor. It does not replace or edit any existing Upper Jeuno actor block.

Client files:

- `ROM/21/53.DAT`: Upper Jeuno event bytecode with actor `0x010F4110`, event `10000`.
- `ROM/25/53.DAT`: Upper Jeuno English dialogue with the eleven retail outpost strings appended.

Server files:

- `modules/sanctum/warps/opjeuno.lua`: native event trigger and result handlers.
- `modules/sanctum/sql/upper_jeuno_native_outpost.sql`: fixed-ID liaison NPC.

The generated `package` directory is ready to copy over the FFXI client root. Back up the
two destination DATs first. This test targets the English client; a Japanese client needs
the equivalent strings added to `ROM/23/53.DAT`.

To rebuild the package with `xi-tools`:

```powershell
uv run python build_upper_jeuno_outpost.py `
  --ffxi-dir "C:\Sanctum XI\SquareEnix\FINAL FANTASY XI" `
  --output package
```
