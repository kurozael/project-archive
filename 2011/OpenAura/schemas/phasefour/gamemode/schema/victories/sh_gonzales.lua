--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Gonzales";
VICTORY.image = "victories/gonzales";
VICTORY.reward = 960;
VICTORY.maximum = 1;
VICTORY.description = "Get 100% agility without using boosts.\nReceive a reward of 960 rations.";
VICTORY.unlockTitle = "Speedy %n";

VIC_GONZALES = openAura.victory:Register(VICTORY);