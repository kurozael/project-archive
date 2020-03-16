--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Stealth Camo";
	ITEM.cost = 5000;
	ITEM.model = "models/gibs/shield_scanner_gib1.mdl";
	ITEM.weight = 1.5;
	ITEM.category = "Reusables";
	ITEM.uniqueID = "cw_stealthcamo";
	ITEM.business = true;
	ITEM.isFakeWeapon = true;
	ITEM.isMeleeWeapon = true;
	ITEM.description = "A dervice which allow you to become temporarily invisible.\nUsing this device will drain your stamina.";
Clockwork.item:Register(ITEM);