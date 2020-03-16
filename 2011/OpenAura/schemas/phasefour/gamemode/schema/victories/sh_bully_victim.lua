--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local VICTORY = {};

VICTORY.name = "Bully Victim";
VICTORY.image = "victories/bullyvictim";
VICTORY.reward = 160;
VICTORY.maximum = 10;
VICTORY.description = "Get killed by other players ten times.\nReceive a reward of 160 rations.";
VICTORY.unlockTitle = "%n the Bully Victim";

VIC_BULLYVICTIM = openAura.victory:Register(VICTORY);