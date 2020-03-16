--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Reckoner";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/reckoner";
AUGMENT.honor = "evil";
AUGMENT.description = "Your generators will put rations earned into your inventory.";

AUG_RECKONER = openAura.augment:Register(AUGMENT);