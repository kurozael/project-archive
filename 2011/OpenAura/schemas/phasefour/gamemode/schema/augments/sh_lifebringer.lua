--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Lifebringer";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/lifebringer";
AUGMENT.honor = "good";
AUGMENT.description = "Grants you the ability to bring corpses back to life.\nWhen used, you donate half of your health to the target.";

AUG_LIFEBRINGER = openAura.augment:Register(AUGMENT);