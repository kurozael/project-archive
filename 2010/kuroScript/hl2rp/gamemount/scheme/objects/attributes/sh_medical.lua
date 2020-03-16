--[[
Name: "sh_medical.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Medical";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "med";
ATTRIBUTE.description = "Affects your overall medical skills, e.g: health gained from vials and kits.";

-- Register the attribute.
ATB_MEDICAL = kuroScript.attribute.Register(ATTRIBUTE);