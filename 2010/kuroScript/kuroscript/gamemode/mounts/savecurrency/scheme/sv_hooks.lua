--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when kuroScript has loaded all of the entities.
function MOUNT:KuroScriptInitPostEntity()
	self:LoadCurrency();
end;

-- Called just after data should be saved.
function MOUNT:PostSaveData()
	self:SaveCurrency();
end;