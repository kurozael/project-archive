--[[
Name: "cl_storage.lua".
Product: "nexus".
--]]

nexus.storage = {};

-- A function to get whether storage is open.
function nexus.storage.IsStorageOpen()
	local panel = nexus.storage.GetPanel();
	
	if ( IsValid(panel) and panel:IsVisible() ) then
		return true;
	end;
end;

-- A function to get whether there is no cash weight.
function nexus.storage.GetNoCashWeight()
	return nexus.storage.noCashWeight;
end;

-- A function to get the storage inventory.
function nexus.storage.GetInventory()
	return nexus.storage.inventory;
end;

-- A function to get the storage cash.
function nexus.storage.GetCash()
	if ( nexus.config.Get("cash_enabled"):Get() ) then
		return nexus.storage.cash;
	else
		return 0;
	end;
end;

-- A function to get the storage panel.
function nexus.storage.GetPanel()
	return nexus.storage.panel;
end;

-- A function to get the storage weight.
function nexus.storage.GetWeight()
	return nexus.storage.weight;
end;

-- A function to get the storage entity.
function nexus.storage.GetEntity()
	return nexus.storage.entity;
end;

-- A function to get the storage name.
function nexus.storage.GetName()
	return nexus.storage.name;
end;