--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Drunkard";
TROPHY.image = "aperture/trophies/drunkard";
TROPHY.reward = 80;
TROPHY.maximum = 10;
TROPHY.description = "Drink ten bottles of any alcoholic drink.\nReceive a reward of 80 serums.";
TROPHY.unlockHeading = "%n the Drunkard";

TRO_DRUNKARD = openAura.trophy:Register(TROPHY);