--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Mutilator";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/mutilator";
AUGMENT.karma = "evil";
AUGMENT.description = "Grants you the ability to mutilate corpses for health.";

AUG_MUTILATOR = openAura.augment:Register(AUGMENT);