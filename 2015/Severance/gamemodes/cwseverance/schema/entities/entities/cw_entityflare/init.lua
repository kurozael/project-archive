--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

include("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/items/grenadeammo.mdl");
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetHealth(50);
	self:SetSolid(SOLID_VPHYSICS);
	
	timer.Simple(70, function()
		if (IsValid(self)) then
			Clockwork.entity:Decay(self, 30);
		end;
	end);
	
	timer.Simple(0.5, function()
		if (IsValid(self)) then
			local delay = 0;
			
			for i = 1, 6 do
				timer.Simple(delay, function()
					if (IsValid(self)) then
						if (IsValid(self.cwFlareEnt)) then
							self.cwFlareEnt:Remove();
						end;
						
						local attachment = self:GetAttachment(self:LookupAttachment("fuse"));
						local position = self:GetPos();
						
						if (attachment) then
							position = attachment.Pos;
						end;
						
						self.cwFlareEnt = ents.Create("env_flare");
						self.cwFlareEnt:SetKeyValue("duration", 180);
						self.cwFlareEnt:SetKeyValue("scale", 8);
						self.cwFlareEnt:SetParent(self);
						self.cwFlareEnt:SetPos(position);
						self.cwFlareEnt:Spawn();
					end;
				end);
				
				delay = delay + 10;
			end;
		end;
	end);
	
	local physicsObject = self:GetPhysicsObject();
	
	if (IsValid(physicsObject)) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- Called when the entity is removed.
function ENT:OnRemove()
	if (IsValid(self.cwFlareEnt)) then
		self.cwFlareEnt:Remove();
	end;
end;

-- A function to explode the entity.
function ENT:Explode(scale)
	local effectData = EffectData();
		effectData:SetStart(self:GetPos());
		effectData:SetOrigin(self:GetPos());
		effectData:SetScale(8);
	util.Effect("GlassImpact", effectData, true, true);

	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0));
	
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;