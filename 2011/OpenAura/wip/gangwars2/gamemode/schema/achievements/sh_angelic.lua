--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Angelic";
VICTORY.image = "achievements/angelic";
VICTORY.reward = 80;
VICTORY.maximum = 1;
VICTORY.description = "Get the highest possible honor.\nReceive a reward of 80 drugs.";
VICTORY.unlockTitle = "%n the Angel";

ACH_ANGELIC = openAura.achievement:Register(VICTORY);