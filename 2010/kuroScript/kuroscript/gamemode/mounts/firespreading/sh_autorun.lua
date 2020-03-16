--[[
Name: "sh_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Fire Spreading";
MOUNT.author = "kuromeku";
MOUNT.entityFires = {};

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");