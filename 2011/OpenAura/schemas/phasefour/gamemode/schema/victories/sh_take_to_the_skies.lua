--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Take To The Skies";
VICTORY.image = "victories/taketotheskies";
VICTORY.reward = 320;
VICTORY.maximum = 10;
VICTORY.description = "Take to the skies in a jetpack for ten seconds.\nReceive a reward of 320 rations.";
VICTORY.unlockTitle = "The Flying %n";

VIC_TAKETOTHESKIES = openAura.victory:Register(VICTORY);