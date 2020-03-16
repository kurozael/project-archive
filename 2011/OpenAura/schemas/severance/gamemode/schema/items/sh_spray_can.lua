--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Spray Can";
ITEM.model = "models/sprayca2.mdl";
ITEM.weight = 1;
ITEM.category = "Reusables";
ITEM.description = "A standard spray can filled with paint.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);