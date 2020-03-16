--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local owner = kuroScript.entity.GetOwner(self);
	
	-- Check if a statement is true.
	if ( self:GetSharedVar("ks_Note") ) then
		y = kuroScript.frame:DrawInfo("Note", x, y, Color(175, 100, 150, 255), alpha);
	else
		y = kuroScript.frame:DrawInfo("Paper", x, y, Color(175, 100, 150, 255), alpha);
	end;
	
	-- Draw some information.
	y = kuroScript.frame:DrawInfo("Press Use", x, y, COLOR_WHITE, alpha);
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;