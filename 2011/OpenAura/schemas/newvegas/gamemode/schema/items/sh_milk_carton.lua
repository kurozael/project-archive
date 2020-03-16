--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Milk Carton";
ITEM.cost = 4;
ITEM.model = "models/props_junk/garbage_milkcarton002a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.25;
ITEM.access = "T";
ITEM.business = true;
ITEM.useText = "Drink";
ITEM.business = true;
ITEM.category = "Consumables";
ITEM.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"};
ITEM.description = "A carton filled with delicious milk.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 4, 0, 100) );
	player:UpdateInventory("empty_milk_carton", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);