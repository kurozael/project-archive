--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Writing";
MOUNT.author = "kuromeku";
MOUNT.paperIDs = {};

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");