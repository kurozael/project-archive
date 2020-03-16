--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Metalship";
AUGMENT.cost = 2000;
AUGMENT.image = "aperture/augments/metalship";
AUGMENT.karma = "good";
AUGMENT.description = "Your Serum Producer will produce an extra $250 an hour.";

AUG_METALSHIP = openAura.augment:Register(AUGMENT);