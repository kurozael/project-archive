--[[
Name: "sh_ota_owc.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(150, 50, 50, 255);
VOCATION.class = CLASS_OTA;
VOCATION.wages = 300;
VOCATION.wagesName = "Supplies";
VOCATION.maleModel = "models/combine_super_soldier.mdl";
VOCATION.description = "An elite transhuman Overwatch commander.";
VOCATION.defaultDetails = "ShinyOverwatchGear";

-- Register the vocation.
VOC_OTA_OWC = kuroScript.vocation.Register(VOCATION, "Elite Overwatch Commander");