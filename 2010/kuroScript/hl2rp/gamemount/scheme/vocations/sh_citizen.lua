--[[
Name: "sh_citizen.lua".
Product: "HL2 RP".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(150, 100, 50, 255);
VOCATION.class = CLASS_CIT;
VOCATION.default = true;
VOCATION.description = "A Denizen of the city.";
VOCATION.defaultDetails = "DirtyClothes";

-- Register the vocation.
VOC_CITIZEN = kuroScript.vocation.Register(VOCATION, "Citizen");