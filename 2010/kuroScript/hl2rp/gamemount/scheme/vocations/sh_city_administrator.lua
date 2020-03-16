--[[
Name: "sh_cad.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(255, 200, 100, 255);
VOCATION.class = CLASS_CAD;
VOCATION.wages = 140;
VOCATION.default = true;
VOCATION.wagesName = "Allowance";
VOCATION.description = "Local Administrator for the city";
VOCATION.defaultDetails = "CleanClothes";

-- Register the vocation.
VOC_CAD = kuroScript.vocation.Register(VOCATION, "City Administrator");