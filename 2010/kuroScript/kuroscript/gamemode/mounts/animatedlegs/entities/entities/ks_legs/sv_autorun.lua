--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Set some information.
AddCSLuaFile("cl_autorun.lua");
AddCSLuaFile("sh_autorun.lua");

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

-- Called when the entity is touched by another entity.
function ENT:Touch(entity) end;

-- Called when the entity is used.
function ENT:Use(activator, caller) end;

-- Called when the entity is removed.
function ENT:OnRemove()
	if ( self:GetOwner() ) then
		self:GetOwner()._AnimatedLegs = nil;
	end;
end;

-- Called each frame.
function ENT:Think()
	local curTime = CurTime();
	local owner = self:GetOwner();
	
	-- Check if a statement is true.
	if ( owner and owner:Alive() ) then
		local playerYaw = owner:GetPoseParameter("move_yaw");
		local legsYaw = self:GetPoseParameter("move_yaw");
		
		-- Check if a statement is true.
		if (playerYaw != legsYaw) then
			self:SetPoseParameter("move_yaw", playerYaw);
		end;
		
		-- Set some information.
		local velocity = owner:GetVelocity():Length();
		local sequence = owner:GetSequence();
		local model = owner:GetModel();
		
		-- Check if a statement is true.
		if ( owner:InVehicle() ) then
			local vehicle = owner:GetVehicle();
			
			-- Check if a statement is true.
			if ( ValidEntity(vehicle) ) then
				if ( !kuroScript.entity.IsPodEntity(vehicle) ) then
					self:SetPoseParameter( "vehicle_steer", owner:GetVehicle():GetPoseParameter("vehicle_steer") );
				end;
			end;
		end
		
		-- Check if a statement is true.
		if (!self.NextSecond or curTime >= self.NextSecond) then
			self.NextSecond = curTime + 1;
			
			-- Set some information.
			self:SetSkin( owner:GetSkin() );
			self:SetColor( owner:GetColor() );
			self:SetMaterial( owner:GetMaterial() );
		end;
		
		-- Check if a statement is true.
		if (self.Animation != sequence) then
			self.Animation = sequence;
			
			-- Set some information.
			self:SetPlaybackRate(owner:GetKeyValues().playbackrate);
			self:ResetSequence(self.Animation);
			self:SetCycle(0);
		end;
		
		-- Check if a statement is true.
		if (self:GetModel() != model) then
			self:SetModel(model);
		end;
		
		-- Set some information.
		self:SetAngles( owner:GetAngles() );
		self:NextThink(curTime);
		
		-- Return true to break the function.
		return true;
	else
		self:Remove();
	end;
end;