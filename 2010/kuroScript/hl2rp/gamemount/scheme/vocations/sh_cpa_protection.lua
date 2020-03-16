--[[
Name: "sh_cpa_protection.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(50, 100, 150, 255);
VOCATION.class = CLASS_CPA;
VOCATION.wages = 100;
VOCATION.default = true;
VOCATION.wagesName = "Supplies";
VOCATION.description = "A Civil Protection unit.";
VOCATION.defaultDetails = "MetroCopJacket";

-- Register the vocation.
VOC_CPA_PRO = kuroScript.vocation.Register(VOCATION, "Civil Protection Unit");