--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Hollow Point";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/hollowpoint";
AUGMENT.karma = "evil";
AUGMENT.description = "You will deal 10% more damage with weapons.\nThis augment only applies when attacking good characters.";

AUG_HOLLOWPOINT = openAura.augment:Register(AUGMENT);