--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "alcohol_base";
ITEM.name = "Whiskey";
ITEM.cost = 35;
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.weight = 1.2;
ITEM.business = true;
ITEM.attributes = {Stamina = 10};
ITEM.description = "A brown colored whiskey bottle, be careful!";

-- Called when a player drinks the item.
function ITEM:OnDrink(player)
	openAura.victories:Progress(player, VIC_DRUNKARD);
end;

openAura.item:Register(ITEM);