--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Bottled Water";
ITEM.model = "models/props_junk/glassbottle01a.mdl";
ITEM.plural = "Bottled Waters";
ITEM.weight = 0.5;
ITEM.useText = "Drink";
ITEM.category = "Consumables"
ITEM.description = "A clear bottle, the liquid inside looks dirty.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 8, 0, 100) );
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);