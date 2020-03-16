--[[
	© 2017 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "CDF MRE: Extras Packet";
ITEM.model = "models/props_lab/box01a.mdl";
ITEM.weight = 0.1;
ITEM.useText = "Eat";
ITEM.uniqueID = "mre_extras"
ITEM.category = "Consumables"
ITEM.description = "An extras packet containing several items.";
ITEM.useSound = "items/ammocrate_open.wav";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local randomitems = {"mre_matches", "cardboard_scraps", "moist_towlette", "bubble_gum"}
	local itemTable = Clockwork.item:FindByID(table.Random(randomitems));
	Clockwork.player:Notify(player, "You open the extras packet, taking the contents out, but the only thing of use inside you find is: ".. itemTable("name"));
	player:GiveItem(itemTable("uniqueID"));
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);