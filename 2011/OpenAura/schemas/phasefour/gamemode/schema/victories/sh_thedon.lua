--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "The Don";
VICTORY.image = "victories/thedon";
VICTORY.reward = 240;
VICTORY.maximum = 10;
VICTORY.description = "Invite a total of ten people into your alliance.\nReceive a reward of 240 rations.";
VICTORY.unlockTitle = "%n the Don";

VIC_THEDON = openAura.victory:Register(VICTORY);