--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Fiddy Acro";
TROPHY.image = "aperture/trophies/fiddyacro";
TROPHY.reward = 720;
TROPHY.maximum = 1;
TROPHY.description = "Get 50% acrobatics without using boosts.\nReceive a reward of 720 serums.";
TROPHY.unlockHeading = "Acrobatic %n";

TRO_FIDDYACRO = openAura.trophy:Register(TROPHY);