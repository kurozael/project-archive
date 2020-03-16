--[[
Name: "sh_dexterity.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Dexterity";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "dex";
ATTRIBUTE.description = "Affects your overall dexterity, e.g: how fast you can tie/untie.";

-- Register the attribute.
ATB_DEXTERITY = kuroScript.attribute.Register(ATTRIBUTE);