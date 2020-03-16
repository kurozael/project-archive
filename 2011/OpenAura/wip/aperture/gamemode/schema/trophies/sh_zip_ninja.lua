--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Zip Ninja";
TROPHY.image = "aperture/trophies/zipninja";
TROPHY.reward = 160;
TROPHY.maximum = 10;
TROPHY.description = "Use zip ties and succeed on ten characters.\nReceive a reward of 160 serums.";
TROPHY.unlockHeading = "%n the Zip Ninja";

TRO_ZIPNINJA = openAura.trophy:Register(TROPHY);