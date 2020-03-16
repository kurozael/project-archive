--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Milk Jugs";
ITEM.cost = 6;
ITEM.model = "models/props_junk/garbage_milkcarton001a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.35;
ITEM.access = "T";
ITEM.business = true;
ITEM.useText = "Drink";
ITEM.business = true;
ITEM.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"};
ITEM.category = "Consumables";
ITEM.description = "A jug filled with delicious milk.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 8, 0, 100) );
	player:UpdateInventory("empty_milk_jug", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);