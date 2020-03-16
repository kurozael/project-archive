--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Flash Martyr";
AUGMENT.cost = 2000;
AUGMENT.image = "aperture/augments/flashmartyr";
AUGMENT.karma = "good";
AUGMENT.description = "When you are killed you will activate a flash grenade.\nYou do not need a flash grenade for this to work.";

AUG_FLASHMARTYR = openAura.augment:Register(AUGMENT);