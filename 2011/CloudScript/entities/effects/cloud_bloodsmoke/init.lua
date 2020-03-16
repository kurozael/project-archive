--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local function ParticleCollides(particle, position, normal)
	util.Decal("Blood", position + normal, position - normal);
end;

-- Called when the effect has initialized.
function EFFECT:Init(data)
	local particleEmitter = ParticleEmitter( data:GetOrigin() );
	local velocity = data:GetNormal() or ( Vector(0, 0, 1) * math.Rand(32, 64) );
	local scale = data:GetScale() or 2;
	
	for i = 1, (16 * scale) do
		local startSize = math.Rand(16 * scale, 32 * scale);
		local position = Vector( math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-2, 2) );
		local particle = particleEmitter:Add("particle/particle_smokegrenade", data:GetOrigin() + position);
		
		if (particle) then
			particle:SetAirResistance( math.Rand(256, 384) );
			particle:SetCollideCallback(ParticleCollides);
			particle:SetStartAlpha(175);
			particle:SetStartSize(startSize * 2);
			particle:SetRollDelta( math.Rand(-0.2, 0.2) );
			particle:SetEndAlpha( math.Rand(0, 128) );
			particle:SetVelocity(velocity);
			particle:SetLifeTime(0);
			particle:SetLighting(0);
			particle:SetGravity( Vector( math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(16, -16) ) );
			particle:SetCollide(true);
			particle:SetEndSize(startSize);
			particle:SetDieTime( math.random(1, 3) );
			particle:SetBounce(0.5);
			particle:SetColor( math.random(200, 255), math.random(0, 50), math.random(0, 50) );
			particle:SetRoll( math.Rand(-180, 180) );
		end;
	end;
	
	particleEmitter:Finish()
end;

-- Called when the effect should be rendered.
function EFFECT:Render() end;

-- Called each frame.
function EFFECT:Think()
	return false;
end;