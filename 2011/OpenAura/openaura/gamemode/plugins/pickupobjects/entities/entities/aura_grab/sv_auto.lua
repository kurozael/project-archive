--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl");
	self:SetSolid(SOLID_NONE);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	
	self.computePosition = Vector(0, 0, 0);
	self.player = NULL;
	self.plugin = openAura.plugin:Get("Pickup Objects");
	
	local physicsObject = self:GetPhysicsObject();
	
	if ( IsValid(physicsObject) ) then
		physicsObject:SetMass(2048);
		physicsObject:Wake();
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller) end;

-- Called each frame.
function ENT:Think()
	if (IsValid(self.player) and IsValid(self.target) and self.plugin) then
		if ( !self.plugin:CalculatePosition(self.player) ) then
			self.plugin:ForceDropEntity(self.player);
		end;
	else
		self:Remove();
	end;
end;

-- A function to set the entity's compute position.
function ENT:SetComputePosition(position)
	self.computePosition = position;
end;

-- A function to set the entity's player.
function ENT:SetPlayer(player)
	self.player = player;
end;

-- A function to set the entity's target.
function ENT:SetTarget(target)
	self.target = target;
end;

-- Called when the physics should be simulated.
function ENT:PhysicsSimulate(physicsObject, deltaTime)
	if ( IsValid(self.target) ) then
		local targetPhysicsObject = self.target:GetPhysicsObject();
		
		if ( IsValid(targetPhysicsObject) ) then
			targetPhysicsObject:Wake();
		end;
	end;
	
	physicsObject:Wake();
	
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
		pos = self.computePosition
	} );
end;