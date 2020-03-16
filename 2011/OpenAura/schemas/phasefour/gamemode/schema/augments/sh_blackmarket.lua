--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Blackmarket";
AUGMENT.cost = 3000;
AUGMENT.image = "augments/blackmarket";
AUGMENT.honor = "evil";
AUGMENT.description = "You can cash in items in your inventory for 20% of their original price.";

AUG_BLACKMARKET = openAura.augment:Register(AUGMENT);