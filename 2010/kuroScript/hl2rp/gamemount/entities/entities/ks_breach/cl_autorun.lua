--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local owner = kuroScript.entity.GetOwner(self);
	
	-- Draw some information.
	y = kuroScript.frame:DrawInfo("Breach", x, y, Color(200, 100, 50, 255), alpha);
	y = kuroScript.frame:DrawInfo("Press Use", x, y, COLOR_WHITE, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw() self:DrawModel(); end;