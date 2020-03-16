--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Armored";
AUGMENT.cost = 2000;
AUGMENT.image = "augments/armored";
AUGMENT.honor = "perma";
AUGMENT.description = "You will get 50% more armor when kevlar is used.";

AUG_ARMORED = openAura.augment:Register(AUGMENT);