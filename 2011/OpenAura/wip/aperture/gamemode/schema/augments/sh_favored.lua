--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Favored";
AUGMENT.cost = 1600;
AUGMENT.image = "aperture/augments/favored";
AUGMENT.karma = "evil";
AUGMENT.description = "Whenever you gain karma, the karma gained is doubled.\nThis is for characters that want to try and remain good\nand want to quickly get up from having evil karma.";

AUG_FAVORED = openAura.augment:Register(AUGMENT);