--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(50, 100, 150, 255);
CLASS.factions = {FACTION_MPF};
CLASS.description = "A metropolice scanner, it utilises Combine technology.";
CLASS.defaultPhysDesc = "Making beeping sounds";

CLASS_MPS = openAura.class:Register(CLASS, "Metropolice Scanner");