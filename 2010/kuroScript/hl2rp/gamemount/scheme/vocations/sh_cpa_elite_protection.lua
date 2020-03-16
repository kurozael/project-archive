--[[
Name: "sh_cpa_elite_protection.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(50, 100, 150, 255);
VOCATION.class = CLASS_CPA;
VOCATION.wages = 140;
VOCATION.wagesName = "Supplies";
VOCATION.maleModel = "models/leet_police2.mdl";
VOCATION.description = "An elite Civil Protection unit.";
VOCATION.defaultDetails = "MetroCopJacket";

-- Register the vocation.
VOC_CPA_EPU = kuroScript.vocation.Register(VOCATION, "Elite Civil Protection Unit");