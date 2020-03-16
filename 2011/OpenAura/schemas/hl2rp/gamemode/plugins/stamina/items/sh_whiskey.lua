--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "alcohol_base";
ITEM.name = "Whiskey";
ITEM.cost = 6;
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.weight = 1.2;
ITEM.access = "v";
ITEM.business = true;
ITEM.attributes = {Stamina = 2};
ITEM.description = "A brown colored whiskey bottle, be careful!";

openAura.item:Register(ITEM);