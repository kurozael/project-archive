--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Zip Ninja";
VICTORY.image = "victories/zipninja";
VICTORY.reward = 160;
VICTORY.maximum = 10;
VICTORY.description = "Use zip ties and succeed on ten characters.\nReceive a reward of 160 rations.";
VICTORY.unlockTitle = "%n the Zip Ninja";

VIC_ZIPNINJA = openAura.victory:Register(VICTORY);