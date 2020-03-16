--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called just after a player spawns.
function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!lightSpawn) then
		self:MakePlayerExitStance(player, true);
	end;
end;
	
-- Called when a player spawns lightly.
function PLUGIN:PostPlayerLightSpawn(player, weapons, ammo, special)
	self:MakePlayerExitStance(player);
end;

-- Called when a player has been ragdolled.
function PLUGIN:PlayerRagdolled(player, state, ragdoll)
	self:MakePlayerExitStance(player, true);
end;

-- Called when a player attempts to fire a weapon.
function PLUGIN:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
	if ( self:IsPlayerInStance(player) ) then
		return false;
	end;
end;

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player, curTime, infoTable)
	local forcedAnimation = player:GetForcedAnimation();
	local isMoving = false;
	local uniqueID = player:UniqueID();
	
	if ( player:KeyDown(IN_FORWARD) or player:KeyDown(IN_BACK) or player:KeyDown(IN_MOVELEFT)
	or player:KeyDown(IN_MOVERIGHT) ) then
		isMoving = true;
	end;
	
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		if (player:GetPos():Distance( player:GetSharedVar("stancePosition") ) > 16
		or !player:IsOnGround() or isMoving) then
			player:SetForcedAnimation(false);
			player.previousPosition = nil;
			player:SetSharedVar( "stancePosition", Vector(0, 0, 0) );
			player:SetSharedVar( "stanceAngles", Angle(0, 0, 0) );
			player:SetSharedVar( "stanceIdle", false );
		end;
	elseif ( self:IsPlayerInStance(player) ) then
		if ( !CloudScript:TimerExists("exit_stance_"..uniqueID) ) then
			CloudScript:CreateTimer("exit_stance_"..uniqueID, 1, 1, function()
				if ( IsValid(player) ) then
					player:SetSharedVar( "stancePosition", Vector(0, 0, 0) );
					player:SetSharedVar( "stanceAngles", Angle(0, 0, 0) );
				end;
			end);
		end;
	end;
end;

-- Called when the player attempts to be ragdolled.
function PLUGIN:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	local forcedAnimation = player:GetForcedAnimation();
	
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		if ( player:Alive() ) then
			return false;
		end;
	end;
end;

-- Called when a player attempts to NoClip.
function PLUGIN:PlayerNoClip(player)
	local forcedAnimation = player:GetForcedAnimation();
	
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		return false;
	end;
end;