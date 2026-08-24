-----------------------------------
-- PET: Jug
--
-- Spawn hook shared by every jug pet. CPetEntity::Spawn calls OnMobSpawn and
-- GetScriptName returns 'jug' for the whole class, so this is the one entry
-- point they all pass through.
--
-- Empty by design. Per-family behaviour is overridden from modules/sanctum/jobs/beastmaster/lua.
-----------------------------------

xi          = xi or {}
xi.pets     = xi.pets or {}
xi.pets.jug = xi.pets.jug or {}

xi.pets.jug.onMobSpawn = function(pet)
end
