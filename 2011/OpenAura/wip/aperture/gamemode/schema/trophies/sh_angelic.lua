--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Angelic";
TROPHY.image = "aperture/trophies/angelic";
TROPHY.reward = 80;
TROPHY.maximum = 1;
TROPHY.description = "Get the highest possible karma.\nReceive a reward of 80 serums.";
TROPHY.unlockHeading = "%n the Angel";

TRO_ANGELIC = openAura.trophy:Register(TROPHY);