--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Olympic Runner";
TROPHY.image = "aperture/trophies/olympicrunner";
TROPHY.reward = 960;
TROPHY.maximum = 1;
TROPHY.description = "Get 100% stamina without using boosts.\nReceive a reward of 960 serums.";

TRO_OLYMPICRUNNER = openAura.trophy:Register(TROPHY);