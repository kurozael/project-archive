--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Test Subject";
VICTORY.image = "victories/testsubject";
VICTORY.reward = 240;
VICTORY.maximum = 5;
VICTORY.description = "Purchase a total of five augments.\nReceive a reward of 240 rations.";
VICTORY.unlockTitle = "%n the Test Subject";

VIC_TESTSUBJECT = openAura.victory:Register(VICTORY);