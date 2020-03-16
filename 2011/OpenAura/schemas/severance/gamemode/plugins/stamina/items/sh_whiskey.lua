--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "alcohol_base";
ITEM.name = "Whiskey";
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.weight = 1.2;
ITEM.attributes = {Stamina = 4};
ITEM.description = "A brown colored whiskey bottle, be careful!";

openAura.item:Register(ITEM);