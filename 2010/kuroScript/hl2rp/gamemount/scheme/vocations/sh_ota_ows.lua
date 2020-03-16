--[[
Name: "sh_ota_ows.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(150, 50, 50, 255);
VOCATION.class = CLASS_OTA;
VOCATION.wages = 200;
VOCATION.wagesName = "Supplies";
VOCATION.description = "A transhuman Overwatch soldier.";
VOCATION.defaultDetails = "DirtyOverwatchGear";

-- Register the vocation.
VOC_OTA_OWS = kuroScript.vocation.Register(VOCATION, "Overwatch Soldier");