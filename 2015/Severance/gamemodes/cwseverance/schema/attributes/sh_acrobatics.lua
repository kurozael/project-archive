--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Acrobatics";
	ATTRIBUTE.maximum = 75;
	ATTRIBUTE.uniqueID = "acr";
	ATTRIBUTE.description = "Affects the overall height at which you can jump.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_ACROBATICS = Clockwork.attribute:Register(ATTRIBUTE);