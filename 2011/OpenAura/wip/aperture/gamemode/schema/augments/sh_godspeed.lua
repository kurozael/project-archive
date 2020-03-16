--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Godspeed";
AUGMENT.cost = 1600;
AUGMENT.image = "aperture/augments/godspeed";
AUGMENT.karma = "perma";
AUGMENT.description = "Using this augment will cause you to sprinter 10% faster.";

AUG_GODSPEED = openAura.augment:Register(AUGMENT);