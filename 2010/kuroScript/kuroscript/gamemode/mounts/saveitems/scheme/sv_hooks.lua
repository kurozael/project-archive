--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when kuroScript has loaded all of the entities.
function MOUNT:KuroScriptInitPostEntity()
	self:LoadShipments(); self:LoadItems();
end;

-- Called just after data should be saved.
function MOUNT:PostSaveData()
	self:SaveShipments(); self:SaveItems();
end;