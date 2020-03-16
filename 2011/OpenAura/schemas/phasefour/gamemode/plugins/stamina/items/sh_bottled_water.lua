--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Bottled Water";
ITEM.cost = 50;
ITEM.model = "models/props_junk/glassbottle01a.mdl";
ITEM.plural = "Bottled Waters";
ITEM.weight = 0.5;
ITEM.useText = "Drink";
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A clear bottle, the liquid inside looks dirty.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 10, 0, 100) );
	player:BoostAttribute(self.name, ATB_AGILITY, 4, 600);
	player:BoostAttribute(self.name, ATB_STAMINA, 4, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);