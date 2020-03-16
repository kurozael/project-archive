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
	self:SetModel("models/props_c17/paper01.mdl");
	
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

-- A function to set the text.
function ENT:SetText(text)
	if (text) then
		self._Text = text;
		self._UniqueID = util.CRC(text);
		
		-- Set some information.
		self:SetSharedVar("ks_Note", true);
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		if (self._Text) then
			if ( !activator._PaperIDs or !activator._PaperIDs[self._UniqueID] ) then
				if (!activator._PaperIDs) then
					activator._PaperIDs = {};
				end;
				
				-- Set some information.
				activator._PaperIDs[self._UniqueID] = true;
				
				-- Start a data stream.
				datastream.StreamToClients( activator, "ks_ViewPaper", {self, self._UniqueID, self._Text} );
			else
				datastream.StreamToClients( activator, "ks_ViewPaper", {self, self._UniqueID} );
			end;
		else
			umsg.Start("ks_EditPaper", activator);
				umsg.Entity(self);
			umsg.End();
		end;
	end;
end;