--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Rouseless";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/rouseless";
AUGMENT.karma = "evil";
AUGMENT.description = "You can see through other character's skull masks.";

AUG_ROUSELESS = openAura.augment:Register(AUGMENT);