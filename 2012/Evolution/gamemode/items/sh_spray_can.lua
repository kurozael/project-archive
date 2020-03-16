--[[
	� 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Spray Can";
ITEM.cost = (100 * 0.5);
ITEM.batch = 1;
ITEM.model = "models/sprayca2.mdl";
ITEM.weight = 1;
ITEM.category = "Equipment"
ITEM.business = true;
ITEM.description = "A standard spray can filled with paint.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);