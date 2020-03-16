--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Quickhands";
VICTORY.image = "victories/quickhands";
VICTORY.reward = 960;
VICTORY.maximum = 1;
VICTORY.description = "Get 100% dexterity without using boosts.\nReceive a reward of 960 rations.";
VICTORY.unlockTitle = "%n with Quick Hands";

VIC_QUICKHANDS = openAura.victory:Register(VICTORY);