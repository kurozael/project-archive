--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Reckoner";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/reckoner";
AUGMENT.karma = "evil";
AUGMENT.description = "Your generators will put serums earned into your inventory.";

AUG_RECKONER = openAura.augment:Register(AUGMENT);