--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Fiddy Acro";
VICTORY.image = "victories/fiddyacro";
VICTORY.reward = 720;
VICTORY.maximum = 1;
VICTORY.description = "Get 50% acrobatics without using boosts.\nReceive a reward of 720 rations.";
VICTORY.unlockTitle = "Acrobatic %n";

VIC_FIDDYACRO = openAura.victory:Register(VICTORY);