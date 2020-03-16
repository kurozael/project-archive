--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Rapid Melee";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/rapidmelee";
AUGMENT.honor = "evil";
AUGMENT.description = "Your melee weapons attack 50% faster.\nThis does not include the fist.";

AUG_RAPIDMELEE = openAura.augment:Register(AUGMENT);