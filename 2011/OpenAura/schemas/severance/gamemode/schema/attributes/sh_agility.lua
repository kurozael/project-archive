--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Agility";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "agt";
ATTRIBUTE.description = "Affects your overall speed, e.g: how fast you run.";
ATTRIBUTE.characterScreen = true;

ATB_AGILITY = openAura.attribute:Register(ATTRIBUTE);