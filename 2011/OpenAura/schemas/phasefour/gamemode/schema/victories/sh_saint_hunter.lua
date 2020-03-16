--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Saint Hunter";
VICTORY.image = "victories/sainthunter";
VICTORY.reward = 320;
VICTORY.maximum = 20;
VICTORY.description = "Kill twenty characters who have good honor.\nReceive a reward of 320 rations.";
VICTORY.unlockTitle = "%n the Saint Hunter";

VIC_SAINTHUNTER = openAura.victory:Register(VICTORY);