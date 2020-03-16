--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Incendiary";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/incendiary";
AUGMENT.karma = "good";
AUGMENT.description = "Your firearms have a 5% chance to set the victim on fire.\nThis augment only applies when attacking evil characters.";

AUG_INCENDIARY = openAura.augment:Register(AUGMENT);