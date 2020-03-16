--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local TROPHY = {};

TROPHY.name = "Bulkbuyer";
TROPHY.image = "aperture/trophies/bulkbuyer";
TROPHY.reward = 160;
TROPHY.maximum = 10;
TROPHY.description = "Craft ten shipments of equipment.\nReceive a reward of 160 serums.";
TROPHY.unlockHeading = "%n the Crafter";

TRO_BULKBUYER = openAura.trophy:Register(TROPHY);