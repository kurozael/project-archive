--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Go Thermal";
TROPHY.image = "aperture/trophies/gothermal";
TROPHY.reward = 320;
TROPHY.maximum = 1;
TROPHY.description = "Turn on thermal implant for the first time.\nReceive a reward of 320 serums.";

TRO_GOTHERMAL = openAura.trophy:Register(TROPHY);