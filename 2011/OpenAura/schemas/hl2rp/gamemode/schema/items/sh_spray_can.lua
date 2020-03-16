--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Spray Can";
ITEM.cost = 15;
ITEM.model = "models/sprayca2.mdl";
ITEM.weight = 1;
ITEM.access = "v";
ITEM.category = "Reusables";
ITEM.business = true;
ITEM.description = "A standard spray can filled with paint.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);