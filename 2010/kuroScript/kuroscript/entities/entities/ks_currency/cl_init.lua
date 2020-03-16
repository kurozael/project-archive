--[[
Name: "cl_init.lua".
Product: "kuroScript".
--]]

include("sh_init.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local amount = self:GetSharedVar("ks_Amount");
	local owner = kuroScript.entity.GetOwner(self);
	
	-- Draw some information.
	y = kuroScript.frame:DrawInfo(NAME_CURRENCY, x, y, Color(200, 100, 50, 255), alpha);
	y = kuroScript.frame:DrawInfo(FORMAT_CURRENCY(amount), x, y, COLOR_WHITE, alpha);
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;