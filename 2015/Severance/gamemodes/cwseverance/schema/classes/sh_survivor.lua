--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local CLASS = {};
	CLASS.color = Color(100, 150, 100, 255);
	CLASS.factions = {FACTION_SURVIVOR};
	CLASS.isDefault = true;
	CLASS.description = "A survivor of the zombie apocalypse.";
	CLASS.defaultPhysDesc = "Wearing dirty clothes and a small satchel";
CLASS_SURVIVOR = Clockwork.class:Register(CLASS, "Survivor");