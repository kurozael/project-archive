--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(150, 125, 100, 255);
CLASS.factions = {FACTION_CIVILIAN};
CLASS.isDefault = true;
CLASS.description = "A survivor of the zombie apocalypse.";
CLASS.defaultPhysDesc = "Wearing dirty clothes and a small satchel";

CLASS_SURVIVOR = openAura.class:Register(CLASS, "Survivor");