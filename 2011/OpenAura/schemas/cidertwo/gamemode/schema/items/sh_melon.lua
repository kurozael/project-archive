--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Melon";
ITEM.cost = 8;
ITEM.model = "models/props_junk/watermelon01.mdl";
ITEM.weight = 1;
ITEM.useText = "Eat";
ITEM.classes = {CLASS_CATERER};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A green fruit, it has a hard outer shell.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData( "hunger", math.Clamp(player:GetCharacterData("hunger") - 50, 0, 100) );
	player:SetCharacterData( "thirst", math.Clamp(player:GetCharacterData("thirst") - 50, 0, 100) );
	player:SetHealth( math.Clamp(player:Health() + 10, 0, 100) );
	
	player:BoostAttribute(self.name, ATB_ACROBATICS, 2, 600);
	player:BoostAttribute(self.name, ATB_AGILITY, 2, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);