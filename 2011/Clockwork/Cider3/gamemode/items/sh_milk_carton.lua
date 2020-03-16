--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Milk Carton";
ITEM.cost = 4;
ITEM.model = "models/props_junk/garbage_milkcarton002a.mdl";
ITEM.weight = 0.8;
ITEM.useText = "Drink";
ITEM.classes = {CLASS_CATERER};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A carton filled with delicious milk.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("Thirst", math.Clamp(player:GetCharacterData("Thirst") - 50, 0, 100));
	player:SetHealth(math.Clamp(player:Health() + 5, 0, 100));
	
	player:BoostAttribute(self("name"), ATB_ENDURANCE, 1, 600);
	player:BoostAttribute(self("name"), ATB_STRENGTH, 1, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);