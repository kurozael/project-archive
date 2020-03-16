--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Set some information.
AddCSLuaFile("cl_autorun.lua");
AddCSLuaFile("sh_autorun.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/props_wasteland/prison_padlock001a.mdl");
	
	-- Set some information.
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	
	-- Set some information.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if a statement is true.
	if ( ValidEntity(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- A function to create a dummy breach.
function ENT:CreateDummyBreach()
	local entity = ents.Create("prop_physics");
	
	-- Set some information.
	entity:SetCollisionGroup(COLLISION_GROUP_WORLD);
	entity:SetAngles( self:GetAngles() );
	entity:SetModel("models/props_wasteland/prison_padlock001b.mdl");
	entity:SetPos( self:GetPos() );
	
	-- Spawn the entity.
	entity:Spawn();
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		kuroScript.entity.Decay(entity, 30);
	end;
end;

-- A function to set the entity's breach entity.
function ENT:SetBreachEntity(entity, trace)
	local position = trace.HitPos;
	local angles = trace.HitNormal:Angle();
	
	-- Set some information.
	self._Entity = entity;
	self._Entity:DeleteOnRemove(self);
	
	-- Set some information.
	self:SetPos(position);
	self:SetAngles(angles);
	self:SetParent(entity);
	
	-- Set some information.
	entity._Breach = self; self:SetHealth(5);
end;

-- A function to open the entity.
function ENT:BreachEntity(activator)
	self:Explode(); self:Remove();
	
	-- Call a mount hook.
	kuroScript.mount.Call("EntityBreached", self._Entity, activator);
end;

-- A function to explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	-- Set some information.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(8);
	
	-- Set some information.
	util.Effect("GlassImpact", effectData, true, true);
	
	-- Emit a sound.
	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		self:CreateDummyBreach();
		self:BreachEntity(activator);
	end;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if a statement is true.
	if (self:Health() <= 0) then
		self:CreateDummyBreach();
		self:BreachEntity( damageInfo:GetAttacker() );
	end;
end;