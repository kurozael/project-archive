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
	local r, g, b, a = self:GetColor();
	local rationTime = self:GetSharedVar("ks_Ration");
	local flashTime = self:GetSharedVar("ks_Flash");
	local position = self:GetPos();
	local forward = self:GetForward() * 8;
	local curTime = CurTime();
	local right = self:GetRight() * 5;
	local up = self:GetUp() * 13;
	
	-- Check if a statement is true.
	if (rationTime > curTime) then
		local glowColor = Color(0, 0, 255, a);
		local timeLeft = rationTime - curTime;
		
		-- Check if a statement is true.
		if ( !self._NextFlash or curTime >= self._NextFlash or (self._FlashUntil and self._FlashUntil > curTime) ) then
			cam.Start3D( EyePos(), EyeAngles() );
				render.SetMaterial(glowMaterial);
				render.DrawSprite(position + forward + right + up, 20, 20, glowColor);
			cam.End3D();
			
			-- Check if a statement is true.
			if (!self._FlashUntil or curTime >= self._FlashUntil) then
				self._NextFlash = curTime + (timeLeft / 4);
				self._FlashUntil = curTime + (FrameTime() * 4);
				
				-- Emit a sound from the entity.
				self:EmitSound("hl1/fvox/boop.wav");
			end;
		end;
	else
		local glowColor = Color(0, 255, 0, a);
		
		-- Check if a statement is true.
		if ( self:GetSharedVar("ks_Locked") ) then
			glowColor = Color(255, 150, 0, a);
		end;
		
		-- Check if a statement is true.
		if (flashTime and flashTime >= curTime) then
			glowColor = Color(255, 0, 0, a);
		end;
		
		-- Start a 3D camera.
		cam.Start3D( EyePos(), EyeAngles() );
			render.SetMaterial(glowMaterial);
			render.DrawSprite(position + forward + right + up, 20, 20, glowColor);
		cam.End3D();
	end;
end;