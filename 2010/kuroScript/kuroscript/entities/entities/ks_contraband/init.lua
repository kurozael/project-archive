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
	self:SetModel(self.Model);
	
	-- Set some information.
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);

	-- Set some information.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if a statement is true.
	if ( ValidEntity(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	
	-- Set some information.
	local contraband = kuroScript.contraband.Get( self:GetClass() );
	
	-- Check if a statement is true.
	if (contraband) then
		self:SetHealth(contraband.health);
		self:SetSharedVar("ks_Power", contraband.power);
		
		-- Set some information.
		timer.Simple(1, function()
			if ( ValidEntity(self) ) then
				if (self.OnCreated) then
					self:OnCreated();
				end;
			end;
		end);
	else
		timer.Simple(1, function()
			if ( ValidEntity(self) ) then
				self:Remove();
			end;
		end);
	end;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	local contraband = kuroScript.contraband.Get( self:GetClass() );
	local attacker = damageInfo:GetAttacker();
	
	-- Check if a statement is true.
	if (contraband) then
		if ( ValidEntity(attacker) and attacker:IsPlayer() ) then
			if ( hook.Call("PlayerCanDestroyContraband", kuroScript.frame, attacker, self, contraband) ) then
				self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
				
				-- Check if a statement is true.
				if (self:Health() <= 0) then
					if ( ValidEntity(attacker) and attacker:IsPlayer() )then
						hook.Call("PlayerDestroyContraband", kuroScript.frame, attacker, self, contraband);
					end;
					
					-- Check if a statement is true.
					if (self.OnDestroy) then self:OnDestroy(attacker, damageInfo); end;
					
					-- A function to explode the entity.and remove it.
					self:Explode(); self:Remove();
				end;
			end;
		end;
	end;
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

-- Called when a player uses the entity.
function ENT:Use(player, caller)
	local contraband = kuroScript.contraband.Get( self:GetClass() );
	
	-- Check if a statement is true.
	if (contraband) then
		if (self:GetSharedVar("ks_Power") < contraband.power) then
			self:SetSharedVar("ks_Power", contraband.power);
			
			-- Call a gamemode hook.
			hook.Call("PlayerChargeContraband", kuroScript.frame, player, self, contraband);
			
			-- Check if a statement is true.
			if (self.OnCharged) then
				self:OnCharged(player);
			end;
		end;
	end;
end;