--[[
Name: "cl_storage.lua".
Product: "kuroScript".
--]]

kuroScript.storage = {};

-- A function to get whether storage is open.
function kuroScript.storage.IsStorageOpen()
	local panel = kuroScript.storage.GetPanel();
	
	-- Check if a statement is true.
	if (panel and panel:IsValid() ) then
		return true;
	end;
end;

-- A function to get the storage inventory.
function kuroScript.storage.GetInventory()
	return kuroScript.storage.inventory;
end;

-- A function to get the storage currency.
function kuroScript.storage.GetCurrency()
	return kuroScript.storage.currency;
end;

-- A function to get the storage panel.
function kuroScript.storage.GetPanel()
	return kuroScript.storage.panel;
end;

-- A function to get the storage weight.
function kuroScript.storage.GetWeight()
	return kuroScript.storage.weight;
end;

-- A function to get the storage entity.
function kuroScript.storage.GetEntity()
	return kuroScript.storage.entity;
end;

-- A function to get the storage name.
function kuroScript.storage.GetName()
	return kuroScript.storage.name;
end;