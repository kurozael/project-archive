--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Thermal Vision";
	ITEM.cost = 4000;
	ITEM.model = "models/gibs/shield_scanner_gib1.mdl";
	ITEM.weight = 1.5;
	ITEM.category = "Reusables";
	ITEM.uniqueID = "cw_thermalvision";
	ITEM.business = true;
	ITEM.isFakeWeapon = true;
	ITEM.isMeleeWeapon = true;
	ITEM.description = "An device which allows you to see stealthed humans.\nUsing this device will drain your stamina.";
Clockwork.item:Register(ITEM);