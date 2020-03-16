--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Mike Tyson";
VICTORY.image = "victories/miketyson";
VICTORY.reward = 960;
VICTORY.maximum = 1;
VICTORY.description = "Get 100% strength without using boosts.\nReceive a reward of 960 rations.";
VICTORY.unlockTitle = "%n aka Mike Tyson";

VIC_MIKETYSON = openAura.victory:Register(VICTORY);