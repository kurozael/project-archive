--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.storage = {};

-- A function to get whether storage is open.
function openAura.storage:IsStorageOpen()
	local panel = self:GetPanel();
	
	if ( IsValid(panel) and panel:IsVisible() ) then
		return true;
	end;
end;

-- A function to get whether there is no cash weight.
function openAura.storage:GetNoCashWeight()
	return self.noCashWeight;
end;

-- A function to get the storage inventory.
function openAura.storage:GetInventory()
	return self.inventory;
end;

-- A function to get the storage cash.
function openAura.storage:GetCash()
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		return self.cash;
	else
		return 0;
	end;
end;

-- A function to get the storage panel.
function openAura.storage:GetPanel()
	return self.panel;
end;

-- A function to get the storage weight.
function openAura.storage:GetWeight()
	return self.weight;
end;

-- A function to get the storage entity.
function openAura.storage:GetEntity()
	return self.entity;
end;

-- A function to get the storage name.
function openAura.storage:GetName()
	return self.name;
end;