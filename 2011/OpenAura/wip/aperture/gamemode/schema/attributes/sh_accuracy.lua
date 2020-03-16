--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Accuracy";
ATTRIBUTE.image = "aperture/attributes/accuracy";
ATTRIBUTE.maximum = 100;
ATTRIBUTE.uniqueID = "acc";
ATTRIBUTE.category = "Skills";
ATTRIBUTE.description = "Affects how accurate you can fire with weapons.";

ATB_ACCURACY = openAura.attribute:Register(ATTRIBUTE);