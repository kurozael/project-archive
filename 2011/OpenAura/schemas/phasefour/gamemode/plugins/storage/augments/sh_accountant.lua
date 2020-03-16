--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Accountant";
AUGMENT.cost = 2400;
AUGMENT.image = "augments/accountant";
AUGMENT.honor = "good";
AUGMENT.description = "Your generators will put rations earned into your safebox.";

AUG_ACCOUNTANT = openAura.augment:Register(AUGMENT);