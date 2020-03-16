--[[
Name: "sh_ota_eow.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(150, 50, 50, 255);
VOCATION.class = CLASS_OTA;
VOCATION.wages = 240;
VOCATION.wagesName = "Supplies";
VOCATION.maleModel = "models/combine_super_soldier.mdl";
VOCATION.description = "An elite transhuman Overwatch soldier.";
VOCATION.defaultDetails = "ShinyOverwatchGear";

-- Register the vocation.
VOC_OTA_EOW = kuroScript.vocation.Register(VOCATION, "Elite Overwatch Soldier");