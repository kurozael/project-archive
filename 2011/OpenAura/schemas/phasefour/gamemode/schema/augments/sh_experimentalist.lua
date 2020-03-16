--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Experimentalist";
AUGMENT.cost = 2000;
AUGMENT.image = "augments/experimentalist";
AUGMENT.honor = "perma";
AUGMENT.description = "With this augment your flash grenades will also emit a smoke cloud.";

AUG_EXPERIMENTALIST = openAura.augment:Register(AUGMENT);