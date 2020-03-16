--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Medical";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "med";
ATTRIBUTE.description = "Affects your overall medical skills, e.g: health gained from vials and kits.";
ATTRIBUTE.characterScreen = true;

ATB_MEDICAL = openAura.attribute:Register(ATTRIBUTE);