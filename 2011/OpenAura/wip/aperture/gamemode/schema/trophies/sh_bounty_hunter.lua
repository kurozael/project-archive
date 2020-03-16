--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Bounty Hunter";
TROPHY.image = "aperture/trophies/bountyhunter";
TROPHY.reward = 240;
TROPHY.maximum = 10;
TROPHY.description = "Kill ten characters who have a bounty on their head.\nReceive a reward of 240 serums.";
TROPHY.unlockHeading = "Bounty Hunter %n";

TRO_BOUNTYHUNTER = openAura.trophy:Register(TROPHY);