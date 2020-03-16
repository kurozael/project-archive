--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Intervention";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/intervention";
AUGMENT.karma = "good";
AUGMENT.description = "Your Serum Guarders give your generators double protection.";

AUG_INTERVENTION = openAura.augment:Register(AUGMENT);