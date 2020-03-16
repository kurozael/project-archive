--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Biosignal";
MOUNT.author = "kuromeku";

-- Register a player networked table.
RegisterNWTablePlayer( {
	{"ks_Biosignal", false, NWTYPE_BOOL, REPL_EVERYONE}
} );

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");