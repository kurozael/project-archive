--[[
Name: "sh_strength.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Strength";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "str";
ATTRIBUTE.description = "Affects your overall strength, e.g: how hard you punch.";

-- Register the attribute.
ATB_STRENGTH = kuroScript.attribute.Register(ATTRIBUTE);