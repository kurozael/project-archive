--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

ITEM = openAura.item:New();
ITEM.name = "Vehicle Base";
ITEM.batch = 1;
ITEM.weight = 0;
ITEM.useText = "Drive";
ITEM.category = "Vehicles";
ITEM.business = false;
ITEM.hornSound = "vehicles/honk.wav";
ITEM.isBaseItem = true;
ITEM.isRareItem = true;
ITEM.destroyText = "Sell";
ITEM.allowStorage = false;

if (string.lower( game.GetMap() ) == "rp_evocity_v2d") then
	ITEM.business = true;
end;

-- Called when the item has initialized.
function ITEM:OnInitialize(panel)
	self.weightText = "Garage";
end;

-- Called when a player destroys the item.
function ITEM:OnDestroy(player)
	openAura.player:GiveCash( player, self.cost / 2, "selling a "..string.lower(self.name) );
end;

-- Called when the item has been ordered.
function ITEM:OnOrder(player, entity)
	player:UpdateInventory(self.uniqueID, 1, true);

	if ( IsValid(entity) ) then
		entity:Remove();
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (string.lower( game.GetMap() ) != "rp_evocity_v2d") then
		openAura.player:Notify(player, "You cannot use vehicles on this map!");
		
		return;
	end;
	
	if ( !PLUGIN:SpawnVehicle(player, self) ) then
		return false;
	end;
end;

openAura.item:Register(ITEM);