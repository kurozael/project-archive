--[[
Name: "sh_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Character Views";
MOUNT.author = "kuromeku";

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");