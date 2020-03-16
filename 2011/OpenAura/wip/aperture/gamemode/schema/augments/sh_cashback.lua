--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Cashback";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/cashback";
AUGMENT.karma = "good";
AUGMENT.description = "You can cash in items in your inventory for 25% of their original price.";

AUG_CASHBACK = openAura.augment:Register(AUGMENT);