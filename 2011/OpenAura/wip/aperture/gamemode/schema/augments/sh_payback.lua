--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Payback";
AUGMENT.cost = 2000;
AUGMENT.image = "aperture/augments/payback";
AUGMENT.karma = "evil";
AUGMENT.description = "With this augment you receive more for destroying generators.\nThis only applies to generators belonging to good characters.";

AUG_PAYBACK = openAura.augment:Register(AUGMENT);