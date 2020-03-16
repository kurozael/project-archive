--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local CLASS = {};
	CLASS.color = Color(50, 75, 100, 255);
	CLASS.factions = {FACTION_CDF};
	CLASS.isDefault = true;
	CLASS.description = "A member of the Civil Defense Force.";
	CLASS.defaultPhysDesc = "Wearing a dark grey uniform with a gas mask";
CLASS_CDF = Clockwork.class:Register(CLASS, "C.D.F");