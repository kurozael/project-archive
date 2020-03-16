--[[
Name: "cl_init.lua".
Product: "nexus".
--]]

include("sh_init.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = nexus.schema.GetColor("target_id");
	local colorWhite = nexus.schema.GetColor("white");
	local amount = self:GetSharedVar("sh_Amount");
	local owner = nexus.entity.GetOwner(self);
	
	y = NEXUS:DrawInfo(nexus.schema.GetOption("name_cash"), x, y, colorTargetID, alpha);
	y = NEXUS:DrawInfo(FORMAT_CASH(amount), x, y, colorWhite, alpha);
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;