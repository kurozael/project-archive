--[[
Name: "cl_auto.lua".
Product: "nexus".
--]]

NEXUS:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetSolid(SOLID_NONE);
	self:SetNotSolid(true);
	self:SetMoveType(MOVETYPE_NONE);
	self:SetCollisionBounds( Vector(0, 0, 0), Vector(0, 0, 0) );
end

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo) end;

-- Called when the entity has a collision.
function ENT:PhysicsCollide(data, physicsObject) end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

-- Called when the entity is touched by another entity.
function ENT:Touch(entity) end;

-- Called when the entity is used.
function ENT:Use(activator, caller) end;

-- Called when the entity is removed.
function ENT:OnRemove()
	if ( self:GetOwner() ) then
		self:GetOwner().animatedLegs = nil;
	end;
end;

-- Called each frame.
function ENT:Think()
	local curTime = CurTime();
	local owner = self:GetOwner();
	
	if ( owner and owner:Alive() ) then
		local playerYaw = owner:GetPoseParameter("move_yaw");
		local legsYaw = self:GetPoseParameter("move_yaw");
		
		if (playerYaw != legsYaw) then
			self:SetPoseParameter("move_yaw", playerYaw);
		end;
		
		local sequence = owner:GetSequence();
		local model = owner:GetModel();
		
		if ( owner:InVehicle() ) then
			local vehicle = owner:GetVehicle();
			
			if ( IsValid(vehicle) and !nexus.entity.IsPodEntity(vehicle) ) then
				self:SetPoseParameter(
					"vehicle_steer",
					owner:GetVehicle():GetPoseParameter("vehicle_steer")
				);
			end;
		end
		
		if (!self.NextSecond or curTime >= self.NextSecond) then
			self.NextSecond = curTime + 1;
			
			if (self:GetModel() != model) then
				self:SetModel(model);
			end;
			
			self:SetSkin( owner:GetSkin() );
			self:SetColor( owner:GetColor() );
			self:SetMaterial( owner:GetMaterial() );
		end;
		
		if (self.Animation != sequence) then
			self.Animation = sequence;
			
			self:SetPlaybackRate( owner:GetPlaybackRate() );
			self:ResetSequence(self.Animation);
			self:SetCycle(0);
		end;
		
		self:NextThink(curTime);
		
		return true;
	else
		self:Remove();
	end;
end;