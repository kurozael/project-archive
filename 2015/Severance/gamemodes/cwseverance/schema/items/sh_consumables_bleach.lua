--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Bleach";
ITEM.model = "models/props_junk/garbage_plasticbottle001a.mdl";
ITEM.weight = 0.8;
ITEM.useText = "Drink";
ITEM.category = "Consumables"
ITEM.description = "A bottle of bleach, this is dangerous stuff.";
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav";
ITEM.EnergyAmount = -60
ITEM.ThirstAmount = 1 --Heh.

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:TakeDamage(25, player, player);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);