--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Human Meat";
ITEM.model = "models/Gibs/Antlion_gib_small_2.mdl";
ITEM.weight = 0.35;
ITEM.plural = "Human Meat";
ITEM.useText = "Eat";
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav";
ITEM.category = "Consumables"
ITEM.isRareItem = true;
ITEM.description = "Meat ripped from the body of a human, it smells disgusting.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 8, 0, 100) );
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when the item entity has spawned.
function ITEM:OnEntitySpawned(entity)
	entity:SetMaterial("models/flesh");
end;

openAura.item:Register(ITEM);