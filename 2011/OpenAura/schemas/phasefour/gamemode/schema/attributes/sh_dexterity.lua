--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Dexterity";
ATTRIBUTE.maximum = 100;
ATTRIBUTE.uniqueID = "dex";
ATTRIBUTE.description = "Affects your overall dexterity, e.g: how fast you can tie/untie.";
ATTRIBUTE.characterScreen = true;

ATB_DEXTERITY = openAura.attribute:Register(ATTRIBUTE);