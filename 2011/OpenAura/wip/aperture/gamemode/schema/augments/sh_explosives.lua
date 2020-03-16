--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Explosives";
AUGMENT.cost = 1600;
AUGMENT.image = "aperture/augments/explosives";
AUGMENT.karma = "perma";
AUGMENT.description = "With this augment you will be able to purchase grenades and landmines.";

AUG_EXPLOSIVES = openAura.augment:Register(AUGMENT);