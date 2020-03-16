--[[
Name: "sh_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Oxygen Meter";
MOUNT.author = "kuromeku";

-- Register a player networked table.
RegisterNWTablePlayer( {
	{"ks_Oxygen", 100, NWTYPE_SHORT, REPL_PLAYERONLY},
} );

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");