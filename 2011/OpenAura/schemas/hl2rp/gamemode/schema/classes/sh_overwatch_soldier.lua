--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(150, 50, 50, 255);
CLASS.wages = 40;
CLASS.factions = {FACTION_OTA};
CLASS.wagesName = "Supplies";
CLASS.description = "A transhuman Overwatch soldier produced by the Combine.";
CLASS.defaultPhysDesc = "Wearing dirty Overwatch gear";

CLASS_OWS = openAura.class:Register(CLASS, "Overwatch Soldier");