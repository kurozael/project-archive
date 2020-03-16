--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Set some information.
AddCSLuaFile("cl_autorun.lua");
AddCSLuaFile("sh_autorun.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	-- Set some information.
	self:SetModel("models/props_lab/citizenradio.mdl");
	
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

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if a statement is true.
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;

-- A function to set the frequency.
function ENT:SetFrequency(frequency)
	self:SetSharedVar("ks_Frequency", frequency);
end;

-- A function to get whether the entity is off.
function ENT:IsOff()
	return self:GetSharedVar("ks_Off");
end;

-- A function to set whether the entity is off.
function ENT:SetOff(off)
	self:SetSharedVar("ks_Off", off);
end;

-- A function to toggle whether the entity is off.
function ENT:Toggle()
	if ( self:IsOff() ) then
		self:SetOff(false);
	else
		self:SetOff(true);
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		if ( activator:KeyDown(IN_SPEED) ) then
			self:Toggle();
		else
			local success, fault = kuroScript.inventory.Update(activator, "stationary_radio", 1);
			
			-- Check if a statement is true.
			if (!success) then
				kuroScript.player.Notify(activator, fault);
			else
				self:Remove();
			end;
		end;
	end;
end;