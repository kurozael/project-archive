--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Augment King";
TROPHY.image = "aperture/trophies/augmentking";
TROPHY.reward = 240;
TROPHY.maximum = 5;
TROPHY.description = "Purchase a total of five augments.\nReceive a reward of 240 serums.";
TROPHY.unlockHeading = "%n the Augment King";

TRO_AUGMENTKING = openAura.trophy:Register(TROPHY);