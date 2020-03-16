--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua")

-- Set some information.
local glowMaterial = Material("sprites/grav_flare");

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local frequency = self:GetSharedVar("ks_Frequency");
	local owner = kuroScript.entity.GetOwner(self);
	
	-- Draw some information.
	y = kuroScript.frame:DrawInfo("Radio", x, y, Color(175, 100, 150, 255), alpha);
	
	-- Check if a statement is true.
	if ( !self:GetSharedVar("ks_Off") ) then
		y = kuroScript.frame:DrawInfo("Turn Off: Sprint + Use", x, y, COLOR_INFORMATION, alpha);
	else
		y = kuroScript.frame:DrawInfo("Turn On: Sprint + Use", x, y, COLOR_INFORMATION, alpha);
	end;
	
	-- Check if a statement is true.
	if (frequency == "") then
		y = kuroScript.frame:DrawInfo("Frequency: 000.0", x, y, COLOR_WHITE, alpha);
	else
		y = kuroScript.frame:DrawInfo("Frequency: "..frequency, x, y, COLOR_WHITE, alpha);
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
	
	-- Set some information.
	local r, g, b, a = self:GetColor();
	local glowColor = Color(0, 255, 0, a);
	local position = self:GetPos();
	local forward = self:GetForward() * 9;
	local right = self:GetRight() * 5;
	local up = self:GetUp() * 8;
	
	-- Check if a statement is true.
	if ( self:GetSharedVar("ks_Off") ) then
		glowColor = Color(255, 0, 0, a);
	end;
	
	-- Start a 3D camera.
	cam.Start3D( EyePos(), EyeAngles() );
		render.SetMaterial(glowMaterial);
		render.DrawSprite(position + forward + right + up, 16, 16, glowColor);
	cam.End3D();
end;