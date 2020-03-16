--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Blood Donor";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/blooddonor";
AUGMENT.karma = "good";
AUGMENT.description = "You will receive 10% health back from damage you do with weapons.\nThis augment only applies when attacking evil characters.";

AUG_BLOODDONOR = openAura.augment:Register(AUGMENT);