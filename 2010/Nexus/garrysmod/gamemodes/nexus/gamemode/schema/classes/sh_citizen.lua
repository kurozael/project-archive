--[[
Name: "sh_citizen.lua".
Product: "nexus".
--]]

local CLASS = {};

CLASS.color = Color(150, 100, 50, 255);
CLASS.factions = {FACTION_CITIZEN};
CLASS.isDefault = true;
CLASS.description = "A regular Citizen living in the city.";

CLASS_CITIZEN = nexus.class.Register(CLASS, "Citizen");