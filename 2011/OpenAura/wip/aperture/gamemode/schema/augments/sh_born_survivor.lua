--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Born Survivor";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/bornsurvivor";
AUGMENT.karma = "evil";
AUGMENT.description = "When in critical condition, you cannot take damage from other characters.";

AUG_BORNSURVIVOR = openAura.augment:Register(AUGMENT);