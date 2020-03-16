--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Tear Martyr";
AUGMENT.cost = 2000;
AUGMENT.image = "aperture/augments/tearmartyr";
AUGMENT.karma = "evil";
AUGMENT.description = "When you are killed you will activate a tear gas grenade.\nYou do not need a tear gas grenade for this to work.";

AUG_TEARMARTYR = openAura.augment:Register(AUGMENT);