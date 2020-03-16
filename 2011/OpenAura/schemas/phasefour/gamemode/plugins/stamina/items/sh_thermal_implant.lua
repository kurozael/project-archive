--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Thermal Implant";
ITEM.cost = 4000;
ITEM.model = "models/gibs/shield_scanner_gib1.mdl";
ITEM.weight = 1.5;
ITEM.category = "Implants";
ITEM.uniqueID = "aura_thermalvision";
ITEM.business = true;
ITEM.fakeWeapon = true;
ITEM.meleeWeapon = true;
ITEM.description = "An implant which allows you to see stealthed humans.\nUsing this implant will drain your stamina.";

openAura.item:Register(ITEM);