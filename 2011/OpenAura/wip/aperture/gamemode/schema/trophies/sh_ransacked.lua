--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Ransacked";
TROPHY.image = "aperture/trophies/ransacked";
TROPHY.reward = 160;
TROPHY.maximum = 1;
TROPHY.description = "Successfully loot $1500 from a corpse.\nReceive a reward of 160 serums.";
TROPHY.unlockHeading = "%n the Ransacker";

TRO_RANSACKED = openAura.trophy:Register(TROPHY);