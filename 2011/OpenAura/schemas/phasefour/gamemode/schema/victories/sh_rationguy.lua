--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Ration Guy";
VICTORY.image = "victories/rationguy";
VICTORY.reward = 80;
VICTORY.maximum = 1;
VICTORY.description = "Get hold of over two hundred rations.\nReceive a reward of 80 rations.";
VICTORY.unlockTitle = "%n the Ration Guy";

VIC_CODEKGUY = openAura.victory:Register(VICTORY);