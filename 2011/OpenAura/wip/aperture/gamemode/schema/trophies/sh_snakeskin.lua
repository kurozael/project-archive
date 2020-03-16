--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Snakeskin";
TROPHY.image = "aperture/trophies/snakeskin";
TROPHY.reward = 960;
TROPHY.maximum = 1;
TROPHY.description = "Get 100% endurance without using boosts.\nReceive a reward of 960 serums.";
TROPHY.unlockHeading = "%n the Endurable";

TRO_SNAKESKIN = openAura.trophy:Register(TROPHY);