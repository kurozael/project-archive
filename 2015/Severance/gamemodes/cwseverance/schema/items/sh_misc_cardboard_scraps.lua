local ITEM = Clockwork.item:New();

ITEM.name = "Cardboard Scraps";
ITEM.model = "models/props_junk/garbage_carboard002a.mdl";
ITEM.weight = 0.2;
ITEM.category = "Materials";
ITEM.uniqueID = "cardboard_scraps";
ITEM.description = "Some cardboard scraps, could be useful for something.";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

ITEM:Register();