--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Sharp Shooter";
TROPHY.image = "aperture/trophies/sharpshooter";
TROPHY.reward = 960;
TROPHY.maximum = 1;
TROPHY.description = "Get 100% accuracy without using boosts.\nReceive a reward of 960 serums.";
TROPHY.unlockHeading = "%n the Sharp Shooter";

TRO_SHARPSHOOTER = openAura.trophy:Register(TROPHY);