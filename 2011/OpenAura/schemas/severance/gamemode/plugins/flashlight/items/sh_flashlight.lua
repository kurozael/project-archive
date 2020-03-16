--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Flashlight";
ITEM.model = "models/lagmite/lagmite.mdl";
ITEM.weight = 0.8;
ITEM.category = "Reusables";
ITEM.uniqueID = "aura_flashlight";
ITEM.fakeWeapon = true;
ITEM.meleeWeapon = true;
ITEM.description = "A black flashlight with Maglite printed on the side.";

openAura.item:Register(ITEM);