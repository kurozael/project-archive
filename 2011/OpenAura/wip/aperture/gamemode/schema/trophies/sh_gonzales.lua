--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Gonzales";
TROPHY.image = "aperture/trophies/gonzales";
TROPHY.reward = 960;
TROPHY.maximum = 1;
TROPHY.description = "Get 100% agility without using boosts.\nReceive a reward of 960 serums.";
TROPHY.unlockHeading = "Speedy %n";

TRO_GONZALES = openAura.trophy:Register(TROPHY);