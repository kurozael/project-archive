--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Recycler";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/recycler";
AUGMENT.honor = "evil";
AUGMENT.description = "You have a 50% chance of getting health back when you headshot a character.";

AUG_RECYCLER = openAura.augment:Register(AUGMENT);