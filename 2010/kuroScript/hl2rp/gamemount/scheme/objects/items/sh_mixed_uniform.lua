--[[
Name: "sh_mixed_uniform.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "clothes_base";
ITEM.name = "Mixed Uniform";
ITEM.group = "group03m";
ITEM.weight = 3;
ITEM.protection = 0.6;
ITEM.description = "A mixed resistance and Combine uniform with a dusty face-plate.";
ITEM.replacement = "models/humans/group03/male_soldier.mdl";

-- Register the item.
kuroScript.item.Register(ITEM);