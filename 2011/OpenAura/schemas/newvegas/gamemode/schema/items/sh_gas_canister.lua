--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "junk_base";
ITEM.name = "Gas Canister";
ITEM.worth = 10;
ITEM.model = "models/props_junk/gascan001a.mdl";
ITEM.weight = 1;
ITEM.description = "A red can filled with gasoline.";

openAura.item:Register(ITEM);