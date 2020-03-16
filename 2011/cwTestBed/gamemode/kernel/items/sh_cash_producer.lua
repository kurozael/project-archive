--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("generator_base");
ITEM.name = "Cash Producer";
ITEM.cost = 150;
ITEM.model = "models/props_lab/reciever01a.mdl";
ITEM.toolTip = "<color=255,100,100>Ordering a second one will destroy your first one!</color>";
ITEM.business = true;
ITEM.description = "Produces a <color=172,226,129>medium</color> rate of cash over time.\nThis is not permanent and can be destroyed by others.";

--[[
	Set up the generator information. This
	data is given to the Clockwork.generator library.
--]]
ITEM.generatorInfo = {
	powerPlural = "Batteries",
	powerName = "Battery",
	uniqueID = "cw_cash_producer",
	maximum = 1,
	health = 150,
	power = 4,
	cash = 110,
	name = "Cash Producer",
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