--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Freeman";
TROPHY.image = "aperture/trophies/freeman";
TROPHY.reward = 80;
TROPHY.maximum = 1;
TROPHY.description = "Be the one to buy a shipment of crowbars.\nReceive a reward of 80 serums.";
TROPHY.unlockHeading = "%n the Freeman";

TRO_FREEMAN = openAura.trophy:Register(TROPHY);