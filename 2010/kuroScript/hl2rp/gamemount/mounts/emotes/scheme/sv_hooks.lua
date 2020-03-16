--[[
Name: "sv_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called just after a player spawns.
function MOUNT:PostPlayerSpawn(player, lightSpawn, changeVocation, firstSpawn)
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

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	local forcedAnimation = player:GetForcedAnimation();
	
	-- Check if a statement is true.
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		if (player._StanceLocation) then
			if (player:GetPos():Distance(player._StanceLocation) > 16) then
				player._StanceLocation = nil;
				player._StancePosition = nil;
				
				-- Set some information.
				player:SetForcedAnimation(false);
				player:SetSharedVar("ks_Stance", false);
				player:Freeze(false);
			end;
		end;
		
		-- Set some information.
		return true;
	elseif ( player:GetSharedVar("ks_Stance") ) then
		player:SetSharedVar("ks_Stance", false);
	end;
end;

-- Called when a player starts to move.
function MOUNT:Move(player, moveData)
	local forcedAnimation = player:GetForcedAnimation();
	
	-- Check if a statement is true.
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		player:DrawViewModel(false);
		
		-- Return true to break the function.
		return true;
	end;
end;

-- Called when the player attempts to be ragdolled.
function MOUNT:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	local forcedAnimation = player:GetForcedAnimation();
	
	-- Check if a statement is true.
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		if ( player:Alive() ) then
			return false;
		end;
	end;
end;

-- Called when a player attempts to NoClip.
function MOUNT:PlayerNoClip(player)
	local forcedAnimation = player:GetForcedAnimation();
	
	-- Check if a statement is true.
	if ( forcedAnimation and self.stances[forcedAnimation.animation] ) then
		return false;
	end;
end;