--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Incarnate";
TROPHY.image = "aperture/trophies/incarnate";
TROPHY.reward = 80;
TROPHY.maximum = 1;
TROPHY.description = "Get the lowest possible karma.\nReceive a reward of 80 serums.";
TROPHY.unlockHeading = "%n the Incarnate";

TRO_INCARNATE = openAura.trophy:Register(TROPHY);