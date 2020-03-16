--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Armadillo";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/armadillo";
AUGMENT.karma = "perma";
AUGMENT.description = "With this augment you will be able to purchase the best clothing.";

AUG_ARMADILLO = openAura.augment:Register(AUGMENT);