--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Strength";
	ATTRIBUTE.maximum = 100;
	ATTRIBUTE.uniqueID = "str";
	ATTRIBUTE.description = "Affects your overall strength, e.g: how hard you punch.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_STRENGTH = Clockwork.attribute:Register(ATTRIBUTE);