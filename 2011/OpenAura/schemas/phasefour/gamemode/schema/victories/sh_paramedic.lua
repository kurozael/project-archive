--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Paramedic";
VICTORY.image = "victories/paramedic";
VICTORY.reward = 160;
VICTORY.maximum = 20;
VICTORY.description = "Revive a total of ten characters.\nReceive a reward of 160 rations.";
VICTORY.unlockTitle = "Paramedic %n";

VIC_PARAMEDIC = openAura.victory:Register(VICTORY);