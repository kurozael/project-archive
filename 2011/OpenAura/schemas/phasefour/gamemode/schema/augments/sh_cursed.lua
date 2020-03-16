--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Cursed";
AUGMENT.cost = 1600;
AUGMENT.image = "augments/cursed";
AUGMENT.honor = "good";
AUGMENT.description = "Whenever you lose honor, the honor lost is doubled.\nThis is for characters that want to try and remain evil\nand want to quickly get down from having good honor.";

AUG_CURSED = openAura.augment:Register(AUGMENT);