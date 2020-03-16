--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Flashlight";
	ITEM.model = "models/lagmite/lagmite.mdl";
	ITEM.weight = 0.8;
	ITEM.category = "Reusables";
	ITEM.uniqueID = "cw_flashlight";
	ITEM.isFakeWeapon = true;
	ITEM.isMeleeWeapon = true;
	ITEM.description = "A black flashlight with Maglite printed on the side.";
Clockwork.item:Register(ITEM);