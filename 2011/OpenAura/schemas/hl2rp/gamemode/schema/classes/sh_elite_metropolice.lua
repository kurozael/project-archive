--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(50, 100, 150, 255);
CLASS.wages = 30;
CLASS.factions = {FACTION_MPF};
CLASS.wagesName = "Supplies";
CLASS.maleModel = "models/leet_police2.mdl";
CLASS.description = "An elite metropolice unit working as Civil Protection.";
CLASS.defaultPhysDesc = "Wearing a metrocop jacket with a radio";

CLASS_EMP = openAura.class:Register(CLASS, "Elite Metropolice");