--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local AUGMENT = {};

AUGMENT = {};
AUGMENT.name = "Gunsmith";
AUGMENT.cost = 3000;
AUGMENT.image = "augments/gunsmith";
AUGMENT.honor = "perma";
AUGMENT.description = "With this augment you will be able to purchase the best weapons and ammo.";

AUG_GUNSMITH = openAura.augment:Register(AUGMENT);