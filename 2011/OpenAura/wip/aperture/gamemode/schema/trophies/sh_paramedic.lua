--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Paramedic";
TROPHY.image = "aperture/trophies/paramedic";
TROPHY.reward = 160;
TROPHY.maximum = 20;
TROPHY.description = "Revive a total of ten characters.\nReceive a reward of 160 serums.";
TROPHY.unlockHeading = "Paramedic %n";

TRO_PARAMEDIC = openAura.trophy:Register(TROPHY);