--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Freeman";
VICTORY.image = "victories/freeman";
VICTORY.reward = 80;
VICTORY.maximum = 1;
VICTORY.description = "Be the one to buy a shipment of crowbars.\nReceive a reward of 80 rations.";
VICTORY.unlockTitle = "%n the Freeman";

VIC_FREEMAN = openAura.victory:Register(VICTORY);