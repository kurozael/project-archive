--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Large Soda";
ITEM.cost = 6;
ITEM.model = "models/props_junk/garbage_plasticbottle003a.mdl";
ITEM.weight = 1.5;
ITEM.useText = "Drink";
ITEM.classes = {CLASS_CATERER};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A plastic bottle, it's fairly big and filled with liquid.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("Thirst", math.Clamp(player:GetCharacterData("Thirst") - 75, 0, 100));
	player:SetCharacterData("Stamina", 100);
	player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()));
	
	player:BoostAttribute(self("name"), ATB_AGILITY, 5, 600);
	player:BoostAttribute(self("name"), ATB_STAMINA, 5, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);