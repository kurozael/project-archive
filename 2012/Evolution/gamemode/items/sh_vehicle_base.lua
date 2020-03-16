--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New(nil, true);
ITEM.name = "Vehicle Base";
ITEM.batch = 1;
ITEM.weight = 0;
ITEM.useText = "Drive";
ITEM.category = "Vehicles";
ITEM.business = false;
ITEM.hornSound = "vehicles/honk.wav";
ITEM.isRareItem = true;
ITEM.weightText = "Garage";
ITEM.destroyText = "Trade";
ITEM.allowStorage = false;

ITEM:AddData("Name", "", true);
ITEM:AddData("Desc", "", true);
ITEM:AddQueryProxy("description", "Desc", true);
ITEM:AddQueryProxy("name", "Name", true);

--[[ A table of maps allowed to use vehicles... --]]
local VEHICLE_MAPS = {
	"rp_apocalypse",
	"rp_evocity_v33x",
	"rp_outercanals"
};

if (table.HasValue(VEHICLE_MAPS, string.lower(game.GetMap()))) then
	ITEM.business = true;
end;

-- Called when a player destroys the item.
function ITEM:OnDestroy(player)
	Clockwork.player:GiveCash(player, self("cost") / 2, "trading a "..self("name"):lower());
end;

-- Called when the item has been ordered.
function ITEM:OnOrder(player, entity)
	if (IsValid(entity)) then entity:Remove(); end;
	
	player:GiveItem(
		Clockwork.item:CreateInstance(self("uniqueID")), true
	);
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (!table.HasValue(VEHICLE_MAPS, string.lower(game.GetMap()))) then
		Clockwork.player:Notify(player, "You cannot use vehicles on this map!");
		return;
	end;
	
	if (!Schema:SpawnVehicle(player, self)) then
		return false;
	end;
end;

Clockwork.item:Register(ITEM);