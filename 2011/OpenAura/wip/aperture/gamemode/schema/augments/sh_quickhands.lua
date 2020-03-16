--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Quickhands";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/quickhands";
AUGMENT.karma = "evil";
AUGMENT.description = "You will tie characters 30% faster.";

AUG_QUICKHANDS = openAura.augment:Register(AUGMENT);