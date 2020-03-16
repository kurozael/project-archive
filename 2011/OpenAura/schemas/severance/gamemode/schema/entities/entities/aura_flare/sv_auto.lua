--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/items/grenadeammo.mdl");
	
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetHealth(50);
	self:SetSolid(SOLID_VPHYSICS);
	
	timer.Simple(70, function()
		if ( IsValid(self) ) then
			openAura.entity:Decay(self, 30);
		end;
	end);
	
	timer.Simple(0.5, function()
		if ( IsValid(self) ) then
			local delay = 0;
			-- local i;
			
			for i = 1, 6 do
				timer.Simple(delay, function()
					if ( IsValid(self) ) then
						if ( IsValid(self.flareEntity) ) then
							self.flareEntity:Remove();
						end;
						
						local attachment = self:GetAttachment( self:LookupAttachment("fuse") );
						local position = self:GetPos();
						
						if (attachment) then
							position = attachment.Pos;
						end;
						
						self.flareEntity = ents.Create("env_flare");
						self.flareEntity:SetKeyValue("duration", 180);
						self.flareEntity:SetKeyValue("scale", 8);
						self.flareEntity:SetParent(self);
						self.flareEntity:SetPos(position);
						self.flareEntity:Spawn();
					end;
				end);
				
				delay = delay + 10;
			end;
		end;
	end);
	
	local physicsObject = self:GetPhysicsObject();
	
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- Called when the entity is removed.
function ENT:OnRemove()
	if ( IsValid(self.flareEntity) ) then
		self.flareEntity:Remove();
	end;
end;

-- A function to explode the entity.
function ENT:Explode(scale)
	local effectData = EffectData();
	
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(scale or 8);
	
	util.Effect("GlassImpact", effectData);

	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;