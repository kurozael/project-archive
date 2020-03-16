--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Devil Hunter";
TROPHY.image = "aperture/trophies/devilhunter";
TROPHY.reward = 320;
TROPHY.maximum = 20;
TROPHY.description = "Kill twenty characters who have evil karma.\nReceive a reward of 320 serums.";
TROPHY.unlockHeading = "%n the Devil Hunter";

TRO_DEVILHUNTER = openAura.trophy:Register(TROPHY);