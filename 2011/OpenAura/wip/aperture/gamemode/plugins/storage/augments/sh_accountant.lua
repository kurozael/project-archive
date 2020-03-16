--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Accountant";
AUGMENT.cost = 2400;
AUGMENT.image = "aperture/augments/accountant";
AUGMENT.karma = "good";
AUGMENT.description = "Your generators will put serums earned into your safebox.";

AUG_ACCOUNTANT = openAura.augment:Register(AUGMENT);