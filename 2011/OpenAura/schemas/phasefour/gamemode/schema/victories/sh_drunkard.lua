--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Drunkard";
VICTORY.image = "victories/drunkard";
VICTORY.reward = 80;
VICTORY.maximum = 10;
VICTORY.description = "Drink ten bottles of any alcoholic drink.\nReceive a reward of 80 rations.";
VICTORY.unlockTitle = "%n the Drunkard";

VIC_DRUNKARD = openAura.victory:Register(VICTORY);