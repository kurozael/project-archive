--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:Add("take_physcannon", true);

-- A function to force a player to throw the entity that they are holding.
function PLUGIN:ForceThrowEntity(player)
	local entity = self:ForceDropEntity(player);
	local force = player:GetAimVector() * 768;
	
	timer.Simple(FrameTime() * 0.5, function()
		if ( IsValid(entity) and IsValid(player) ) then
			local physicsObject = entity:GetPhysicsObject();
			
			if ( IsValid(physicsObject) ) then
				physicsObject:ApplyForceCenter(force);
			end;
		end;
	end);
end;

-- A function to foorce a player to drop the entity that they are holding.
function PLUGIN:ForceDropEntity(player)
	local holdingGrab = player.holdingGrab;
	local curTime = CurTime();
	local entity = player.holdingEntity;
	
	if ( IsValid(holdingGrab) ) then
		constraint.RemoveAll(holdingGrab);
		
		holdingGrab:Remove();
	end;
	
	if ( IsValid(entity) ) then
		entity.nextTakeDamageTime = curTime + 1;
		entity.holdingGrab = nil;
	end;
	
	if (player.holdingEntity) then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
	end;
	
	player.nextPunchTime = curTime + 1;
	player.holdingEntity = nil;
	player.holdingGrab = nil;
	
	return entity;
end;

-- A function to foorce a player to pickup an entity.
function PLUGIN:ForcePickup(player, entity, trace)
	self:ForceDropEntity(player);
	
	player.holdingGrab = ents.Create("aura_grab");
	player.holdingGrab:SetOwner(player);
	player.holdingGrab:SetPos(trace.HitPos);
	player.holdingGrab:Spawn();
	
	player.holdingGrab:StartMotionController();
	player.holdingGrab:SetComputePosition(trace.HitPos);
	player.holdingGrab:SetPlayer(player);
	player.holdingGrab:SetTarget(entity);
	
	player.holdingEntity = entity;
	player.holdingGrab:SetCollisionGroup(COLLISION_GROUP_WORLD);
	player.holdingGrab:SetNotSolid(true);
	player.holdingGrab:SetNoDraw(true);
	
	entity.holdingGrab = player.holdingGrab;
	
	player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
	
	if (entity:GetClass() == "prop_ragdoll") then
		constraint.Weld(entity, player.holdingGrab, trace.PhysicsBone, 0, 0);
	else
		constraint.Weld(entity, player.holdingGrab, 0, 0, 0);
	end
end;

-- A function to calculate a player's entity position.
function PLUGIN:CalculatePosition(player)
	local holdingGrab = player.holdingGrab;
	local curTime = CurTime();
	local entity = player.holdingEntity;
	
	if ( IsValid(entity) and IsValid(holdingGrab) and player:Alive() and !player:IsRagdolled() ) then
		if ( player:IsUsingHands() ) then
			local shootPosition = player:GetShootPos();
			local isRagdoll = entity:GetClass() == "prop_ragdoll";
			local filter = {holdingGrab, entity, player};
			local length = 32 + entity:BoundingRadius();
			
			if (isRagdoll) then
				length = 0;
			end;
			
			if ( player:KeyDown(IN_FORWARD) ) then
				length = length + (player:GetVelocity():Length() / 2);
			elseif ( player:KeyDown(IN_BACK) and player:KeyDown(IN_SPEED) ) then
				length = -16;
			end;
			
			local trace = util.TraceLine( {
				start = shootPosition,
				endpos = shootPosition + (player:GetAimVector() * length),
				filter = filter
			} );
			
			holdingGrab:SetComputePosition( trace.HitPos - holdingGrab:OBBCenter() );
			
			if (entity:GetClass() == "prop_ragdoll") then
				holdingGrab.computePosition.z = math.min(holdingGrab.computePosition.z, shootPosition.z - 32);
			else
				holdingGrab.computePosition.z = math.min(holdingGrab.computePosition.z, shootPosition.z + 8);
			end;
			
			return true;
		end;
	end;
end;