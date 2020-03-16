--[[
Name: "init.lua".
Product: "nexus".
--]]

include("sh_init.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	self:SetModel(self.Model);
	
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);

	local physicsObject = self:GetPhysicsObject();
	
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	
	local generator = nexus.generator.Get( self:GetClass() );
	
	if (generator) then
		self:SetHealth(generator.health);
		self:SetSharedVar("sh_Power", generator.power);
		
		timer.Simple(1, function()
			if ( IsValid(self) ) then
				if (self.OnCreated) then
					self:OnCreated();
				end;
			end;
		end);
	else
		timer.Simple(1, function()
			if ( IsValid(self) ) then
				self:Remove();
			end;
		end);
	end;
end;

-- Called each frame.
function ENT:Think()
	self:NextThink(CurTime() + 1);
	
	if ( !self:IsInWorld() ) then
		self:Remove();
	end;
end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	local generator = nexus.generator.Get( self:GetClass() );
	local attacker = damageInfo:GetAttacker();
	
	if (generator) then
		if ( IsValid(attacker) and attacker:IsPlayer() ) then
			if ( nexus.mount.Call("PlayerCanDestroyGenerator", attacker, self, generator) ) then
				self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
				
				if (self:Health() <= 0) then
					if ( IsValid(attacker) and attacker:IsPlayer() )then
						nexus.mount.Call("PlayerDestroyGenerator", attacker, self, generator);
					end;
					
					if (self.OnDestroy) then
						self:OnDestroy(attacker, damageInfo);
					end;
					
					self:Explode();
					self:Remove();
				end;
			end;
		end;
	end;
end;

-- A function to explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(8);
	
	util.Effect("GlassImpact", effectData);

	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;