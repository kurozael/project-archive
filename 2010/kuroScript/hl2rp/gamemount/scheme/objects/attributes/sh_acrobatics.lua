--[[
Name: "sh_acrobatics.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Acrobatics";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "acr";
ATTRIBUTE.description = "Affects the overall height at which you can jump.";

-- Register the attribute.
ATB_ACROBATICS = kuroScript.attribute.Register(ATTRIBUTE);