--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Confederacy";
TROPHY.image = "aperture/trophies/confederacy";
TROPHY.reward = 400;
TROPHY.maximum = 20;
TROPHY.description = "Invite a total of twenty people into your guild.\nReceive a reward of 400 serums.";
TROPHY.unlockHeading = "%n of the Confederacy";

TRO_CONFEDERACY = openAura.trophy:Register(TROPHY);