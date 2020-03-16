--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(165, 155, 95, 255);
CLASS.factions = {FACTION_WASTELANDER};
CLASS.isDefault = true;
CLASS.description = "A survivor of the world's most catastrophic epidemic.";
CLASS.defaultPhysDesc = "Wearing dirty clothes and a small satchel";

CLASS_WASTELANDER = openAura.class:Register(CLASS, "Wastelander");