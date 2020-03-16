--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Milk Jugs";
ITEM.cost = 6;
ITEM.model = "models/props_junk/garbage_milkcarton001a.mdl";
ITEM.weight = 1;
ITEM.useText = "Drink";
ITEM.classes = {CLASS_CATERER};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A jug filled with delicious milk.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData( "thirst", math.Clamp(player:GetCharacterData("thirst") - 75, 0, 100) );
	player:SetHealth( math.Clamp(player:Health() + 10, 0, 100) );
	
	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 600);
	player:BoostAttribute(self.name, ATB_STRENGTH, 2, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);