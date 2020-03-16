--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Take To The Skies";
TROPHY.image = "aperture/trophies/taketotheskies";
TROPHY.reward = 320;
TROPHY.maximum = 10;
TROPHY.description = "Take to the skies in a jetpack for ten seconds.\nReceive a reward of 320 serums.";
TROPHY.unlockHeading = "The Flying %n";

TRO_TAKETOTHESKIES = openAura.trophy:Register(TROPHY);