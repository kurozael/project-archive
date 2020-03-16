--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Go Thermal";
VICTORY.image = "victories/gothermal";
VICTORY.reward = 320;
VICTORY.maximum = 1;
VICTORY.description = "Turn on the thermal implant for the first time.\nReceive a reward of 320 rations.";

VIC_GOTHERMAL = openAura.victory:Register(VICTORY);