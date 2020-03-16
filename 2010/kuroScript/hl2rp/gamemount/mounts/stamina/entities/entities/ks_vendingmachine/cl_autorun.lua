--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua")

-- Set some information.
local glowMaterial = Material("sprites/glow04_noz");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
	
	-- Set some information.
	local r, g, b, a = self:GetColor();
	local flashTime = self:GetSharedVar("ks_Flash");
	local glowColor = Color(0, 255, 0, a);
	local position = self:GetPos();
	local forward = self:GetForward() * 18;
	local curTime = CurTime();
	local right = self:GetRight() * -24;
	local up = self:GetUp() * 6;
	
	-- Check if a statement is true.
	if (self:GetStock() == 0) then
		glowColor = Color(255, 150, 0, a);
	end;
	
	-- Check if a statement is true.
	if (flashTime and flashTime >= curTime) then
		if ( self:GetSharedVar("ks_Action") ) then
			glowColor = Color(0, 0, 255, a);
		else
			glowColor = Color(255, 0, 0, a);
		end;
	end;
	
	-- Start a 3D camera.
	cam.Start3D( EyePos(), EyeAngles() );
		render.SetMaterial(glowMaterial);
		render.DrawSprite(position + forward + right + up, 20, 20, glowColor);
	cam.End3D();
end;