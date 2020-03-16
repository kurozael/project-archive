--[[
Name: "sh_cpa_scanner.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(50, 100, 150, 255);
VOCATION.class = CLASS_CPA;
VOCATION.wagesName = "Supplies";
VOCATION.description = "A Civil authority surveilance unit.";
VOCATION.defaultDetails = "BlindingFlashlight";

-- Register the vocation.
VOC_CPA_SCN = kuroScript.vocation.Register(VOCATION, "Civil Protection Scanner");