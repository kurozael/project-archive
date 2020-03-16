--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Strength";
	ATTRIBUTE.maximum = 75;
	ATTRIBUTE.uniqueID = "str";
	ATTRIBUTE.description = "Affects your overall strength, e.g: how hard you punch.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_STRENGTH = Clockwork.attribute:Register(ATTRIBUTE);