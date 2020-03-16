--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Saint Hunter";
TROPHY.image = "aperture/trophies/sainthunter";
TROPHY.reward = 320;
TROPHY.maximum = 20;
TROPHY.description = "Kill twenty characters who have good karma.\nReceive a reward of 320 serums.";
TROPHY.unlockHeading = "%n the Saint Hunter";

TRO_SAINTHUNTER = openAura.trophy:Register(TROPHY);