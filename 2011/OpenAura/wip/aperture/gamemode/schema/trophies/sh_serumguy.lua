--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Serum Guy";
TROPHY.image = "aperture/trophies/serumguy";
TROPHY.reward = 80;
TROPHY.maximum = 1;
TROPHY.description = "Get hold of over two hundred serums.\nReceive a reward of 80 serums.";
TROPHY.unlockHeading = "%n the Serum Guy";

TRO_CODEKGUY = openAura.trophy:Register(TROPHY);