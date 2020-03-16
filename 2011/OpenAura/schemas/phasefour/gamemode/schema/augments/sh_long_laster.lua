--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Long Laster";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/longlaster";
AUGMENT.honor = "good";
AUGMENT.description = "When in critical condition, you will survive for two times as long.\nIf you have the Adrenaline augment, you will revive two times as quick.";

AUG_LONGLASTER = openAura.augment:Register(AUGMENT);