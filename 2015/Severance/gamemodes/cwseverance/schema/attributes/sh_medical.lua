--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Medical";
	ATTRIBUTE.maximum = 75;
	ATTRIBUTE.uniqueID = "med";
	ATTRIBUTE.description = "Affects your overall medical skills, e.g: health gained from vials and kits.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_MEDICAL = Clockwork.attribute:Register(ATTRIBUTE);