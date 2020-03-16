--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Books";
MOUNT.author = "kuromeku";

-- Add a custom permit.
kuroScript.game:AddCustomPermit("Readable Material", "3", "models/props_lab/bindergreenlabel.mdl");

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");