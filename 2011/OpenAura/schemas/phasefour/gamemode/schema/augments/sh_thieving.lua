--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Thieving";
AUGMENT.cost = 2000;
AUGMENT.image = "augments/thieving";
AUGMENT.honor = "evil";
AUGMENT.description = "Your Ration Printer will produce an extra $150 an hour.";

AUG_THIEVING = openAura.augment:Register(AUGMENT);