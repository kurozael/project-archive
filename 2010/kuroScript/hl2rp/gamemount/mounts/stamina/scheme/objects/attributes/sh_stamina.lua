--[[
Name: "sh_stamina.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Stamina";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "stam";
ATTRIBUTE.description = "Affects your overall stamina, e.g: how long you can run for.";

-- Register the attribute.
ATB_STAMINA = kuroScript.attribute.Register(ATTRIBUTE);