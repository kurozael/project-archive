--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Adrenaline";
AUGMENT.cost = 3000;
AUGMENT.image = "augments/adrenaline";
AUGMENT.honor = "perma";
AUGMENT.description = "With this augment you will slowly revive yourself in critical condition.";

AUG_ADRENALINE = openAura.augment:Register(AUGMENT);