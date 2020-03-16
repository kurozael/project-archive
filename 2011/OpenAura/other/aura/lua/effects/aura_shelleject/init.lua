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
	util.Effect("ShellEject", effectData);

	local particleEmitter = ParticleEmitter(self.Position);
	
	for i = 1, 2 do
		local particle = particleEmitter:Add("particle/particle_smokegrenade", self.Position);
		
		if (particle) then
			particle:SetAirResistance(40);
			particle:SetStartAlpha( math.Rand(50, 60) );
			particle:SetStartSize(1);
			particle:SetVelocity(6 * i * self.Forward + 1.02 * addVelocity);
			particle:SetRollDelta( math.Rand(-1, 1) );
			particle:SetEndSize(math.Rand(2 , 3) * i);
			particle:SetLighting(true);
			particle:SetDieTime( math.Rand(0.33, 0.35) );
			particle:SetColor(245, 245, 245);
			particle:SetRoll( math.Rand(180, 480) );
		end;
	end;

	particleEmitter:Finish();
end;

-- Called every frame.
function EFFECT:Think()
	return false;
end;

-- Called when the effect is rendered.
function EFFECT:Render()
end;
