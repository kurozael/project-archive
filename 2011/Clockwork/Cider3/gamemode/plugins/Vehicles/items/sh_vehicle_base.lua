--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

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
ITEM.destroyText = "Sell";
ITEM.allowStorage = false;

if (string.lower(game.GetMap()) == "rp_evocity_v2d") then
	ITEM.business = true;
end;

-- Called when a player destroys the item.
function ITEM:OnDestroy(player)
	Clockwork.player:GiveCash(player, self("cost") / 2, "selling a "..self("name"):lower());
end;

-- Called when the item has been ordered.
function ITEM:OnOrder(player, entity)
	if (IsValid(entity)) then
		entity:Remove();
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (string.lower(game.GetMap()) != "rp_evocity_v2d") then
		Clockwork.player:Notify(player, "You cannot use vehicles on this map!");
		return;
	end;
	
	if (!PLUGIN:SpawnVehicle(player, self)) then
		return false;
	end;
end;

Clockwork.item:Register(ITEM);