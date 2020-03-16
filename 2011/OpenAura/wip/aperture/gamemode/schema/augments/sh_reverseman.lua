--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Reverseman";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/reverseman";
AUGMENT.karma = "evil";
AUGMENT.description = "Your Door Guarders will damage characters that try to shoot your doors open.";

AUG_REVERSEMAN = openAura.augment:Register(AUGMENT);