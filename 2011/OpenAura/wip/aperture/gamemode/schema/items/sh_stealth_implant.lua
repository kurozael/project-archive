--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Stealth Implant";
ITEM.cost = 5000;
ITEM.model = "models/gibs/shield_scanner_gib1.mdl";
ITEM.weight = 1.5;
ITEM.category = "Implants";
ITEM.uniqueID = "aura_stealthcamo";
ITEM.business = true;
ITEM.fakeWeapon = true;
ITEM.meleeWeapon = true;
ITEM.description = "An implant to allow you to become temporarily invisible.\nUsing this implant will drain your stamina.";

openAura.item:Register(ITEM);