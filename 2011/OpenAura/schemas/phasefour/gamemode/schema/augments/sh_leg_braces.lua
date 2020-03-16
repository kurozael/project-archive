--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Leg Braces";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/legbraces";
AUGMENT.honor = "perma";
AUGMENT.description = "This augment will reduce your falling damage by 50%.";

AUG_LEGBRACES = openAura.augment:Register(AUGMENT);