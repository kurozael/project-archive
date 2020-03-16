--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.wages = 0;
CLASS.color = Color(150, 125, 100, 255);
CLASS.factions = {FACTION_CIVILIAN};
CLASS.isDefault = true;
CLASS.description = "A regular inhabitant of the city.";
CLASS.defaultPhysDesc = "Wearing nice and clean clothes";

CLASS_CIVILIAN = openAura.class:Register(CLASS, "Civilian");