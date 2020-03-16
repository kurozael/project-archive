--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	if ( player:Alive() and !player:IsRagdolled() and !player:InVehicle() ) then
		if ( !ValidEntity(player._AnimatedLegs) ) then
			self:GiveAnimatedLegs(player);
		end;
	else
		self:TakeAnimatedLegs(player);
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(player._AnimatedLegs) ) then
		if ( player:IsOnFire() ) then
			if ( !player._AnimatedLegs:IsOnFire() ) then
				player._AnimatedLegs:Ignite(999, 0);
			end;
		else
			player._AnimatedLegs:Extinguish();
		end;
	end;
end;

-- Called when a player enters a vehicle.
function MOUNT:PlayerEnteredVehicle(player, vehicle, role)
	self:TakeAnimatedLegs(player);
end;

-- Called when a player leaves a vehicle.
function MOUNT:PlayerLeaveVehicle(player, vehicle)
	self:TakeAnimatedLegs(player);
end;