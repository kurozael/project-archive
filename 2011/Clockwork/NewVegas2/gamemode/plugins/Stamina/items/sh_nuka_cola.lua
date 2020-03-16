--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Nuka Cola";
ITEM.cost = 8;
ITEM.model = "models/nukacola/nukac1.mdl";
ITEM.batch = 1;
ITEM.weight = 0.25;
ITEM.access = "T";
ITEM.useText = "Drink";
ITEM.business = true;
ITEM.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"};
ITEM.category = "Consumables";
ITEM.description = "A clear bottle, the liquid inside looks lovely.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 12, 0, 100));
	player:GiveItem("empty_nuka_cola", true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);