--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "The Don";
TROPHY.image = "aperture/trophies/thedon";
TROPHY.reward = 240;
TROPHY.maximum = 10;
TROPHY.description = "Invite a total of ten people into your guild.\nReceive a reward of 240 serums.";
TROPHY.unlockHeading = "%n the Don";

TRO_THEDON = openAura.trophy:Register(TROPHY);