--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

-- Called when a particle has collided with a surface.
local function particleCollides(particle, position, normal)
	if (!particle._StartPosition or particle._StartPosition:Distance(position) > 512) then
		position = position + Vector(0, 0, 16);
		
		-- Check if a statement is true.
		if (math.random(1, 8) == 8) then
			WorldSound("ambient/water/rain_drip"..math.random(1, 4)..".wav", position);
		end;
		
		-- Check if a statement is true.
		if (util.PointContents( position - Vector(0, 0, 8) ) == CONTENTS_WATER) then
			local effectData = EffectData();
				effectData:SetOrigin(position);
				effectData:SetNormal(normal);
				effectData:SetStart(position);
				effectData:SetScale(2);
			util.Effect("watersplash", effectData, true, true);
		end;
	end;
	
	-- Set the particle's die time.
	particle:SetDieTime(0);
end;

-- Called when the effect initializes.
function EFFECT:Init(data)
	self._Particles = data:GetMagnitude();
	self._DieTime = CurTime() + 8;
	self._Emitter = ParticleEmitter( g_LocalPlayer:EyePos() + Vector(0, 0, 64) );
end

-- Called each frame.
function EFFECT:Think()
	local playerPosition = g_LocalPlayer:EyePos() + Vector(0, 0, 64);
	local precipitation = kuroScript.mount.Get("Precipitation");
	local velocityX = g_LocalPlayer:GetVelocity().x;
	local velocityY = g_LocalPlayer:GetVelocity().y;
	
	-- Check if a statement is true.
	if (precipitation) then
		self._MapHeight = precipitation:CalculateMapHeight() - playerPosition.z;
	else
		return false;
	end;
	
	-- Check if a statement is true.
	if (CurTime() >= self._DieTime) then
		return false;
	end;
	
	-- Loop through a range of values.
	for i = 1, self._Particles do
		local timeToFall = math.abs(self._MapHeight - playerPosition.z) / 1536;
		local velocityA = timeToFall * 2;
		local randomPY = math.random(-4096, 4096) + (velocityY * velocityA);
		local randomPX = math.random(-4096, 4096) + (velocityX * velocityA);
		local testPos = Vector(randomPX, randomPY, playerPosition.z);
		local trace = util.TraceLine( {
			endpos = testPos + Vector(0, 0, 32768),
			filter = g_LocalPlayer,
			start = testPos
		} );
		
		-- Check if a statement is true.
		if (trace.HitSky) then
			local position = trace.HitPos - Vector(0, 0, 256);
			local particle = self._Emitter:Add("particle/rain", position);
			
			-- Check if a statement is true.
			if (particle) then
				particle._StartPosition = position;
				
				-- Set some information.
				particle:SetCollideCallback(particleCollides);
				particle:SetAirResistance(0);
				particle:SetStartLength(32);
				particle:SetStartAlpha(200);
				particle:SetStartSize(2);
				particle:SetEndLength(48);
				particle:SetVelocity( Vector(0, 0, -1536) );
				particle:SetEndAlpha(255);
				particle:SetLifeTime(0);
				particle:SetDieTime(10 + timeToFall);
				particle:SetEndSize(2);
				particle:SetCollide(true)
				particle:SetBounce(0);
				particle:SetColor(150, 150, 225);
			end;
		end;
	end;
	
	-- Return true to break the function.
	return true;
end;

-- Called when the effect should be rendered.
function EFFECT:Render() end;