
--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "RPG Missile";
ITEM.cost = 80;
ITEM.model = "models/weapons/w_missile_launch.mdl";
ITEM.access = "V";
ITEM.weight = 2;
ITEM.uniqueID = "ammo_rpg_round";
ITEM.business = true;
ITEM.ammoClass = "rpg_round";
ITEM.ammoAmount = 1;
ITEM.description = "A orange and white colored rocket, what would happen if I dropped this?";

openAura.item:Register(ITEM);