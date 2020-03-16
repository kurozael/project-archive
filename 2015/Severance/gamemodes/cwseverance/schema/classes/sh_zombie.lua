--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local CLASS = Clockwork.class:New("Zombie");
	CLASS.color = Color(100, 150, 100, 255);
	CLASS.factions = {FACTION_INFECTED};
	CLASS.isDefault = true;
	CLASS.description = "A groaning disgusting walking undead.";
	CLASS.defaultPhysDesc = "Bloodied skin and wearing dirty clothes.";
CLASS_INFECTED = CLASS:Register();