--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Devil Hunter";
VICTORY.image = "victories/devilhunter";
VICTORY.reward = 320;
VICTORY.maximum = 20;
VICTORY.description = "Kill twenty characters who have evil honor.\nReceive a reward of 320 rations.";
VICTORY.unlockTitle = "%n the Devil Hunter";

VIC_DEVILHUNTER = openAura.victory:Register(VICTORY);