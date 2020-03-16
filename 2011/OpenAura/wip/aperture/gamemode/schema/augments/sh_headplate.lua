--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Headplate";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/headplate";
AUGMENT.karma = "good";
AUGMENT.description = "You have a 50% chance of taking no damage when headshotted.";

AUG_HEADPLATE = openAura.augment:Register(AUGMENT);