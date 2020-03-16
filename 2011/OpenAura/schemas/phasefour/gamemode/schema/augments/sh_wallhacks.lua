--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Wallhacks";
AUGMENT.cost = 2000;
AUGMENT.image = "augments/wallhacks";
AUGMENT.honor = "good";
AUGMENT.description = "You can see the green outline of characters in your alliance through walls.";

AUG_WALLHACKS = openAura.augment:Register(AUGMENT);