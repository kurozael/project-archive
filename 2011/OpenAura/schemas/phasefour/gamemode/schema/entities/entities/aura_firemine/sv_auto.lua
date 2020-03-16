--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl");
	
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(200);
	self:SetSolid(SOLID_VPHYSICS);
	
	local physicsObject = self:GetPhysicsObject();
	
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- Called when the entity touches another entity.
function ENT:Touch(entity)
	if ( entity:IsPlayer() and entity != self:GetPlayer() ) then
		local owner = self:GetPlayer();
		local attacker = owner;
		
		if ( !IsValid(owner) ) then
			attacker = self;
		end;
		
		self:EmitSound("buttons/button16.wav");
		
		timer.Simple(1, function()
			if ( IsValid(self) and IsValid(attacker) ) then
				entity:Ignite(8, 0);
				
				self:Explode();
				self:Remove();
			end;
		end);
	end;
end;

-- Called each frame.
function ENT:Think()
	if ( !self:IsInWorld() ) then
		self:Remove();
	end;
end;

-- A function to defuse the entity.
function ENT:Defuse()
	local effectData = EffectData();
	
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(8);
	
	util.Effect("GlassImpact", effectData, true, true);
	
	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- A function to explode the entity.
function ENT:Explode(scale, bNoDamage)
	local effectData = EffectData();
	local owner = self:GetPlayer();
	local attacker = owner;
	
	if ( !IsValid(owner) ) then
		attacker = self;
	end;
	
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(scale or 8);
	
	util.Effect("Explosion", effectData);
	
	if (!bNoDamage) then
		for k, v in ipairs( ents.FindInSphere(self:GetPos(), 128) ) do
			if ( v:IsPlayer() ) then
				v:TakeDamageInfo( openAura:FakeDamageInfo(10, self, attacker, self:GetPos(), DMG_BLAST, 2) );
			end;
		end;
	end;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;