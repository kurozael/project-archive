--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Tracking";
AUGMENT.cost = 2000;
AUGMENT.image = "augments/tracking";
AUGMENT.honor = "evil";
AUGMENT.description = "You can see the red outline of characters that attack your alliance through walls.";

AUG_TRACKING = openAura.augment:Register(AUGMENT);