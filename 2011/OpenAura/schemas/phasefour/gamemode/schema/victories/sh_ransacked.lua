--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Ransacked";
VICTORY.image = "victories/ransacked";
VICTORY.reward = 160;
VICTORY.maximum = 1;
VICTORY.description = "Successfully loot $1500 from a corpse.\nReceive a reward of 160 rations.";
VICTORY.unlockTitle = "%n the Ransacker";

VIC_RANSACKED = openAura.victory:Register(VICTORY);