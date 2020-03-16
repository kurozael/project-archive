--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Set some information.
AddCSLuaFile("cl_autorun.lua");
AddCSLuaFile("sh_autorun.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl");
	self:SetSolid(SOLID_NONE);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	
	-- Set some information.
	self._ComputePosition = Vector(0, 0, 0);
	self._Player = NULL;
	self._Mount = kuroScript.mount.Get("Pickup Objects");
	
	-- Set some information.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if a statement is true.
	if ( ValidEntity(physicsObject) ) then
		physicsObject:SetMass(2048);
		physicsObject:Wake();
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller) end;

-- Called each frame.
function ENT:Think()
	if (ValidEntity(self._Player) and ValidEntity(self._Target) and self._Mount) then
		if ( !self._Mount:CalculatePosition(self._Player) ) then
			self._Mount:ForceDropEntity(self._Player);
		end;
	else
		self:Remove();
	end;
end;

-- A function to set the entity's compute position.
function ENT:SetComputePosition(position)
	self._ComputePosition = position;
end;

-- A function to set the entity's player.
function ENT:SetPlayer(player)
	self._Player = player;
end;

-- A function to set the entity's target.
function ENT:SetTarget(target)
	self._Target = target;
end;

-- Called when the physics should be simulated.
function ENT:PhysicsSimulate(physicsObject, deltaTime)
	if ( ValidEntity(self._Target) ) then
		local targetPhysicsObject = self._Target:GetPhysicsObject();
		
		-- Check if a statement is true.
		if ( ValidEntity(targetPhysicsObject) ) then
			targetPhysicsObject:Wake();
		end;
	end;
	
	-- Wake the physics object.
	physicsObject:Wake();
	
	-- Compute the shadow control for the physics object.
	physicsObject:ComputeShadowControl( {
		secondstoarrive = 0.01,
		teleportdistance = 128,
		maxangulardamp = 10000,
		maxspeeddamp = 10000,
		dampfactor = 0.8,
		deltatime = deltaTime,
		maxangular = 512,
		maxspeed = 256,
		angle = self:GetAngles(),
		pos = self._ComputePosition
	} );
end;