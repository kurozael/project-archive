local ITEM = Clockwork.item:New();

ITEM.name = "Cardboard Scraps";
ITEM.model = "models/props_junk/garbage_carboard002a.mdl";
ITEM.weight = 0;
ITEM.category = "Materials";
ITEM.description = "Some cardboard scraps, could be useful for something.";
ITEM.uniqueID = "moist_towlette";
ITEM.EnergyAmount = 5;

-- Called when a player drops the item.
function ITEM:OnUse(player, itemEntity)
	Clockwork.player:Notify(player, "You use the Moist Towlette to wipe yourself off, the soft smell of it just enough to make you feel a bit better.");
end;

function ITEM:OnDrop(player, position) end;

ITEM:Register();