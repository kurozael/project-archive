--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Stamina";
MOUNT.author = "kuromeku";

-- Register a player networked table.
RegisterNWTablePlayer( {
	{"ks_Stamina", 100, NWTYPE_SHORT, REPL_PLAYERONLY},
} );

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");