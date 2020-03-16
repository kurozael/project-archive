--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local owner = kuroScript.entity.GetOwner(self);
	
	-- Check if a statement is true.
	if ( kuroScript.inventory.HasItem("locker_key") ) then
		y = kuroScript.frame:DrawInfo("Locker", x, y, Color(125, 150, 175, 255), alpha);
		y = kuroScript.frame:DrawInfo("Press F2", x, y, COLOR_WHITE, alpha);
	else
		y = kuroScript.frame:DrawInfo("Locker", x, y, Color(125, 150, 175, 255), alpha);
		y = kuroScript.frame:DrawInfo("Locked", x, y, COLOR_WHITE, alpha);
	end;
end;

-- Called when the entity should draw.
function ENT:Draw() self:DrawModel(); end;