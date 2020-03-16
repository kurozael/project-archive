--[[
	© 2017 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "CDF MRE: Bubblegum";
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Eat";
ITEM.uniqueID = "bubble_gum"
ITEM.category = "Consumables"
ITEM.description = "Some bubblegum, it has the CDF logo imprinted on it, spearmint flavor.";
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav";
ITEM.HungerAmount = 1;
ITEM.EnergyAmount = 1;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity) end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);