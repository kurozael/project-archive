--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Saint Tome";
ITEM.cost = 200;
ITEM.model = "models/props_lab/binderbluelabel.mdl";
ITEM.batch = 1;
ITEM.weight = 0.5;
ITEM.useText = "Read";
ITEM.category = "Tomes"
ITEM.uniqueID = "saints_tome";
ITEM.business = true;
ITEM.description = "An old dusty book with foreign writing enscribed onto it.\nReading this tome will give you ten karma.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:HandleKarma(10);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);