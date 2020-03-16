--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Obsessive";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/obsessive";
AUGMENT.karma = "perma";
AUGMENT.description = "Your safebox can hold triple the amount with this augment.";

AUG_OBSESSIVE = openAura.augment:Register(AUGMENT);