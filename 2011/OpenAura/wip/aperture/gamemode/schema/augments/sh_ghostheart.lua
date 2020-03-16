--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Ghostheart";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/ghostheart";
AUGMENT.karma = "good";
AUGMENT.description = "You will not show on other character's heartbeat sensors.";

AUG_GHOSTHEART = openAura.augment:Register(AUGMENT);