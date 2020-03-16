--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Bounty Hunter";
VICTORY.image = "victories/bountyhunter";
VICTORY.reward = 240;
VICTORY.maximum = 10;
VICTORY.description = "Kill ten characters who have a bounty on their head.\nReceive a reward of 240 rations.";
VICTORY.unlockTitle = "Bounty Hunter %n";

VIC_BOUNTYHUNTER = openAura.victory:Register(VICTORY);