--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Acrobatics";
ATTRIBUTE.maximum = 100;
ATTRIBUTE.uniqueID = "acr";
ATTRIBUTE.description = "Affects the overall height at which you can jump.";
ATTRIBUTE.characterScreen = true;

ATB_ACROBATICS = openAura.attribute:Register(ATTRIBUTE);