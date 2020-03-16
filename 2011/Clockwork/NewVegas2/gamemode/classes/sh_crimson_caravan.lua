--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};
	CLASS.color = Color(200, 50, 50, 255);
	CLASS.flags = "T";
	CLASS.factions = {FACTION_CARAVAN};
	CLASS.isDefault = true;
	CLASS.description = "A member of the famous trading organisation.";
	CLASS.defaultPhysDesc = "Wearing dirty clothes and a large backpack";
CLASS_CARAVAN = Clockwork.class:Register(CLASS, "Crimson Carvan");