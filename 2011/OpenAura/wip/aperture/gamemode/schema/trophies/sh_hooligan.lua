--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Hooligan";
TROPHY.image = "aperture/trophies/hooligan";
TROPHY.reward = 160;
TROPHY.maximum = 50;
TROPHY.description = "Destroy fifty of other character's props.\nReceive a reward of 160 serums.";
TROPHY.unlockHeading = "%n the Hooligan";

TRO_HOOLIGAN = openAura.trophy:Register(TROPHY);