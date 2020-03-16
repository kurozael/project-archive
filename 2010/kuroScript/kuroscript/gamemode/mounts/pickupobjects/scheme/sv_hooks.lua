--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when a player has disconnected.
function MOUNT:PlayerDisconnected(player)
	self:ForceDropEntity(player);
end;

-- Called when a player attempts to throw a punch.
function MOUNT:PlayerCanThrowPunch(player)
	if ( ValidEntity(player._HoldingEntity) or ( player._NextPunchTime and player._NextPunchTime >= CurTime() ) ) then
		return false;
	end;
end;

-- Called when a player's weapons should be given.
function MOUNT:PlayerGiveWeapons(player)
	if ( kuroScript.config.Get("take_physcannon"):Get() ) then
		kuroScript.player.TakeSpawnWeapon(player, "weapon_physcannon");
	end;
end;

-- Called to get whether an entity is being held.
function MOUNT:GetEntityBeingHeld(entity)
	if ( ValidEntity(entity._HoldingGrab) and !entity:IsPlayer() ) then
		return true;
	end;
end;

-- Called when kuroScript config has changed.
function MOUNT:KuroScriptConfigChanged(key, data, previousValue, newValue)
	if (key == "take_physcannon") then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if (newValue) then
				kuroScript.player.TakeSpawnWeapon(v, "weapon_physcannon");
			else
				kuroScript.player.GiveSpawnWeapon(v, "weapon_physcannon");
			end;
		end;
	end;
end;

-- Called when a player's ragdoll attempts to take damage.
function MOUNT:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	if (ragdoll._NextTakeDamageTime and CurTime() < ragdoll._NextTakeDamageTime) then
		return false;
	elseif ( ValidEntity(ragdoll._HoldingGrab) ) then
		if ( !damageInfo:IsExplosionDamage() and !damageInfo:IsBulletDamage() ) then
			if ( !damageInfo:IsDamageType(DMG_CLUB) and !damageInfo:IsDamageType(DMG_SLASH) ) then
				return false;
			end;
		end;
	end;
end;

-- Called when a player attempts to get up.
function MOUNT:PlayerCanGetUp(player)
	if ( player:GetSharedVar("ks_BeingDragged") ) then
		return false;
	end;
end;

-- Called when a player's shared variables should be set.
function MOUNT:PlayerSetSharedVars(player, curTime)
	if ( player:IsRagdolled() and kuroScript.player.GetUnragdollTime(player) ) then
		local entity = player:GetRagdollEntity();
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			if ( ValidEntity(entity._HoldingGrab) or entity:IsBeingHeld() ) then
				kuroScript.player.PauseUnragdollTime(player);
				
				-- Set some information.
				player:SetSharedVar("ks_BeingDragged", true);
			elseif ( player:GetSharedVar("ks_BeingDragged") ) then
				kuroScript.player.StartUnragdollTime(player);
				
				-- Set some information.
				player:SetSharedVar("ks_BeingDragged", false);
			end;
		else
			player:SetSharedVar("ks_BeingDragged", false);
		end;
	else
		player:SetSharedVar("ks_BeingDragged", false);
	end;
end;

-- Called when a player presses a key.
function MOUNT:KeyPress(player, key)
	if ( player:IsUsingHands() ) then
		if ( !ValidEntity(player._HoldingEntity) ) then
			if (key == IN_ATTACK2) then
				local trace = player:GetEyeTraceNoCursor();
				local entity = trace.Entity;
				local canPickup = nil;
				
				-- Check if a statement is true.
				if (ValidEntity(entity) and trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
					if (ValidEntity( entity:GetPhysicsObject() ) and entity:GetSolid() == SOLID_VPHYSICS) then
						if (entity:GetClass() == "prop_ragdoll" or entity:GetPhysicsObject():GetMass() <= 100) then
							if ( entity:GetPhysicsObject():IsMoveable() and !ValidEntity(entity._HoldingGrab) ) then
								canPickup = true;
							end;
						end;
					end;
					
					-- Check if a statement is true.
					if ( canPickup and !kuroScript.entity.IsDoor(entity) ) then
						self:ForcePickup(player, entity, trace);
					end;
				end;
			end;
		elseif (key == IN_ATTACK) then
			self:ForceThrowEntity(player);
		elseif (key == IN_RELOAD) then
			self:ForceDropEntity(player);
		end;
	end;
end;