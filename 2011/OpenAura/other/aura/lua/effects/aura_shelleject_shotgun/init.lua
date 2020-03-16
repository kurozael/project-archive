--[[
Name: "init.lua".
Product: "OpenAura".
--]]

-- Called when the effect initializes.
function EFFECT:Init(data)
	self.WeaponEntity = data:GetEntity();
	self.Attachment = data:GetAttachment();
	
	if ( !IsValid(self.WeaponEntity) or !self.WeaponEntity:IsWeapon() ) then
		return;
	end;
	
	self.Normal = data:GetNormal();
	
	if ( self.WeaponEntity:IsCarriedByLocalPlayer() and GetViewEntity() == LocalPlayer() ) then
		local viewModel = LocalPlayer():GetViewModel();
		
		if ( !IsValid(viewModel) ) then
			return;
		end;
		
		self.EjectionPort = viewModel:GetAttachment(self.Attachment);
		
		if (!self.EjectionPort) then
			return;
		end;
		
		self.Angle = self.EjectionPort.Ang;
		self.Forward = self.Angle:Forward();
		self.Position = self.EjectionPort.Pos;
	else
		self.EjectionPort = self.WeaponEntity:GetAttachment(self.Attachment);
		
		if (!self.EjectionPort) then
			return;
		end;
		
		self.Forward = self.Normal:Angle():Right();
		self.Angle = self.Forward:Angle();
		self.Position = self.EjectionPort.Pos - ( 0.5 * self.WeaponEntity:BoundingRadius() ) * self.EjectionPort.Ang:Forward();
	end;

	local addVelocity = self.WeaponEntity:GetOwner():GetVelocity();
	local effectData = EffectData();
		effectData:SetOrigin(self.Position);
		effectData:SetAngle(self.Angle);
		effectData:SetEntity(self.WeaponEntity);
	util.Effect("ShotgunShellEject", effectData);

	local particleEmitter = ParticleEmitter(self.Position);
	
	for i = 1, 3 do
		local particle = particleEmitter:Add("particle/particle_smokegrenade", self.Position + self.Forward * 2);
		
		if (particle) then
			particle:SetAirResistance(40);
			particle:SetStartAlpha( math.Rand(40, 50) );
			particle:SetRollDelta( math.Rand(-1, 1) );
			particle:SetStartSize( math.Rand(1, 2) );
			particle:SetVelocity(math.Rand(5, 9) * self.Forward + 1.02 * addVelocity);
			particle:SetLighting(true);
			particle:SetGravity( math.Rand(5,9) * VectorRand() + Vector(0, 0, -10) );
			particle:SetDieTime( math.Rand(1, 1.2) );
			particle:SetEndSize( math.Rand(3, 4) );
			particle:SetRoll( math.Rand(180, 480) );
			particle:SetColor(245, 245, 245);
		end;
	end;
	
	particleEmitter:Finish();
end;

-- Called when the effect should be rendered.
function EFFECT:Render() end;

-- Called each frame.
function EFFECT:Think()
	return false;
end;