--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Reincarnation";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/reincarnation";
AUGMENT.karma = "perma";
AUGMENT.description = "With this augment you will spawn 75% quicker.";

AUG_REINCARNATION = openAura.augment:Register(AUGMENT);