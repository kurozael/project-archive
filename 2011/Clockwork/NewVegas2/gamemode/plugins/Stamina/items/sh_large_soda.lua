--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Large Soda";
ITEM.cost = 8;
ITEM.model = "models/props_junk/garbage_plasticbottle003a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.5;
ITEM.access = "T";
ITEM.useText = "Drink";
ITEM.business = true;
ITEM.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"};
ITEM.category = "Consumables";
ITEM.description = "A plastic bottle, it's fairly big and filled with liquid.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 8, 0, player:GetMaxHealth()));
	player:GiveItem("empty_soda_bottle", true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);