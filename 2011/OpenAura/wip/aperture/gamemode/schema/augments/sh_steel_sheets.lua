--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Steel Sheets";
AUGMENT.cost = 1600;
AUGMENT.image = "aperture/augments/steelsheets";
AUGMENT.karma = "good";
AUGMENT.description = "With this augment your generators will be harder to destroy.";

AUG_STEELSHEETS = openAura.augment:Register(AUGMENT);