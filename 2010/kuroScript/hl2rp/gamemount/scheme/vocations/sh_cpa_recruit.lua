--[[
Name: "sh_cpa_recruit.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(50, 100, 150, 255);
VOCATION.class = CLASS_CPA;
VOCATION.wages = 40;
VOCATION.wagesName = "Supplies";
VOCATION.description = "A Civil Protection recruit.";
VOCATION.defaultDetails = "MetroCopJacket";

-- Register the vocation.
VOC_CPA_RCT = kuroScript.vocation.Register(VOCATION, "Civil Protection Recruit");