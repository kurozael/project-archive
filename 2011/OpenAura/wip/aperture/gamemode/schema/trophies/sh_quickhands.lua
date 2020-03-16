--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Quickhands";
TROPHY.image = "aperture/trophies/quickhands";
TROPHY.reward = 960;
TROPHY.maximum = 1;
TROPHY.description = "Get 100% dexterity without using boosts.\nReceive a reward of 960 serums.";
TROPHY.unlockHeading = "%n with Quick Hands";

TRO_QUICKHANDS = openAura.trophy:Register(TROPHY);