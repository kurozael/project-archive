--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "5.56x45mm Rounds";
	ITEM.cost = 210;
	ITEM.model = "models/items/boxmrounds.mdl";
	ITEM.weight = 2;
	ITEM.uniqueID = "ammo_smg1";
	ITEM.business = true;
	ITEM.ammoClass = "smg1";
	ITEM.ammoAmount = 90;
	ITEM.description = "A large green container with 5.56x45mm on the side.";
Clockwork.item:Register(ITEM);