--[[
Name: "sh_citizen.lua".
Product: "kuroScript".
--]]

local VOCATION = {};

-- Set some information.
VOCATION.color = Color(150, 100, 50, 255);
VOCATION.class = CLASS_CZ;
VOCATION.default = true;
VOCATION.description = "A regular Citizen living in the city.";

-- Register the vocation.
VOC_CS = kuroScript.vocation.Register(VOCATION, "Citizen");