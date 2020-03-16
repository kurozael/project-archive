--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Bleach";
ITEM.model = "models/props_junk/garbage_plasticbottle001a.mdl";
ITEM.plural = "Bleaches";
ITEM.weight = 0.8;
ITEM.useText = "Drink";
ITEM.description = "A bottle of bleach, this is dangerous stuff.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:TakeDamage(25, player, player);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);