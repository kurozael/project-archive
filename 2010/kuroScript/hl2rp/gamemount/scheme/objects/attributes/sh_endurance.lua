--[[
Name: "sh_endurance.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Endurance";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "end";
ATTRIBUTE.description = "Affects your overall endurance, e.g: how much pain you can take.";

-- Register the attribute.
ATB_ENDURANCE = kuroScript.attribute.Register(ATTRIBUTE);