--[[
Name: "sv_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called just after a player spawns.
function MOUNT:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!lightSpawn) then
		self:MakePlayerExitStance(player, true);
	end;
end;
	
-- Called when a player spawns lightly.
function MOUNT:PostPlayerLightSpawn(player, weapons, ammo, special)
	self:MakePlayerExitStance(player);
end;

-- Called when a player has been ragdolled.
function MOUNT:PlayerRagdolled(player, state, ragdoll)
	self:MakePlayerExitStance(player, true);
end;

-- Called when a player attempts to fire a weapon.
function MOUNT:PlayerCanFireWeapon(player, raised, weapon, secondary)
	if ( self:IsPlayerInStance(player) ) then
		return false;
	end;
end;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	local forcedAnimation = player:GetForcedAnimation();
	local uniqueID = player:UniqueID();
	
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		if ( player:GetPos():Distance( player:GetSharedVar("sh_StancePosition") ) > 16
		or !player:IsOnGround() ) then
			player:SetForcedAnimation(false);
			player.previousPosition = nil;
			player:SetSharedVar( "sh_StancePosition", Vector(0, 0, 0) );
			player:SetSharedVar( "sh_StanceAngles", Angle(0, 0, 0) );
			player:SetSharedVar( "sh_StanceIdle", false );
		end;
	elseif ( self:IsPlayerInStance(player) ) then
		if ( !NEXUS:TimerExists("Exit Stance: "..uniqueID) ) then
			NEXUS:CreateTimer("Exit Stance: "..uniqueID, 1, 1, function()
				if ( IsValid(player) ) then
					player:SetSharedVar( "sh_StancePosition", Vector(0, 0, 0) );
					player:SetSharedVar( "sh_StanceAngles", Angle(0, 0, 0) );
				end;
			end);
		end;
	end;
end;

-- Called when the player attempts to be ragdolled.
function MOUNT:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	local forcedAnimation = player:GetForcedAnimation();
	
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		if ( player:Alive() ) then
			return false;
		end;
	end;
end;

-- Called when a player attempts to NoClip.
function MOUNT:PlayerNoClip(player)
	local forcedAnimation = player:GetForcedAnimation();
	
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		return false;
	end;
end;