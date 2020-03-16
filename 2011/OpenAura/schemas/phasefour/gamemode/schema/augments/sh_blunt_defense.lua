--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Blunt Defense";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/bluntdefense";
AUGMENT.honor = "good";
AUGMENT.description = "You take 25% less damage from melee weapons.\nThis includes the fist.";

AUG_BLUNTDEFENSE = openAura.augment:Register(AUGMENT);