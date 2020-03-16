--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Endurance";
	ATTRIBUTE.maximum = 100;
	ATTRIBUTE.uniqueID = "end";
	ATTRIBUTE.description = "Affects your overall endurance, e.g: how much pain you can take.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_ENDURANCE = Clockwork.attribute:Register(ATTRIBUTE);