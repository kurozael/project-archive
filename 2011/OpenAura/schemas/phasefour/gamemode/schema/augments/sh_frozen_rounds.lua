--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Frozen Rounds";
AUGMENT.cost = 3000;
AUGMENT.image = "augments/frozenrounds";
AUGMENT.honor = "evil";
AUGMENT.description = "Your firearms have a 5% chance to freeze the victim temporarily.\nThis augment only applies when attacking good characters.";

AUG_FROZENROUNDS = openAura.augment:Register(AUGMENT);