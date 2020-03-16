--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Mike Tyson";
TROPHY.image = "aperture/trophies/miketyson";
TROPHY.reward = 960;
TROPHY.maximum = 1;
TROPHY.description = "Get 100% strength without using boosts.\nReceive a reward of 960 serums.";
TROPHY.unlockHeading = "%n aka Mike Tyson";

TRO_MIKETYSON = openAura.trophy:Register(TROPHY);