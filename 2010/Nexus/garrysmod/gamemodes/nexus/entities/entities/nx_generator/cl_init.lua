--[[
Name: "cl_init.lua".
Product: "nexus".
--]]

include("sh_init.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;