--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Whether or not to take the physcannon from each player.
kuroScript.config.Add("take_physcannon", true);

-- A function to force a player to throw the entity that they are holding.
function MOUNT:ForceThrowEntity(player)
	local entity = self:ForceDropEntity(player);
	local force = player:GetAimVector() * 768;
	
	-- Set some information.
	timer.Simple(FrameTime() * 0.5, function()
		if ( ValidEntity(entity) and ValidEntity(player) ) then
			local physicsObject = entity:GetPhysicsObject();
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				physicsObject:ApplyForceCenter(force);
			end;
		end;
	end);
end;

-- A function to foorce a player to drop the entity that they are holding.
function MOUNT:ForceDropEntity(player)
	local holdingGrab = player._HoldingGrab;
	local curTime = CurTime();
	local entity = player._HoldingEntity;
	
	-- Check if a statement is true.
	if ( ValidEntity(holdingGrab) ) then
		constraint.RemoveAll(holdingGrab);
		
		-- Remove the entity.
		holdingGrab:Remove();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		entity._NextTakeDamageTime = curTime + 1;
		entity._HoldingGrab = nil;
	end;
	
	-- Check if a statement is true.
	if (player._HoldingEntity) then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
	end;
	
	-- Set some information.
	player._NextPunchTime = curTime + 1;
	player._HoldingEntity = nil;
	player._HoldingGrab = nil;
	
	-- Return the entity.
	return entity;
end;

-- A function to foorce a player to pickup an entity.
function MOUNT:ForcePickup(player, entity, trace)
	self:ForceDropEntity(player);
	
	-- Set some information.
	player._HoldingGrab = ents.Create("ks_grab");
	player._HoldingGrab:SetOwner(player);
	player._HoldingGrab:SetPos(trace.HitPos);
	player._HoldingGrab:Spawn();
	
	-- Set some information.
	player._HoldingGrab:StartMotionController();
	player._HoldingGrab:SetComputePosition(trace.HitPos);
	player._HoldingGrab:SetPlayer(player);
	player._HoldingGrab:SetTarget(entity);
	
	-- Set some information.
	player._HoldingEntity = entity;
	player._HoldingGrab:SetCollisionGroup(COLLISION_GROUP_WORLD);
	player._HoldingGrab:SetNotSolid(true);
	player._HoldingGrab:SetNoDraw(true);
	
	-- Set some information.
	entity._HoldingGrab = player._HoldingGrab;
	
	-- Emit a sound from the player.
	player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
	
	-- Check if a statement is true.
	if (entity:GetClass() == "prop_ragdoll") then
		constraint.Weld(entity, player._HoldingGrab, trace.PhysicsBone, 0, 0);
	else
		constraint.Weld(entity, player._HoldingGrab, 0, 0, 0);
	end
end;

-- A function to calculate a player's entity position.
function MOUNT:CalculatePosition(player)
	local holdingGrab = player._HoldingGrab;
	local curTime = CurTime();
	local entity = player._HoldingEntity;
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) and ValidEntity(holdingGrab) and player:Alive() and !player:IsRagdolled() ) then
		if ( player:IsUsingHands() ) then
			local shootPosition = player:GetShootPos();
			local isRagdoll = entity:GetClass() == "prop_ragdoll";
			local filter = {holdingGrab, entity, player};
			local length = 32 + entity:BoundingRadius();
			
			-- Check if a statement is true.
			if (isRagdoll) then
				length = 0;
			end;
			
			-- Check if a statement is true.
			if (player:KeyDown(IN_SPEED) and isRagdoll) then
				self:ForceDropEntity(player);
			elseif ( player:KeyDown(IN_FORWARD) ) then
				length = length + (player:GetVelocity():Length() / 2);
			elseif ( player:KeyDown(IN_BACK) and player:KeyDown(IN_SPEED) ) then
				length = -16;
			end;
			
			-- Set some information.
			local trace = util.TraceLine( {
				start = shootPosition,
				endpos = shootPosition + (player:GetAimVector() * length),
				filter = filter
			} );
			
			-- Set some information.
			holdingGrab:SetComputePosition( trace.HitPos - holdingGrab:OBBCenter() );
			
			-- Check if a statement is true.
			if (entity:GetClass() == "prop_ragdoll") then
				holdingGrab._ComputePosition.z = math.min(holdingGrab._ComputePosition.z, shootPosition.z - 32);
			else
				holdingGrab._ComputePosition.z = math.min(holdingGrab._ComputePosition.z, shootPosition.z + 8);
			end;
			
			-- Return true to break the function.
			return true;
		end;
	end;
end;