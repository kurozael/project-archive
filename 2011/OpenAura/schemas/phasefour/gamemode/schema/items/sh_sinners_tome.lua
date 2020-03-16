--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Sinner Tome";
ITEM.cost = 100;
ITEM.model = "models/props_lab/binderredlabel.mdl";
ITEM.batch = 1;
ITEM.weight = 0.5;
ITEM.useText = "Read";
ITEM.uniqueID = "sinners_tome";
ITEM.category = "Tomes"
ITEM.business = true;
ITEM.description = "An old dusty book with foreign writing enscribed onto it.\nReading this tome will deduct ten honor from you.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:HandleHonor(-10);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);