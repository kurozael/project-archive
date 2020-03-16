--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Hooligan";
VICTORY.image = "victories/hooligan";
VICTORY.reward = 160;
VICTORY.maximum = 50;
VICTORY.description = "Destroy fifty of other character's props.\nReceive a reward of 160 rations.";
VICTORY.unlockTitle = "%n the Hooligan";

VIC_HOOLIGAN = openAura.victory:Register(VICTORY);