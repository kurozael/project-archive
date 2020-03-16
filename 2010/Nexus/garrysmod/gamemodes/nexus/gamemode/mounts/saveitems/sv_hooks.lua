--[[
Name: "sv_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when nexus has loaded all of the entities.
function MOUNT:NexusInitPostEntity()
	self:LoadShipments(); self:LoadItems();
end;

-- Called just after data should be saved.
function MOUNT:PostSaveData()
	self:SaveShipments(); self:SaveItems();
end;