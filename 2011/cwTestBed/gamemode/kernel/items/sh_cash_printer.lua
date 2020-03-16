--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("generator_base");
ITEM.name = "Cash Printer";
ITEM.cost = 100;
ITEM.model = "models/props_lab/reciever01b.mdl";
ITEM.business = true;
ITEM.description = "Prints a <color=255,180,100>minor</color> rate of cash over time.\nThis is not permanent and can be destroyed by others.";

--[[
	Set up the generator information. This
	data is given to the Clockwork.generator library.
--]]
ITEM.generatorInfo = {
	powerPlural = "Batteries",
	powerName = "Battery",
	uniqueID = "cw_cash_printer",
	maximum = 1,
	health = 100,
	power = 3,
	cash = 90,
	name = "Cash Printer",
};

-- Called before a player orders the item.
function ITEM:PreOrder(player)
	local entities = Clockwork.player:GetPropertyEntities(
		player, self("generatorInfo").uniqueID
	);
	
	for k, v in ipairs(entities) do
		v:Explode(); v:Remove();
		Clockwork.entity:ClearProperty(v);
	end;
end;

-- Called before a player drops the item.
function ITEM:PreDrop(player)
	self:PreOrder(player);
end;

Clockwork.item:Register(ITEM);