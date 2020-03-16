--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when kuroScript has loaded all of the entities.
function MOUNT:KuroScriptInitPostEntity()
	self:LoadParentData();
	self:LoadDoorData();
end;