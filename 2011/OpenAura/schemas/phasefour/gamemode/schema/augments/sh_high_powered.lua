--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "High Powered";
AUGMENT.cost = 3000;
AUGMENT.image = "augments/highpowered";
AUGMENT.honor = "perma";
AUGMENT.description = "Your jetpack fuel will last two times longer with this augment.";

AUG_HIGHPOWERED = openAura.augment:Register(AUGMENT);