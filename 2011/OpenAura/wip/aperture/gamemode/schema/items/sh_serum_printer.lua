--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "generator_base";
ITEM.name = "Serum Printer";
ITEM.cost = 100;
ITEM.model = "models/props_lab/reciever01b.mdl";
ITEM.business = true;
ITEM.description = "Prints a minor rate of serums over time.\nThis is not permanent and can be destroyed by others.\nOrdering a second one will destroy your first one.";

ITEM.generator = {
	powerPlural = "Batteries",
	powerName = "Battery",
	uniqueID = "aura_serumprinter",
	maximum = 1,
	health = 100,
	power = 3,
	cash = 90,
	name = "Serum Printer",
};

-- Called before a player orders the item.
function ITEM:PreOrder(player)
	local entities = openAura.player:GetPropertyEntities(player, self.generator.uniqueID);
	
	for k, v in ipairs(entities) do
		v:Explode(); v:Remove();
		openAura.entity:ClearProperty(v);
	end;
end;

-- Called before a player drops the item.
function ITEM:PreDrop(player)
	self:PreOrder(player);
end;

openAura.item:Register(ITEM);