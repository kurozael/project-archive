--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Incarnate";
VICTORY.image = "victories/incarnate";
VICTORY.reward = 80;
VICTORY.maximum = 1;
VICTORY.description = "Get the lowest possible honor.\nReceive a reward of 80 rations.";
VICTORY.unlockTitle = "%n the Incarnate";

VIC_INCARNATE = openAura.victory:Register(VICTORY);