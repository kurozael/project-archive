--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Bulkbuyer";
VICTORY.image = "victories/bulkbuyer";
VICTORY.reward = 160;
VICTORY.maximum = 10;
VICTORY.description = "Craft ten shipments of equipment.\nReceive a reward of 160 rations.";
VICTORY.unlockTitle = "%n the Crafter";

VIC_BULKBUYER = openAura.victory:Register(VICTORY);