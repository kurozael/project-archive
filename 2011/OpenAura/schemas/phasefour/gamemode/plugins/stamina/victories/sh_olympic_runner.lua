--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Olympic Runner";
VICTORY.image = "victories/olympicrunner";
VICTORY.reward = 960;
VICTORY.maximum = 1;
VICTORY.description = "Get 100% stamina without using boosts.\nReceive a reward of 960 rations.";

VIC_OLYMPICRUNNER = openAura.victory:Register(VICTORY);