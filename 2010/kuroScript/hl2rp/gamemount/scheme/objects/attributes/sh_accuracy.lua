--[[
Name: "sh_accuracy.lua".
Product: "HL2 RP".
--]]

local ATTRIBUTE = {};

-- Set some information.
ATTRIBUTE.name = "Accuracy";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "acc";
ATTRIBUTE.description = "Affects your overall accuracy, e.g: how much recoil you receive.";

-- Register the attribute.
ATB_ACCURACY = kuroScript.attribute.Register(ATTRIBUTE);