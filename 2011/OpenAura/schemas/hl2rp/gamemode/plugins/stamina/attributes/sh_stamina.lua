--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Stamina";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "stam";
ATTRIBUTE.description = "Affects your overall stamina, e.g: how long you can run for.";
ATTRIBUTE.characterScreen = true;

ATB_STAMINA = openAura.attribute:Register(ATTRIBUTE);