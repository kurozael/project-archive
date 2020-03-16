--[[
Name: "sv_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	if ( player:Alive() and !player:IsRagdolled() and !player:InVehicle() ) then
		if ( !IsValid(player.animatedLegs) ) then
			self:GiveAnimatedLegs(player);
		end;
	else
		self:TakeAnimatedLegs(player);
	end;
	
	if ( IsValid(player.animatedLegs) ) then
		if ( player:IsOnFire() ) then
			if ( !player.animatedLegs:IsOnFire() ) then
				player.animatedLegs:Ignite(999, 0);
			end;
		else
			player.animatedLegs:Extinguish();
		end;
	end;
end;

-- Called when a player enters a vehicle.
function MOUNT:PlayerEnteredVehicle(player, vehicle, class)
	self:TakeAnimatedLegs(player);
end;

-- Called when a player leaves a vehicle.
function MOUNT:PlayerLeaveVehicle(player, vehicle)
	self:TakeAnimatedLegs(player);
end;