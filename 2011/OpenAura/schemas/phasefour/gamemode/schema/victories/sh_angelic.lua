--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Angelic";
VICTORY.image = "victories/angelic";
VICTORY.reward = 80;
VICTORY.maximum = 1;
VICTORY.description = "Get the highest possible honor.\nReceive a reward of 80 rations.";
VICTORY.unlockTitle = "%n the Angel";

VIC_ANGELIC = openAura.victory:Register(VICTORY);