--[[
Name: "init.lua".
Product: "kuroScript".
--]]

include("sh_init.lua");

-- Add some shared Lua files.
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	-- Set some information.
	self:SetModel(MODEL_CURRENCY);
	
	-- Set some information.
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(25);
	self:SetSolid(SOLID_VPHYSICS);
	
	-- Set some information.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if a statement is true.
	if ( ValidEntity(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- A function to set the amount of currency.
function ENT:SetAmount(amount)
	self:SetSharedVar("ks_Amount", amount);
end;

-- A function to explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	-- Set some information.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(8);
	
	-- Set some information.
	util.Effect("GlassImpact", effectData);
	
	-- Emit a sound.
	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if a statement is true.
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		kuroScript.player.GiveCurrency(activator, self:GetSharedVar("ks_Amount"), "Currency");
		
		-- Emit a sound.
		activator:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		-- Remove the entity.
		self:Remove();
	end;
end;