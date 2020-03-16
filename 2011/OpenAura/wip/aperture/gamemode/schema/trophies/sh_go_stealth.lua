--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Go Stealth";
TROPHY.image = "aperture/trophies/gostealth";
TROPHY.reward = 320;
TROPHY.maximum = 1;
TROPHY.description = "Turn on the stealth implant for the first time.\nReceive a reward of 320 serums.";

TRO_GOSTEALTH = openAura.trophy:Register(TROPHY);