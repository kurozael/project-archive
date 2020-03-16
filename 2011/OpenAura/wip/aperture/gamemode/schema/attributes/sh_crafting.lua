--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Crafting";
ATTRIBUTE.image = "aperture/attributes/crafting";
ATTRIBUTE.maximum = 50;
ATTRIBUTE.uniqueID = "eng";
ATTRIBUTE.category = "Skills";
ATTRIBUTE.description = "Affects what level of equipment you can craft.";

ATB_CRAFTING = openAura.attribute:Register(ATTRIBUTE);