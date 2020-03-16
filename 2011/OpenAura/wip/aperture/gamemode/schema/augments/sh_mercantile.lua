--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Mercantile";
AUGMENT.cost = 3000;
AUGMENT.image = "aperture/augments/mercantile";
AUGMENT.karma = "perma";
AUGMENT.description = "All shipments will cost you 10% less to purchase.";

AUG_MERCANTILE = openAura.augment:Register(AUGMENT);