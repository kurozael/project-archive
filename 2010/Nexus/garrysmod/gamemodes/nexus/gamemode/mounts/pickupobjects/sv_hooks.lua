--[[
Name: "sv_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when a player's character has unloaded.
function MOUNT:PlayerCharacterUnloaded(player)
	self:ForceDropEntity(player);
end;

-- Called when a player attempts to throw a punch.
function MOUNT:PlayerCanThrowPunch(player)
	if ( IsValid(player.holdingEntity) or ( player.nextPunchTime and player.nextPunchTime >= CurTime() ) ) then
		return false;
	end;
end;

-- Called when a player's weapons should be given.
function MOUNT:PlayerGiveWeapons(player)
	if ( nexus.config.Get("take_physcannon"):Get() ) then
		nexus.player.TakeSpawnWeapon(player, "weapon_physcannon");
	end;
end;

-- Called to get whether an entity is being held.
function MOUNT:GetEntityBeingHeld(entity)
	if ( IsValid(entity.holdingGrab) and !entity:IsPlayer() ) then
		return true;
	end;
end;

-- Called when nexus config has changed.
function MOUNT:NexusConfigChanged(key, data, previousValue, newValue)
	if (key == "take_physcannon") then
		
		for k, v in ipairs( g_Player.GetAll() ) do
			if (newValue) then
				nexus.player.TakeSpawnWeapon(v, "weapon_physcannon");
			else
				nexus.player.GiveSpawnWeapon(v, "weapon_physcannon");
			end;
		end;
	end;
end;

-- Called when a player's ragdoll attempts to take damage.
function MOUNT:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	if (ragdoll.nextTakeDamageTime and CurTime() < ragdoll.nextTakeDamageTime) then
		return false;
	elseif ( IsValid(ragdoll.holdingGrab) ) then
		if ( !damageInfo:IsExplosionDamage() and !damageInfo:IsBulletDamage() ) then
			if ( !damageInfo:IsDamageType(DMG_CLUB) and !damageInfo:IsDamageType(DMG_SLASH) ) then
				return false;
			end;
		end;
	end;
end;

-- Called when a player attempts to get up.
function MOUNT:PlayerCanGetUp(player)
	if ( player:GetSharedVar("sh_BeingDragged") ) then
		return false;
	end;
end;

-- Called when a player's shared variables should be set.
function MOUNT:PlayerSetSharedVars(player, curTime)
	if ( player:IsRagdolled() and nexus.player.GetUnragdollTime(player) ) then
		local entity = player:GetRagdollEntity();
		
		if ( IsValid(entity) ) then
			if ( IsValid(entity.holdingGrab) or entity:IsBeingHeld() ) then
				nexus.player.PauseUnragdollTime(player);
				
				player:SetSharedVar("sh_BeingDragged", true);
			elseif ( player:GetSharedVar("sh_BeingDragged") ) then
				nexus.player.StartUnragdollTime(player);
				
				player:SetSharedVar("sh_BeingDragged", false);
			end;
		else
			player:SetSharedVar("sh_BeingDragged", false);
		end;
	else
		player:SetSharedVar("sh_BeingDragged", false);
	end;
end;

-- Called when a player presses a key.
function MOUNT:KeyPress(player, key)
	if ( player:IsUsingHands() ) then
		if ( !IsValid(player.holdingEntity) ) then
			if (key == IN_ATTACK2) then
				local trace = player:GetEyeTraceNoCursor();
				local entity = trace.Entity;
				local canPickup = nil;
				
				if (IsValid(entity) and trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
					if (IsValid( entity:GetPhysicsObject() ) and entity:GetSolid() == SOLID_VPHYSICS) then
						if (entity:GetClass() == "prop_ragdoll" or entity:GetPhysicsObject():GetMass() <= 100) then
							if ( entity:GetPhysicsObject():IsMoveable() and !IsValid(entity.holdingGrab) ) then
								canPickup = true;
							end;
						end;
					end;
					
					if ( canPickup and !nexus.entity.IsDoor(entity) ) then
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