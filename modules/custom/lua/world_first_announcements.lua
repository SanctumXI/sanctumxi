-- Replaced by modules/custom/lua/ServerFirst.lua.
--
-- This data-only compatibility stub is intentionally inert.  The former
-- implementation used a cached server variable and the final blow player,
-- which could produce duplicate notices beside ServerFirst and did not retain
-- a roster.  Returning a plain table keeps the module loader from registering
-- an empty override module.
return {}
