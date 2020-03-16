--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Engineering";
ATTRIBUTE.maximum = 50;
ATTRIBUTE.uniqueID = "eng";
ATTRIBUTE.category = "Skills";
ATTRIBUTE.description = "Affects what level of equipment you can craft.";

ATB_ENGINEERING = openAura.attribute:Register(ATTRIBUTE);