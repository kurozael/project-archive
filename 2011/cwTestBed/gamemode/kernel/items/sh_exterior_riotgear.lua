--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = 4000;
ITEM.name = "Exterior Riotgear";
ITEM.weight = 2.5;
ITEM.business = true;
ITEM.armorScale = 0.3;
ITEM.replacement = "models/riot_ex2.mdl";
ITEM.description = "A dark gray outfit with a mandatory skull mask.";

Clockwork.item:Register(ITEM);