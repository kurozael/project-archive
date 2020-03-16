--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Block Busta";
TROPHY.image = "aperture/trophies/blockbusta";
TROPHY.reward = 160;
TROPHY.maximum = 10;
TROPHY.description = "Breach a total of ten doors.\nReceive a reward of 160 serums.";
TROPHY.unlockHeading = "%n the Breacher";

TRO_BLOCKBUSTER = openAura.trophy:Register(TROPHY);