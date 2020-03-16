--[[
Name: "sh_agility.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Agility";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "agt";
ATTRIBUTE.description = "Affects your overall speed, e.g: how fast you run.";

-- Register the attribute.
ATB_AGILITY = kuroScript.attribute.Register(ATTRIBUTE);