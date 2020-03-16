--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Bully Victim";
TROPHY.image = "aperture/trophies/bullyvictim";
TROPHY.reward = 160;
TROPHY.maximum = 10;
TROPHY.description = "Get killed by other players ten times.\nReceive a reward of 160 serums.";
TROPHY.unlockHeading = "%n the Bully Victim";

TRO_BULLYVICTIM = openAura.trophy:Register(TROPHY);