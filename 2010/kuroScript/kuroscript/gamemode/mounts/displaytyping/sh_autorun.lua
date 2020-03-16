--[[
Name: "sh_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Display Typing";
MOUNT.author = "kuromeku";

-- Register a player networked table.
RegisterNWTablePlayer( {
	{"ks_Typing", 0, NWTYPE_SHORT, REPL_EVERYONE}
} );

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_enums.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");