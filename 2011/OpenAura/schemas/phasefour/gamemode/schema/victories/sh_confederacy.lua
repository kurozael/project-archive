--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Confederacy";
VICTORY.image = "victories/confederacy";
VICTORY.reward = 400;
VICTORY.maximum = 20;
VICTORY.description = "Invite a total of twenty people into your alliance.\nReceive a reward of 400 rations.";
VICTORY.unlockTitle = "%n of the Confederacy";

VIC_CONFEDERACY = openAura.victory:Register(VICTORY);