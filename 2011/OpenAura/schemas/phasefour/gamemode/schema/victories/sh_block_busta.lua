--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Block Busta";
VICTORY.image = "victories/blockbusta";
VICTORY.reward = 160;
VICTORY.maximum = 10;
VICTORY.description = "Breach a total of ten doors.\nReceive a reward of 160 rations.";
VICTORY.unlockTitle = "%n the Breacher";

VIC_BLOCKBUSTER = openAura.victory:Register(VICTORY);