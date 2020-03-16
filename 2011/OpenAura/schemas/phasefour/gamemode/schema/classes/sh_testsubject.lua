--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.wages = 50;
CLASS.color = Color(150, 125, 100, 255);
CLASS.factions = {FACTION_CIVILIAN};
CLASS.isDefault = true;
CLASS.wagesName = "Supplies";
CLASS.description = "The test subject of an Aperture Science experiment.";
CLASS.defaultPhysDesc = "Wearing tattered clothing";

CLASS_TESTSUBJECT = openAura.class:Register(CLASS, "Test Subject");