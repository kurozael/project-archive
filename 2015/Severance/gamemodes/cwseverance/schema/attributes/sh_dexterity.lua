--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ATTRIBUTE = Clockwork.attribute:New();
	ATTRIBUTE.name = "Dexterity";
	ATTRIBUTE.maximum = 75;
	ATTRIBUTE.uniqueID = "dex";
	ATTRIBUTE.description = "Affects your overall dexterity, e.g: how fast you can tie/untie.";
	ATTRIBUTE.isOnCharScreen = true;
ATB_DEXTERITY = Clockwork.attribute:Register(ATTRIBUTE);