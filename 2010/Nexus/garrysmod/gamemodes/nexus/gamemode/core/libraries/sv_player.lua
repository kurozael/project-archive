--[[
Name: "sv_player.lua".
Product: "nexus".
--]]

nexus.player = {};
nexus.player.property = {};
nexus.player.sharedVars = {};

-- A function to get whether a player is noclipping.
function nexus.player.IsNoClipping(player)
	if ( player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle() ) then
		return true;
	end;
end;

-- A function to get whether a player is an admin.
function nexus.player.IsAdmin(player)
	if ( nexus.player.HasFlags(player, "o") ) then
		return true;
	end;
end;

-- A function to get whether a player can hear another player.
function nexus.player.CanHearPlayer(player, target, allowance)
	if ( nexus.config.Get("messages_must_see_player"):Get() ) then
		return nexus.player.CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;

-- A functon to get all property.
function nexus.player.GetAllProperty()
	return nexus.player.property;
end;

-- A function to register a player's shared variable.
function nexus.player.RegisterSharedVar(name, class, playerOnly)
	nexus.player.sharedVars[name] = {
		playerOnly = playerOnly,
		class = class,
		name = name
	};
end;

-- A function to set a player's action.
function nexus.player.SetAction(player, action, duration, priority, Callback)
	local currentAction = nexus.player.GetAction(player);
	
	if (type(action) != "string" or action == "") then
		NEXUS:DestroyTimer( "Action: "..player:UniqueID() );
		
		player:SetSharedVar("sh_StartActionTime", 0);
		player:SetSharedVar("sh_ActionDuration", 0);
		player:SetSharedVar("sh_Action", "");
		
		return;
	elseif (duration == false or duration == 0) then
		if (currentAction == action) then
			return nexus.player.SetAction(player, false);
		else
			return false;
		end;
	end;
	
	if (player.action) then
		if ( ( priority and priority > player.action[2] ) or currentAction == ""
		or action == player.action[1] ) then
			player.action = nil;
		end;
	end;

	if (!player.action) then
		local curTime = CurTime();
		
		player:SetSharedVar("sh_StartActionTime", curTime);
		player:SetSharedVar("sh_ActionDuration", duration);
		player:SetSharedVar("sh_Action", action);
		
		if (priority) then
			player.action = {action, priority};
		else
			player.action = nil;
		end;
		
		NEXUS:CreateTimer("Action: "..player:UniqueID(), duration, 1, function()
			if (Callback) then
				Callback();
			end;
		end);
	end;
end;

-- A function to set the player's character menu state.
function nexus.player.SetCharacterMenuState(player, state)
	NEXUS:StartDataStream(player, "CharacterMenu", state);
end;

-- A function to get a player's action.
function nexus.player.GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("sh_StartActionTime");
	local actionDuration = player:GetSharedVar("sh_ActionDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("sh_Action");
	
	if (CurTime() < startActionTime + actionDuration) then
		if (percentage) then
			return action, (100 / actionDuration) * (actionDuration - ( (startActionTime + actionDuration) - curTime) );
		else
			return action, actionDuration, startActionTime;
		end;
	else
		return "", 0, 0;
	end;
end;

-- A function to run a nexus command on a player.
function nexus.player.RunNexusCommand(player, command, ...)
	return nexus.command.ConsoleCommand( player, "nx", {command, ...} );
end;

-- A function to get a player's wages name.
function nexus.player.GetWagesName(player)
	return nexus.class.Query( player:Team(), "wagesName", nexus.config.Get("wages_name"):Get() );
end;

-- A function to get whether a player can see an NPC.
function nexus.player.CanSeeNPC(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a player.
function nexus.player.CanSeePlayer(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	elseif (target:GetEyeTraceNoCursor().Entity == player) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see an entity.
function nexus.player.CanSeeEntity(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:LocalToWorld( target:OBBCenter() );
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a position.
function nexus.player.CanSeePosition(player, position, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = player:GetShootPos();
	trace.endpos = position;
	trace.filter = {player};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to update whether a player's weapon is raised.
function nexus.player.UpdateWeaponRaised(player)
	local raised = nexus.player.GetWeaponRaised(player);
	local weapon = player:GetActiveWeapon();
	
	player:SetSharedVar("sh_WeaponRaised", raised);
	
	if ( IsValid(weapon) ) then
		NEXUS:HandleWeaponFireDelay( player, raised, weapon, CurTime() );
	end;
end;

-- A function to get whether a player's weapon is raised.
function nexus.player.GetWeaponRaised(player, getCached)
	if ( !nexus.config.Get("raised_weapon_system"):Get() ) then
		return true;
	end;
	
	if (getCached) then
		return player:GetSharedVar("sh_WeaponRaised");
	end;
	
	local weapon = player:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		if (!weapon.NeverRaised) then
			if (weapon.GetRaised) then
				local raised = weapon:GetRaised();
				
				if (raised != nil) then
					return raised;
				end;
			end;
			
			local class = weapon:GetClass();
			
			if (class != "weapon_physgun" and class != "weapon_physcannon" and class != "gmod_tool") then
				return nexus.mount.Call("GetPlayerWeaponRaised", player, class, weapon);
			else
				return true;
			end;
		end;
	end;
	
	return false;
end;

-- A function to toggle whether a player's weapon is raised.
function nexus.player.ToggleWeaponRaised(player)
	nexus.player.SetWeaponRaised(player, !player.toggleWeaponRaised);
end;

-- A function to set whether a player's weapon is raised.
function nexus.player.SetWeaponRaised(player, raised)
	local weapon = player:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		if (type(raised) == "number") then
			player.autoWeaponRaised = weapon:GetClass();
			player:UpdateWeaponRaised();
			
			NEXUS:CreateTimer("Auto Weapon Raised: "..player:UniqueID(), raised, 1, function()
				if ( IsValid(player) ) then
					player.autoWeaponRaised = nil;
					player:UpdateWeaponRaised();
				end;
			end);
		elseif (raised) then
			if (!player.toggleWeaponRaised) then
				if (weapon.OnRaised) then
					weapon:OnRaised();
				end;
			end;
			
			player.toggleWeaponRaised = weapon:GetClass();
			player.autoWeaponRaised = nil;
			player:UpdateWeaponRaised();
		else
			if (player.toggleWeaponRaised) then
				if (weapon.OnLowered) then
					weapon:OnLowered();
				end;
			end;
			
			player.toggleWeaponRaised = nil;
			player.autoWeaponRaised = nil;
			player:UpdateWeaponRaised();
		end;
	end;
end;

-- A function to setup a player's remove property delays.
function nexus.player.SetupRemovePropertyDelays(player)
	local uniqueID = player:UniqueID();
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( nexus.player.GetAllProperty() ) do
		local removeDelay = nexus.entity.QueryProperty(v, "removeDelay");
		
		if (IsValid(v) and removeDelay) then
			if ( uniqueID == nexus.entity.QueryProperty(v, "uniqueID") ) then
				if ( key == nexus.entity.QueryProperty(v, "key") ) then
					NEXUS:CreateTimer("Remove Delay: "..v:EntIndex(), removeDelay, 1, function(entity)
						if ( IsValid(entity) ) then
							entity:Remove();
						end;
					end, v);
				end;
			end;
		end;
	end;
end;

-- A function to disable a player's property.
function nexus.player.DisableProperty(player)
	local uniqueID = player:UniqueID();
	
	for k, v in pairs( nexus.player.GetAllProperty() ) do
		if ( IsValid(v) and uniqueID == nexus.entity.QueryProperty(v, "uniqueID") ) then
			nexus.entity.SetPropertyVar(v, "owner", NULL);
			
			if ( nexus.entity.QueryProperty(v, "networked") ) then
				v:SetNetworkedEntity("sh_Owner", NULL);
			end;
			
			if (v.SetPlayer) then
				v:SetVar("Founder", NULL);
				v:SetVar("FounderIndex", 0);
				v:SetNetworkedString("FounderName", "");
			end;
		end;
	end;
end;

-- A function to give property to a player.
function nexus.player.GiveProperty(player, entity, networked, removeDelay)
	NEXUS:DestroyTimer( "Remove Delay: "..entity:EntIndex() );
	
	nexus.entity.ClearProperty(entity);
	
	entity.property = {
		key = player:QueryCharacter("key"),
		owner = player,
		owned = true,
		uniqueID = player:UniqueID(),
		networked = networked,
		removeDelay = removeDelay
	};
	
	if ( IsValid(player) ) then
		if (entity.SetPlayer) then
			entity:SetPlayer(player);
		end;
		
		if (networked) then
			entity:SetNetworkedEntity("sh_Owner", player);
		end;
	end;
	
	entity:SetNetworkedBool("sh_Owned", true);
	
	nexus.player.GetAllProperty()[ entity:EntIndex() ] = entity;
	
	nexus.mount.Call("PlayerPropertyGiven", player, entity, networked, removeDelay);
end;

-- A function to give property to an offline player.
function nexus.player.GivePropertyOffline(key, uniqueID, entity, networked, removeDelay)
	nexus.entity.ClearProperty(entity);
	
	if (key and uniqueID) then
		local propertyUniqueID = nexus.entity.QueryProperty(entity, "uniqueID");
		local owner = player.GetByUniqueID(uniqueID);
		
		if (owner) then
			if (owner:QueryCharacter("key") != key) then
				owner = nil;
			else
				nexus.player.GiveProperty(owner, entity, networked, removeDelay);
				
				return;
			end;
		end;
		
		if (propertyUniqueID) then
			NEXUS:DestroyTimer("Remove Delay: "..entity:EntIndex().." "..propertyUniqueID);
		end;
		
		entity.property = {
			key = key,
			owner = owner,
			owned = true,
			uniqueID = uniqueID,
			networked = networked,
			removeDelay = removeDelay
		};
		
		if ( IsValid(entity.property.owner) ) then
			if (entity.SetPlayer) then
				entity:SetPlayer(entity.property.owner);
			end;
			
			if (networked) then
				entity:SetNetworkedEntity("sh_Owner", entity.property.owner);
			end;
		end;
		
		entity:SetNetworkedBool("sh_Owned", true);
		
		nexus.player.GetAllProperty()[ entity:EntIndex() ] = entity;
		
		nexus.mount.Call("PlayerPropertyGivenOffline", key, uniqueID, entity, networked, removeDelay);
	end;
end;

-- A function to take property from an offline player.
function nexus.player.TakePropertyOffline(key, uniqueID, entity)
	if (key and uniqueID) then
		local owner = player.GetByUniqueID(uniqueID);
		
		if (owner and owner:QueryCharacter("key") == key) then
			nexus.player.TakeProperty(owner, entity);
			
			return;
		end;
		
		if (nexus.entity.QueryProperty(entity, "uniqueID") == uniqueID) then
			if (nexus.entity.QueryProperty(entity, "key") == key) then
				entity.property = nil;
				
				entity:SetNetworkedEntity("sh_Owner", NULL);
				entity:SetNetworkedBool("sh_Owned", false);
				
				if (entity.SetPlayer) then
					entity:SetVar("Founder", nil);
					entity:SetVar("FounderIndex", nil);
					entity:SetNetworkedString("FounderName", "");
				end;
				
				nexus.player.GetAllProperty()[ entity:EntIndex() ] = nil;
				
				nexus.mount.Call("PlayerPropertyTakenOffline", key, uniqueID, entity);
			end;
		end;
	end;
end;

-- A function to take property from a player.
function nexus.player.TakeProperty(player, entity)
	if (nexus.entity.GetOwner(entity) == player) then
		entity.property = nil;
		
		entity:SetNetworkedEntity("sh_Owner", NULL);
		entity:SetNetworkedBool("sh_Owned", false);
		
		if (entity.SetPlayer) then
			entity:SetVar("Founder", nil);
			entity:SetVar("FounderIndex", nil);
			entity:SetNetworkedString("FounderName", "");
		end;
		
		nexus.player.GetAllProperty()[ entity:EntIndex() ] = nil;
		
		nexus.mount.Call("PlayerPropertyTaken", player, entity);
	end;
end;

-- A function to set a player to their default skin.
function nexus.player.SetDefaultSkin(player)
	player:SetSkin( nexus.player.GetDefaultSkin(player) );
end;

-- A function to get a player's default skin.
function nexus.player.GetDefaultSkin(player)
	return nexus.mount.Call("GetPlayerDefaultSkin", player);
end;

-- A function to set a player to their default model.
function nexus.player.SetDefaultModel(player)
	player:SetModel( nexus.player.GetDefaultModel(player) );
end;

-- A function to get a player's default model.
function nexus.player.GetDefaultModel(player)
	return nexus.mount.Call("GetPlayerDefaultModel", player);
end;

-- A function to get whether a player is drunk.
function nexus.player.GetDrunk(player)
	if (player.drunk) then return #player.drunk; end;
end;

-- A function to set whether a player is drunk.
function nexus.player.SetDrunk(player, expire)
	local curTime = CurTime();
	
	if (expire == false) then
		player.drunk = nil;
	elseif (!player.drunk) then
		player.drunk = {curTime + expire};
	else
		player.drunk[#player.drunk + 1] = curTime + expire;
	end;
	
	player:SetSharedVar("sh_Drunk", nexus.player.GetDrunk(player) or 0);
end;

-- A function to strip a player's default ammo.
function nexus.player.StripDefaultAmmo(player, weapon, itemTable)
	if (!itemTable) then
		itemTable = nexus.item.GetWeapon(weapon);
	end;
	
	if (itemTable) then
		if (itemTable.primaryDefaultAmmo) then
			local ammoClass = weapon:GetPrimaryAmmoType();
			
			if (weapon:Clip1() != -1) then
				weapon:SetClip1(0);
			end;
			
			if (type(itemTable.primaryDefaultAmmo) == "number") then
				player:SetAmmo(math.max(player:GetAmmoCount(ammoClass) - itemTable.primaryDefaultAmmo, 0), ammoClass);
			end;
		end;
		
		if (itemTable.secondaryDefaultAmmo) then
			local ammoClass = weapon:GetSecondaryAmmoType();
			
			if (weapon:Clip2() != -1) then
				weapon:SetClip2(0);
			end;
			
			if (type(itemTable.secondaryDefaultAmmo) == "number") then
				player:SetAmmo(math.max(player:GetAmmoCount(ammoClass) - itemTable.secondaryDefaultAmmo, 0), ammoClass);
			end;
		end;
	end;
end;

-- A function to restore a player's secondary ammo.
function nexus.player.RestoreSecondaryAmmo(player)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if ( IsValid(weapon) ) then
		local spawnAmmo = nexus.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if (weapon:Clip2() != -1) then
			if ( ammo["s_"..class] ) then
				weapon:SetClip2( ammo["s_"..class] );
			elseif ( nexus.player.GetSpawnWeapon(player, class) ) then
				if ( spawnAmmo["s_"..class] ) then
					weapon:SetClip2( spawnAmmo["s_"..class] );
				end;
			end;
		end;
	end;
end;

-- A function to restore a player's primary ammo.
function nexus.player.RestorePrimaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if ( IsValid(weapon) ) then
		local spawnAmmo = nexus.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if (weapon:Clip1() != -1) then
			if ( ammo["p_"..class] ) then
				weapon:SetClip1( ammo["p_"..class] );
			elseif ( nexus.player.GetSpawnWeapon(player, class) ) then
				if ( spawnAmmo["p_"..class] ) then
					weapon:SetClip1( spawnAmmo["p_"..class] );
				end;
			end;
		end;
	end;
end;

-- A function to save a player's secondary ammo.
function nexus.player.SaveSecondaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if ( IsValid(weapon) ) then
		local spawnAmmo = nexus.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if (weapon:Clip2() >= 0) then
			if ( nexus.player.GetSpawnWeapon(player, class) ) then
				spawnAmmo["s_"..class] = weapon:Clip2();
				
				if (spawnAmmo["s_"..class] == 0) then
					spawnAmmo["s_"..class] = nil;
				end;
			else
				ammo["s_"..class] = weapon:Clip2();
				
				if (ammo["s_"..class] == 0) then
					ammo["s_"..class] = nil;
				end;
			end;
		end;
	end;
end;

-- A function to save a player's primary ammo.
function nexus.player.SavePrimaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if ( IsValid(weapon) ) then
		local spawnAmmo = nexus.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if (weapon:Clip1() >= 0) then
			if ( nexus.player.GetSpawnWeapon(player, class) ) then
				spawnAmmo["p_"..class] = weapon:Clip1();
				
				if (spawnAmmo["p_"..class] == 0) then
					spawnAmmo["p_"..class] = nil;
				end;
			else
				ammo["p_"..class] = weapon:Clip1();
				
				if (ammo["p_"..class] == 0) then
					ammo["p_"..class] = nil;
				end;
			end;
		end;
	end;
end;

-- A function to get a player's secondary ammo.
function nexus.player.GetSecondaryAmmo(player, class, bNotSpawn)
	local spawnAmmo = nexus.player.GetSpawnAmmo(player);
	local ammo = player:QueryCharacter("ammo");
	
	if (spawnAmmo["s_"..class] and spawnAmmo["s_"..class] > 0 and !bNotSpawn) then
		return spawnAmmo["s_"..class];
	elseif (ammo["s_"..class] and ammo["s_"..class] > 0) then
		return ammo["s_"..class];
	else
		return 0;
	end;
end;

-- A function to get a player's primary ammo.
function nexus.player.GetPrimaryAmmo(player, class, bNotSpawn)
	local spawnAmmo = nexus.player.GetSpawnAmmo(player);
	local ammo = player:QueryCharacter("ammo");
	
	if (spawnAmmo["p_"..class] and spawnAmmo["p_"..class] > 0 and !bNotSpawn) then
		return spawnAmmo["p_"..class];
	elseif (ammo["p_"..class] and ammo["p_"..class] > 0) then
		return ammo["p_"..class];
	else
		return 0;
	end;
end;

-- A function to set a player's secondary ammo.
function nexus.player.SetSecondaryAmmo(player, class, amount)
	player:QueryCharacter("ammo")["s_"..class] = amount;
	
	if ( player:HasWeapon(class) ) then
		player:GetWeapon(class):SetClip2(amount);
	end;
end;

-- A function to set a player's primary ammo.
function nexus.player.SetPrimaryAmmo(player, class, amount)
	player:QueryCharacter("ammo")["p_"..class] = amount;
	
	if ( player:HasWeapon(class) ) then
		player:GetWeapon(class):SetClip1(amount);
	end;
end;

-- A function to take a player's secondary ammo.
function nexus.player.TakeSecondaryAmmo(player, class)
	local ammo = player:QueryCharacter("ammo");
	
	if (ammo["s_"..class] and ammo["s_"..class] > 0) then
		local amount = ammo["s_"..class];
			ammo["s_"..class] = nil;
			
		if ( player:HasWeapon(class) ) then
			player:GetWeapon(class):SetClip2(0);
		end;
		
		return amount;
	else
		return 0;
	end;
end;

-- A function to take a player's primary ammo.
function nexus.player.TakePrimaryAmmo(player, class)
	local ammo = player:QueryCharacter("ammo");
	
	if (ammo["p_"..class] and ammo["p_"..class] > 0) then
		local amount = ammo["p_"..class];
			ammo["p_"..class] = nil;
			
		if ( player:HasWeapon(class) ) then
			player:GetWeapon(class):SetClip1(0);
		end;
		
		return amount;
	else
		return 0;
	end;
end;

-- A function to check if a player is whitelisted for a faction.
function nexus.player.IsWhitelisted(player, faction)
	return table.HasValue(player:GetData("whitelisted"), faction);
end;

-- A function to set whether a player is whitelisted for a faction.
function nexus.player.SetWhitelisted(player, faction, boolean)
	local whitelisted = player:GetData("whitelisted");
	
	if (boolean) then
		if ( !nexus.player.IsWhitelisted(player, faction) ) then
			whitelisted[#whitelisted + 1] = faction;
		end;
	else
		for k, v in pairs(whitelisted) do
			if (v == faction) then
				whitelisted[k] = nil;
			end;
		end;
	end;
	
	NEXUS:StartDataStream( player, "SetWhitelisted", {faction, boolean} );
end;

-- A function to create a Condition timer.
function nexus.player.ConditionTimer(player, delay, Condition, Callback)
	delay = CurTime() + delay; local uniqueID = player:UniqueID();
	
	if (player.conditionTimer) then
		player.conditionTimer.Callback(false);
		player.conditionTimer = nil;
	end;
	
	player.conditionTimer = {
		delay = delay,
		Callback = Callback,
		Condition = Condition
	};
	
	NEXUS:CreateTimer("Condition Timer: "..uniqueID, 0, 0, function()
		if ( IsValid(player) ) then
			if ( Condition() ) then
				if (CurTime() >= delay) then
					Callback(true); player.conditionTimer = nil;
					
					NEXUS:DestroyTimer("Condition Timer: "..uniqueID);
				end;
			else
				Callback(false); player.conditionTimer = nil;
				
				NEXUS:DestroyTimer("Condition Timer: "..uniqueID);
			end;
		else
			NEXUS:DestroyTimer("Condition Timer: "..uniqueID);
		end;
	end);
end;

-- A function to create an entity Condition timer.
function nexus.player.EntityConditionTimer(player, target, entity, delay, distance, Condition, Callback)
	delay = CurTime() + delay; entity = entity or target;
	
	local uniqueID = player:UniqueID();
	
	if (player.entityConditionTimer) then
		player.entityConditionTimer.Callback(false);
		player.entityConditionTimer = nil;
	end;
	
	player.entityConditionTimer = {
		delay = delay,
		target = target,
		entity = entity,
		distance = distance,
		Callback = Callback,
		Condition = Condition
	};
	
	NEXUS:CreateTimer("Entity Condition Timer: "..uniqueID, 0, 0, function()
		if ( IsValid(player) ) then
			local trace = player:GetEyeTraceNoCursor();
			
			if ( IsValid(target) and IsValid(entity) and trace.Entity == entity
			and trace.Entity:GetPos():Distance( player:GetShootPos() ) <= distance and Condition() ) then
				if (CurTime() >= delay) then
					Callback(true); player.entityConditionTimer = nil;
					
					NEXUS:DestroyTimer("Entity Condition Timer: "..uniqueID);
				end;
			else
				Callback(false); player.entityConditionTimer = nil;
				
				NEXUS:DestroyTimer("Entity Condition Timer: "..uniqueID);
			end;
		else
			NEXUS:DestroyTimer("Entity Condition Timer: "..uniqueID);
		end;
	end);
end;

-- A function to get a player's spawn ammo.
function nexus.player.GetSpawnAmmo(player, ammo)
	if (ammo) then
		return player.spawnAmmo[ammo];
	else
		return player.spawnAmmo;
	end;
end;

-- A function to get a player's spawn weapon.
function nexus.player.GetSpawnWeapon(player, weapon)
	if (weapon) then
		return player.spawnWeapons[weapon];
	else
		return player.spawnWeapons;
	end;
end;

-- A function to take spawn ammo from a player.
function nexus.player.TakeSpawnAmmo(player, ammo, amount)
	if ( player.spawnAmmo[ammo] ) then
		if (player.spawnAmmo[ammo] < amount) then
			amount = player.spawnAmmo[ammo];
			
			player.spawnAmmo[ammo] = nil;
		else
			player.spawnAmmo[ammo] = player.spawnAmmo[ammo] - amount;
		end;
		
		player:RemoveAmmo(amount, ammo);
	end;
end;

-- A function to give the player spawn ammo.
function nexus.player.GiveSpawnAmmo(player, ammo, amount)
	if ( player.spawnAmmo[ammo] ) then
		player.spawnAmmo[ammo] = player.spawnAmmo[ammo] + amount;
	else
		player.spawnAmmo[ammo] = amount;
	end;
	
	player:GiveAmmo(amount, ammo);
end;

-- A function to take a player's spawn weapon.
function nexus.player.TakeSpawnWeapon(player, class)
	player.spawnWeapons[class] = nil;
	
	player:StripWeapon(class);
end;

-- A function to give a player a spawn weapon.
function nexus.player.GiveSpawnWeapon(player, class, uniqueID)
	player.spawnWeapons[class] = true;
	
	player:Give(class, uniqueID);
end;

-- A function to give a player an item weapon.
function nexus.player.GiveItemWeapon(player, item)
	local itemTable = nexus.item.Get(item);
	
	if ( nexus.item.IsWeapon(itemTable) ) then
		player:Give(itemTable.weaponClass, itemTable.uniqueID);
		
		return true;
	end;
end;

-- A function to give a player a spawn item weapon.
function nexus.player.GiveSpawnItemWeapon(player, item)
	local itemTable = nexus.item.Get(item);
	
	if ( nexus.item.IsWeapon(itemTable) ) then
		player.spawnWeapons[itemTable.weaponClass] = true;
		
		player:Give(itemTable.weaponClass, itemTable.uniqueID);
		
		return true;
	end;
end;

-- A function to give flags to a player.
function nexus.player.GiveFlags(player, flags)
	for i = 1, string.len(flags) do
		local flag = string.sub(flags, i, i);
		
		if ( !string.find(player:QueryCharacter("flags"), flag) ) then
			player:SetCharacterData("flags", player:QueryCharacter("flags")..flag, true);
			
			nexus.mount.Call("PlayerFlagsGiven", player, flag);
		end;
	end;
end;

-- A function to play a sound to a player.
function nexus.player.PlaySound(player, sound)
	umsg.Start("nx_PlaySound", player);
		umsg.String(sound);
	umsg.End();
end;

-- A function to get a player's maximum characters.
function nexus.player.GetMaximumCharacters(player)
	local maximum = nexus.config.Get("additional_characters"):Get();
	
	for k, v in pairs(nexus.faction.stored) do
		if ( !v.whitelist or nexus.player.IsWhitelisted(player, v.name) ) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

-- A function to query a player's character.
function nexus.player.Query(player, key, default)
	local character = player:GetCharacter();
	
	if (character) then
		return character[key] or default;
	else
		return default;
	end;
end;

-- A function to set a player to a safe position.
function nexus.player.SetSafePosition(player, position, filter)
	position = nexus.player.GetSafePosition(player, position, filter);
	
	if (position) then
		player:SetMoveType(MOVETYPE_NOCLIP);
		player:SetPos(position);
		
		if ( player:IsInWorld() ) then
			player:SetMoveType(MOVETYPE_WALK);
		else
			player:Spawn();
		end;
	end;
end;

-- A function to get the safest position near a position.
function nexus.player.GetSafePosition(player, position, filter)
	local closestPosition = nil;
	local distanceAmount = 8;
	local directions = {};
	local yawForward = player:EyeAngles().yaw;
	local angles = {
		math.NormalizeAngle(yawForward - 180),
		math.NormalizeAngle(yawForward - 135),
		math.NormalizeAngle(yawForward + 135),
		math.NormalizeAngle(yawForward + 45),
		math.NormalizeAngle(yawForward + 90),
		math.NormalizeAngle(yawForward - 45),
		math.NormalizeAngle(yawForward - 90),
		math.NormalizeAngle(yawForward)
	};
	
	position = position + Vector(0, 0, 32);
	
	if (!filter) then
		filter = {player};
	elseif (type(filter) != "table") then
		filter = {filter};
	end;
	
	if ( !table.HasValue(filter, player) ) then
		filter[#filter + 1] = player;
	end;
	
	for i = 1, 8 do
		for k, v in ipairs(angles) do
			directions[#directions + 1] = {v, distanceAmount};
		end;
		
		distanceAmount = distanceAmount * 2;
	end;
	
	-- A function to get a lower position.
	local function GetLowerPosition(testPosition, ignoreHeight)
		local trace = {
			filter = filter,
			endpos = testPosition - Vector(0, 0, 256),
			start = testPosition
		};
		
		return util.TraceLine(trace).HitPos + Vector(0, 0, 32);
	end;
	
	local trace = {
		filter = filter,
		endpos = position + Vector(0, 0, 256),
		start = position
	};
	
	local safePosition = GetLowerPosition(util.TraceLine(trace).HitPos);
	
	if (safePosition) then
		position = safePosition;
	end;
	
    for k, v in ipairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + ( angleVector * v[2] );
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		local traceLine = util.TraceEntity(trace, player);
		
		if (traceLine.Hit) then
			trace = {
				filter = filter,
				endpos = traceLine.HitPos - ( angleVector * v[2] ),
				start = traceLine.HitPos
			};
			
			traceLine = util.TraceEntity(trace, player);
			
			if (!traceLine.Hit) then
				position = traceLine.HitPos;
			end;
		end;
		
		if (!traceLine.Hit) then
			break;
		end;
    end;
	
    for k, v in ipairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + ( angleVector * v[2] );
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		local traceLine = util.TraceEntity(trace, player);
		
		if (!traceLine.Hit) then
			return traceLine.HitPos;
		end;
    end;
	
	return position;
end;

-- A function to return a player's property.
function nexus.player.ReturnProperty(player)
	local uniqueID = player:UniqueID();
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( nexus.player.GetAllProperty() ) do
		if ( IsValid(v) ) then
			if ( uniqueID == nexus.entity.QueryProperty(v, "uniqueID") ) then
				if ( key == nexus.entity.QueryProperty(v, "key") ) then
					nexus.player.GiveProperty( player, v, nexus.entity.QueryProperty(v, "networked") );
				end;
			end;
		end;
	end;
	
	nexus.mount.Call("PlayerReturnProperty", player);
end;

-- A function to take flags from a player.
function nexus.player.TakeFlags(player, flags)
	for i = 1, string.len(flags) do
		local flag = string.sub(flags, i, i);
		
		if ( string.find(player:QueryCharacter("flags"), flag) ) then
			player:SetCharacterData("flags", string.gsub(player:QueryCharacter("flags"), flag, ""), true);
			
			nexus.mount.Call("PlayerFlagsTaken", player, flag);
		end;
	end;
end;

-- A function to set whether a player's menu is open.
function nexus.player.SetMenuOpen(player, boolean)
	umsg.Start("nx_MenuOpen", player);
		umsg.Bool(boolean);
	umsg.End();
end;

-- A function to set whether a player has intialized.
function nexus.player.SetInitialized(player, initialized)
	player:SetSharedVar("sh_Initialized", initialized);
end;

-- A function to check if a player has any flags.
function nexus.player.HasAnyFlags(player, flags, default)
	if ( player:GetCharacter() ) then
		local playerFlags = player:QueryCharacter("flags");
		
		if ( nexus.class.HasAnyFlags(player:Team(), flags) and !default ) then
			return true;
		else
			-- local i;
			
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success = true;
				
				if (!default) then
					local hasFlag = nexus.mount.Call("PlayerDoesHaveFlag", player, flag);
					
					if (hasFlag != false) then
						if (hasFlag) then
							return true;
						end;
					else
						success = nil;
					end;
				end;
				
				if (success) then
					if (flag == "s") then
						if ( player:IsSuperAdmin() ) then
							return true;
						end;
					elseif (flag == "a") then
						if ( player:IsAdmin() ) then
							return true;
						end;
					elseif (flag == "o") then
						if ( player:IsSuperAdmin() or player:IsAdmin() ) then
							return true;
						elseif ( player:IsUserGroup("operator") ) then
							return true;
						end;
					elseif ( string.find(playerFlags, flag) ) then
						return true;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to check if a player has flags.
function nexus.player.HasFlags(player, flags, default)
	if ( player:GetCharacter() ) then
		local playerFlags = player:QueryCharacter("flags");
		
		if ( nexus.class.HasFlags(player:Team(), flags) and !default ) then
			return true;
		else
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success;
				
				if (!default) then
					local hasFlag = nexus.mount.Call("PlayerDoesHaveFlag", player, flag);
					
					if (hasFlag != false) then
						if (hasFlag) then
							success = true;
						end;
					else
						return;
					end;
				end;
				
				if (!success) then
					if (flag == "s") then
						if ( !player:IsSuperAdmin() ) then
							return;
						end;
					elseif (flag == "a") then
						if ( !player:IsAdmin() ) then
							return;
						end;
					elseif (flag == "o") then
						if ( !player:IsSuperAdmin() and !player:IsAdmin() ) then
							if ( !player:IsUserGroup("operator") ) then
								return;
							end;
						end;
					elseif ( !string.find(playerFlags, flag) ) then
						return;
					end;
				end;
			end;
		end;
		
		return true;
	end;
end;

-- A function to use a player's death code.
function nexus.player.UseDeathCode(player, commandTable, arguments)
	nexus.mount.Call("PlayerDeathCodeUsed", player, commandTable, arguments);
	
	nexus.player.TakeDeathCode(player);
end;

-- A function to get whether a player has a death code.
function nexus.player.GetDeathCode(player, authenticated)
	if ( player.deathCode and (!authenticated or player.deathCodeAuthenticated) ) then
		return player.deathCode;
	end;
end;

-- A function to take a player's death code.
function nexus.player.TakeDeathCode(player)
	player.deathCodeAuthenticated = nil;
	player.deathCode = nil;
end;

-- A function to give a player their death code.
function nexus.player.GiveDeathCode(player)
	player.deathCode = math.random(0, 99999);
	player.deathCodeAuthenticated = nil;
	
	umsg.Start("nx_ChatBoxDeathCode", player);
		umsg.Long(player.deathCode);
	umsg.End();
end;

-- A function to take a door from a player.
function nexus.player.TakeDoor(player, door, force, thisDoorOnly, childrenOnly)
	local doorCost = nexus.config.Get("door_cost"):Get();
	
	if (!thisDoorOnly) then
		local doorParent = nexus.entity.GetDoorParent(door);
		
		if (doorParent and !childrenOnly) then
			return nexus.player.TakeDoor(player, doorParent, force);
		else
			for k, v in pairs( nexus.entity.GetDoorChildren(door) ) do
				if ( IsValid(v) ) then
					nexus.player.TakeDoor(player, v, true, true);
				end;
			end;
		end;
	end;
	
	if ( nexus.mount.Call("PlayerCanUnlockEntity", player, door) ) then
		door:Fire("Unlock", "", 0);
		door:EmitSound("doors/door_latch3.wav");
	end;
	
	nexus.entity.SetDoorText(door, false);
	nexus.player.TakeProperty(player, door)
	
	if (door:GetClass() == "prop_dynamic") then
		if ( !door:IsMapEntity() ) then
			door:Remove();
		end;
	end;
	
	if (!force and doorCost > 0) then
		nexus.player.GiveCash(player, doorCost / 2, "selling a door");
	end;
end;

-- A function to make a player say text as a radio broadcast.
function nexus.player.SayRadio(player, text, check, noEavesdrop)
	local eavesdroppers = {};
	local listeners = {};
	local canRadio = true;
	local info = {listeners = {}, noEavesdrop = noEavesdrop, text = text};
	
	nexus.mount.Call("PlayerAdjustRadioInfo", player, info);
	
	for k, v in pairs(info.listeners) do
		if (type(k) == "Player") then
			listeners[k] = k;
		elseif (type(v) == "Player") then
			listeners[v] = v;
		end;
	end;
	
	if (!info.noEavesdrop) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() and !listeners[v] ) then
				if ( v:GetShootPos():Distance( player:GetShootPos() ) <= nexus.config.Get("talk_radius"):Get() ) then
					eavesdroppers[v] = v;
				end;
			end;
		end;
	end;
	
	if (check) then
		canRadio = nexus.mount.Call("PlayerCanRadio", player, info.text, listeners, eavesdroppers);
	end;
	
	if (canRadio) then
		info = nexus.chatBox.Add(listeners, player, "radio", info.text);
		
		if ( info and IsValid(info.speaker) ) then
			nexus.chatBox.Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			
			nexus.mount.Call("PlayerRadioUsed", player, info.text, listeners, eavesdroppers);
		end;
	end;
end;

-- A function to get a player's faction table.
function nexus.player.GetFactionTable(player)
	return nexus.faction.stored[ player:QueryCharacter("faction") ];
end;

-- A function to give a door to a player.
function nexus.player.GiveDoor(player, door, name, unsellable, override)
	if ( nexus.entity.IsDoor(door) ) then
		local doorParent = nexus.entity.GetDoorParent(door);
		
		if (doorParent and !override) then
			nexus.player.GiveDoor(player, doorParent, name, unsellable);
		else
			for k, v in pairs( nexus.entity.GetDoorChildren(door) ) do
				if ( IsValid(v) ) then
					nexus.player.GiveDoor(player, v, name, unsellable, true);
				end;
			end;
			
			door.unsellable = unsellable;
			door.accessList = {};
			
			nexus.entity.SetDoorText(door, name or "A purchased door.");
			nexus.player.GiveProperty(player, door, true);
			
			if ( nexus.mount.Call("PlayerCanUnlockEntity", player, door) ) then
				door:EmitSound("doors/door_latch3.wav");
				door:Fire("Unlock", "", 0);
			end;
		end;
	end;
end;

-- A function to get a player's real trace.
function nexus.player.GetRealTrace(player, useFilterTrace)
	local eyePos = player:EyePos();
	local trace = player:GetEyeTraceNoCursor();
	
	local newTrace = util.TraceLine( {
		endpos = eyePos + (player:GetAimVector() * 4096),
		filter = player,
		start = eyePos,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	} );
	
	if ( (IsValid(newTrace.Entity) and ( !IsValid(trace.Entity)
	or trace.Entity:IsVehicle() ) and !newTrace.HitWorld) or useFilterTrace ) then
		trace = newTrace;
	end;
	
	return trace;
end;

-- A function to check if a player recognises another player.
function nexus.player.DoesRecognise(player, target, status, simple)
	if (!status) then
		return nexus.player.DoesRecognise(player, target, RECOGNISE_PARTIAL);
	elseif ( nexus.config.Get("recognise_system"):Get() ) then
		local recognisedNames = player:QueryCharacter("recognisedNames");
		local default = false;
		local key = target:QueryCharacter("key");
		
		if ( recognisedNames[key] ) then
			if (simple) then
				default = (recognisedNames[key] == status);
			else
				default = (recognisedNames[key] >= status);
			end;
		end;
		
		return nexus.mount.Call("PlayerDoesRecognisePlayer", player, target, status, simple, default);
	else
		return true;
	end;
end;

-- A function to send a player a creation fault.
function nexus.player.CreationError(player, fault)
	if (!fault) then
		fault = "There has been an unknown error, please contact the administrator!";
	end;
	
	umsg.Start("nx_CharacterFinish", player)
		umsg.Bool(false);
		umsg.String(fault);
	umsg.End();
end;

-- A function to force a player to delete a character.
function nexus.player.ForceDeleteCharacter(player, characterID)
	local charactersTable = nexus.config.Get("mysql_characters_table"):Get();
	local schemaFolder = NEXUS:GetSchemaFolder();
	local character = player.characters[characterID];
	
	if (character) then
		tmysql.query("DELETE FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..player:SteamID().."\" AND _CharacterID = "..characterID);
		
		if ( !nexus.mount.Call("PlayerDeleteCharacter", player, character) ) then
			NEXUS:PrintDebug(player:SteamName().." deleted character '"..character.name.."'.");
		end;
		
		player.characters[characterID] = nil;
		
		umsg.Start("nx_CharacterRemove", player)
			umsg.Short(characterID);
		umsg.End();
	end;
end;

-- A function to delete a player's character.
function nexus.player.DeleteCharacter(player, characterID)
	local character = player.characters[characterID];
	
	if (character) then
		if (player:GetCharacter() != character) then
			local fault = nexus.mount.Call("PlayerCanDeleteCharacter", player, character);
			
			if (fault == nil or fault == true) then
				nexus.player.ForceDeleteCharacter(player, characterID);
				
				return true;
			elseif (type(fault) != "string") then
				return false, "You cannot delete this character!";
			else
				return false, fault;
			end;
		else
			return false, "You cannot delete the character you are using!";
		end;
	else
		return false, "This character does not exist!";
	end;
end;

-- A function to use a player's character.
function nexus.player.UseCharacter(player, characterID)
	local currentCharacter = player:GetCharacter();
	local character = player.characters[characterID];
	
	if (character) then
		if (currentCharacter != character) then
			local factionTable = nexus.faction.Get(character.faction);
			local fault = nexus.mount.Call("PlayerCanUseCharacter", player, character);
			
			if (fault == nil or fault == true) then
				local players = #nexus.faction.GetPlayers(character.faction);
				local limit = nexus.faction.GetLimit(factionTable.name);
				
				if ( nexus.mount.Call("PlayerCanBypassFactionLimit", player, character) ) then
					limit = nil;
				end;
				
				if (limit and players == limit) then
					return false, "The "..character.faction.." faction is full ("..limit.."/"..limit..")!";
				else
					if (currentCharacter) then
						local fault = nexus.mount.Call("PlayerCanSwitchCharacter", player, character);
						
						if (fault != nil and fault != true) then
							return false, fault or "You cannot switch to this character!";
						end;
					end;
					
					NEXUS:PrintDebug(player:SteamName().." has loaded the character '"..character.name.."'.");
					
					nexus.player.LoadCharacter(player, characterID);
					
					return true;
				end;
			else
				return false, fault or "You cannot use this character!";
			end;
		else
			return false, "You are already using this character!";
		end;
	else
		return false, "This character does not exist!";
	end;
end;

-- A function to get a player's character.
function nexus.player.GetCharacter(player)
	return player.character;
end;

-- A function to get a player's storage entity.
function nexus.player.GetStorageEntity(player)
	if ( player:GetStorageTable() ) then
		local entity = nexus.player.QueryStorage(player, "entity");
		
		if ( IsValid(entity) ) then return entity; end;
	end;
end;

-- A function to get a player's storage table.
function nexus.player.GetStorageTable(player)
	return player.storage;
end;

-- A function to query a player's storage.
function nexus.player.QueryStorage(player, key, default)
	local storage = player:GetStorageTable();
	
	if (storage) then
		return storage[key] or default;
	else
		return default;
	end;
end;

-- A function to close storage for a player.
function nexus.player.CloseStorage(player, server)
	local storage = player:GetStorageTable();
	local OnClose = nexus.player.QueryStorage(player, "OnClose");
	local entity = nexus.player.QueryStorage(player, "entity");
	
	if (storage and OnClose) then
		OnClose(player, storage, entity);
	end;
	
	if (!server) then
		umsg.Start("nx_StorageClose", player);
		umsg.End();
	end;
	
	player.storage = nil;
end;

-- A function to get the weight of a player's storage.
function nexus.player.GetStorageWeight(player)
	if ( player:GetStorageTable() ) then
		local inventory = nexus.player.QueryStorage(player, "inventory");
		local cash = nexus.player.QueryStorage(player, "cash");
		local weight = ( cash * nexus.config.Get("cash_weight"):Get() );
		
		if ( nexus.player.QueryStorage(player, "noCashWeight") ) then
			weight = 0;
		end;
		
		for k, v in pairs(inventory) do
			local itemTable = nexus.item.Get(k);
			
			if (itemTable) then
				weight = weight + (math.max(itemTable.storageWeight or itemTable.weight, 0) * v );
			end;
		end;
		
		return weight;
	else
		return 0;
	end;
end;

-- A function to open storage for a player.
function nexus.player.OpenStorage(player, data)
	local storage = player:GetStorageTable();
	local OnClose = nexus.player.QueryStorage(player, "OnClose");
	
	if (storage and OnClose) then
		OnClose(player, storage, storage.entity);
	end;
	
	if ( !nexus.config.Get("cash_enabled"):Get() ) then
		data.cash = nil;
	end;
	
	if (data.noCashWeight == nil) then
		data.noCashWeight = false;
	end;
	
	data.inventory = data.inventory or {};
	data.entity = data.entity or player;
	data.weight = data.weight or nexus.config.Get("default_inv_weight"):Get();
	data.cash = data.cash or 0;
	data.name = data.name or "Storage";
	
	player.storage = data;
	
	umsg.Start("nx_StorageStart", player);
		umsg.Bool(data.noCashWeight);
		umsg.Entity(data.entity);
		umsg.String(data.name);
	umsg.End();
	
	nexus.player.UpdateStorageCash(player, data.cash);
	nexus.player.UpdateStorageWeight(player, data.weight);
	
	for k, v in pairs(data.inventory) do
		nexus.player.UpdateStorageItem(player, k);
	end;
end;

-- A function to update a player's storage cash.
function nexus.player.UpdateStorageCash(player, cash)
	if ( nexus.config.Get("cash_enabled"):Get() ) then
		local storageTable = player:GetStorageTable();
		
		if (storageTable) then
			local inventory = nexus.player.QueryStorage(player, "inventory");
			
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (nexus.player.QueryStorage(v, "inventory") == inventory) then
							v.storage.cash = cash;
							
							umsg.Start("nx_StorageCash", v);
								umsg.Long(cash);
							umsg.End();
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to update a player's storage weight.
function nexus.player.UpdateStorageWeight(player, weight)
	
	if ( player:GetStorageTable() ) then
		local inventory = nexus.player.QueryStorage(player, "inventory");
		
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( v:GetStorageTable() ) then
					if (nexus.player.QueryStorage(v, "inventory") == inventory) then
						v.storage.weight = weight;
						
						umsg.Start("nx_StorageWeight", v);
							umsg.Float(weight);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get whether a player can give to storage.
function nexus.player.CanGiveToStorage(player, item)
	local itemTable = nexus.item.Get(item);
	local entity = nexus.player.QueryStorage(player, "entity");
	
	if (itemTable) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerGive = (!entity:IsPlayer() or itemTable.allowPlayerGive != false);
		local allowEntityGive = (entity:IsPlayer() or itemTable.allowEntityGive != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowGive = (itemTable.allowGive != false);
		local shipment = (entity and entity:GetClass() == "nx_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerGive and allowStorage and allowGive) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can take from storage.
function nexus.player.CanTakeFromStorage(player, item)
	local itemTable = nexus.item.Get(item);
	local entity = nexus.player.QueryStorage(player, "entity");
	
	if (itemTable) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerTake = (!entity:IsPlayer() or itemTable.allowPlayerTake != false);
		local allowEntityTake = (entity:IsPlayer() or itemTable.allowEntityTake != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowTake = (itemTable.allowTake != false);
		local shipment = (entity and entity:GetClass() == "nx_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerTake and allowStorage and allowTake) ) then
			return true;
		end;
	end;
end;

-- A function to update each player's storage for a player.
function nexus.player.UpdateStorageForPlayer(player, item)
	local inventory = nexus.player.GetInventory(player);
	local cash = nexus.player.GetCash(player);
	
	if (item) then
		local itemTable = nexus.item.Get(item);
		
		if (itemTable) then
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (nexus.player.QueryStorage(v, "inventory") == inventory) then
							umsg.Start("nx_StorageItem", v);
								umsg.Long(itemTable.index);
								umsg.Long(inventory[itemTable.uniqueID] or 0);
							umsg.End();
						end;
					end;
				end;
			end;
		end;
	elseif ( nexus.config.Get("cash_enabled"):Get() ) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( v:GetStorageTable() ) then
					if (nexus.player.QueryStorage(v, "inventory") == inventory) then
						v.storage.cash = cash;
						
						umsg.Start("nx_StorageCash", v);
							umsg.Long(cash);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to update a storage item for a player.
function nexus.player.UpdateStorageItem(player, item, amount)
	
	if ( player:GetStorageTable() ) then
		local inventory = nexus.player.QueryStorage(player, "inventory");
		local itemTable = nexus.item.Get(item);
		
		if (itemTable) then
			item = itemTable.uniqueID;
			
			if (amount) then
				if ( amount < 0 and !nexus.player.CanTakeFromStorage(player, item) ) then
					return;
				elseif ( amount > 0 and !nexus.player.CanGiveToStorage(player, item) ) then
					return;
				end;
			end;
			
			if (amount) then
				inventory[item] = inventory[item] or 0;
				inventory[item] = inventory[item] + amount;
			end;
			
			if (inventory[item] and inventory[item] <= 0) then
				inventory[item] = nil;
			end;
			
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (nexus.player.QueryStorage(v, "inventory") == inventory) then
							if (amount or player == v) then
								umsg.Start("nx_StorageItem", v);
									umsg.Long(itemTable.index);
									umsg.Long(inventory[item] or 0);
								umsg.End();
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get a player's gender.
function nexus.player.GetGender(player)
	return player:QueryCharacter("gender");
end;

-- A function to get a player's unrecognised name.
function nexus.player.GetUnrecognisedName(player)
	local unrecognisedPhysDesc = nexus.player.GetPhysDesc(player);
	local unrecognisedName = nexus.config.Get("unrecognised_name"):Get();
	local usedPhysDesc;
	
	if (unrecognisedPhysDesc != "") then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

-- A function to format text based on a relationship.
function nexus.player.FormatRecognisedText(player, text, ...)
	for i = 1, #arg do
		if ( string.find(text, "%%s") and IsValid( arg[i] ) ) then
			local unrecognisedName = "["..nexus.player.GetUnrecognisedName( arg[i] ).."]";
			
			if ( nexus.player.DoesRecognise( player, arg[i] ) ) then
				unrecognisedName = arg[i]:Name();
			end;
			
			text = string.gsub(text, "%%s", unrecognisedName, 1);
		end;
	end;
	
	return text;
end;

-- A function to restore a recognised name.
function nexus.player.RestoreRecognisedName(player, target)
	local recognisedNames = player:QueryCharacter("recognisedNames");
	local key = target:QueryCharacter("key");
	
	if ( recognisedNames[key] ) then
		if ( nexus.mount.Call("PlayerCanRestoreRecognisedName", player, target) ) then
			nexus.player.SetRecognises(player, target, recognisedNames[key], true);
		else
			recognisedNames[key] = nil;
		end;
	end;
end;

-- A function to restore a player's recognised names.
function nexus.player.RestoreRecognisedNames(player)
	umsg.Start("nx_ClearRecognisedNames", player);
	umsg.End();
	
	if ( nexus.config.Get("save_recognised_names"):Get() ) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				nexus.player.RestoreRecognisedName(player, v);
				nexus.player.RestoreRecognisedName(v, player);
			end;
		end;
	end;
end;

-- A function to set whether a player recognises a player.
function nexus.player.SetRecognises(player, target, status, force)
	local recognisedNames = player:QueryCharacter("recognisedNames");
	local name = target:Name();
	local key = target:QueryCharacter("key");
	
	if (status == RECOGNISE_SAVE) then
		if ( nexus.config.Get("save_recognised_names"):Get() ) then
			if ( !nexus.mount.Call("PlayerCanSaveRecognisedName", player, target) ) then
				status = RECOGNISE_TOTAL;
			end;
		else
			status = RECOGNISE_TOTAL;
		end;
	end;
	
	if ( !status or force or !nexus.player.DoesRecognise(player, target, status) ) then
		recognisedNames[key] = status or nil;
		
		status = status or 0;
		
		umsg.Start("nx_RecognisedName", player);
			umsg.Long(key);
			umsg.Short(status);
		umsg.End();
	end;
end;

-- A function to get a player's physical description.
function nexus.player.GetPhysDesc(player)
	local physDesc = player:GetSharedVar("sh_PhysDesc");
	local team = player:Team();
	
	if (physDesc == "") then
		physDesc = nexus.class.Query(team, "defaultPhysDesc", "");
	end;
	
	if (physDesc == "") then
		physDesc = nexus.config.Get("default_physdesc"):Get();
	end;
	
	if (!physDesc or physDesc == "") then
		physDesc = "This character has no physical description set.";
	else
		physDesc = NEXUS:ModifyPhysDesc(physDesc);
	end;
	
	local override = nexus.mount.Call("GetPlayerPhysDescOverride", player, physDesc);
	
	if (override) then
		physDesc = override;
	end;
	
	return physDesc;
end;

-- A function to clear a player's recognised names list.
function nexus.player.ClearRecognisedNames(player, status, simple)
	if (!status) then
		local character = player:GetCharacter();
		
		if (character) then
			character.recognisedNames = {};
			
			umsg.Start("nx_ClearRecognisedNames", player);
			umsg.End();
		end;
	else
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( nexus.player.DoesRecognise(player, v, status, simple) ) then
					nexus.player.SetRecognises(player, v, false);
				end;
			end;
		end;
	end;
	
	nexus.mount.Call("PlayerRecognisedNamesCleared", player, status, simple);
end;

-- A function to clear a player's name from being recognised.
function nexus.player.ClearName(player, status, simple)
	
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( !status or nexus.player.DoesRecognise(v, player, status, simple) ) then
				nexus.player.SetRecognises(v, player, false);
			end;
		end;
	end;
	
	nexus.mount.Call("PlayerNameCleared", player, status, simple);
end;

-- A function to holsters all of a player's weapons.
function nexus.player.HolsterAll(player)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = nexus.item.GetWeapon(v);
		
		if (itemTable) then
			if ( nexus.mount.Call("PlayerCanHolsterWeapon", player, itemTable, true, true) ) then
				player:StripWeapon(class);
				
				player:UpdateInventory(itemTable.uniqueID, 1, true);
				
				nexus.mount.Call("PlayerHolsterWeapon", player, itemTable, true);
			end;
		end;
	end;
	
	player:SelectWeapon("nx_hands");
end;

-- A function to set a shared variable for a player.
function nexus.player.SetSharedVar(player, key, value)
	if ( IsValid(player) ) then
		local sharedVarData = nexus.player.sharedVars[key];
		local playerData = player.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				local class = NEXUS:ConvertUserMessageClass(sharedVarData.class);
				local realValue = value;
				
				if (value == nil) then
					realValue = NEXUS:GetDefaultNetworkedValue(sharedVarData.class);
				end;
				
				if (playerData != realValue) then
					player.sharedVars[key] = realValue;
					
					umsg.Start("nx_SharedVar", player);
						umsg.String(key);
						umsg[class](realValue);
					umsg.End();
				end;
			else
				local class = NEXUS:ConvertNetworkedClass(sharedVarData.class);
				
				if (class) then
					if (value == nil) then
						value = NEXUS:GetDefaultClassValue(class);
					end;
					
					player["SetNetworked"..class](player, key, value);
				else
					player:SetNetworkedVar(key, value);
				end;
			end;
		else
			player:SetNetworkedVar(key, value);
		end;
	end;
end;

-- A function to get a player's shared variable.
function nexus.player.GetSharedVar(player, key)
	if ( IsValid(player) ) then
		local sharedVarData = nexus.player.sharedVars[key];
		local playerData = player.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (!playerData) then
					return NEXUS:GetDefaultNetworkedValue(sharedVarData.class);
				else
					return playerData;
				end;
			else
				local class = NEXUS:ConvertNetworkedClass(sharedVarData.class);
				
				if (class) then
					return player["GetNetworked"..class](player, key);
				else
					return player:GetNetworkedVar(key);
				end;
			end;
		else
			return player:GetNetworkedVar(key);
		end;
	end;
end;

-- A function to set whether a player's character is banned.
function nexus.player.SetBanned(player, banned)
	player:SetCharacterData("banned", banned);
	player:SaveCharacter();
	player:SetSharedVar("sh_Banned", banned);
end;

-- A function to set a player's name.
function nexus.player.SetName(player, name, saveless)
	local previousName = player:QueryCharacter("name");
	local newName = name;
	
	player:SetCharacterData("name", newName, true);
	player:SetSharedVar("sh_Name", newName);
	
	if (!player.firstSpawn) then
		nexus.mount.Call("PlayerNameChanged", player, previousName, newName);
	end;
	
	if (!saveless) then
		player:SaveCharacter();
	end;
end;

-- A function to get a player's property count.
function nexus.player.GetPropertyCount(player, class)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( nexus.player.GetAllProperty() ) do
		if ( uniqueID == nexus.entity.QueryProperty(v, "uniqueID") ) then
			if ( key == nexus.entity.QueryProperty(v, "key") ) then
				if (!class or v:GetClass() == class) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

-- A function to get a player's door count.
function nexus.player.GetDoorCount(player)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( nexus.player.GetAllProperty() ) do
		if ( nexus.entity.IsDoor(v) and !nexus.entity.GetDoorParent(v) ) then
			if ( uniqueID == nexus.entity.QueryProperty(v, "uniqueID") ) then
				if ( player:QueryCharacter("key") == nexus.entity.QueryProperty(v, "key") ) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

-- A function to take a player's door access.
function nexus.player.TakeDoorAccess(player, door)
	if (door.accessList) then
		door.accessList[ player:QueryCharacter("key") ] = false;
	end;
end;

-- A function to give a player door access.
function nexus.player.GiveDoorAccess(player, door, access)
	local key = player:QueryCharacter("key");
	
	if (!door.accessList) then
		door.accessList = {
			[key] = access
		};
	else
		door.accessList[key] = access;
	end;
end;

-- A function to check if a player has door access.
function nexus.player.HasDoorAccess(player, door, access, simple)
	if (!access) then
		return nexus.player.HasDoorAccess(player, door, DOOR_ACCESS_BASIC, simple);
	else
		local doorParent = nexus.entity.GetDoorParent(door);
		local key = player:QueryCharacter("key");
		
		if ( doorParent and nexus.entity.DoorHasSharedAccess(doorParent)
		and (!door.accessList or door.accessList[key] == nil) ) then
			return nexus.mount.Call("PlayerDoesHaveDoorAccess", player, doorParent, access, simple);
		else
			return nexus.mount.Call("PlayerDoesHaveDoorAccess", player, door, access, simple);
		end;
	end;
end;

-- A function to get a player's inventory.
function nexus.player.GetInventory(player)
	return player:QueryCharacter("inventory");
end;

-- A function to get a player's cash.
function nexus.player.GetCash(player)
	if ( nexus.config.Get("cash_enabled"):Get() ) then
		return player:QueryCharacter("cash");
	else
		return 0;
	end;
end;

-- A function to check if a player can afford an amount.
function nexus.player.CanAfford(player, amount)
	if ( nexus.config.Get("cash_enabled"):Get() ) then
		return nexus.player.GetCash(player) >= amount;
	else
		return true;
	end;
end;

-- A function to give a player an amount of cash.
function nexus.player.GiveCash(player, amount, reason, noMessage)
	if ( nexus.config.Get("cash_enabled"):Get() ) then
		local positiveHintColor = nexus.schema.GetColor("positive_hint");
		local negativeHintColor = nexus.schema.GetColor("negative_hint");
		local roundedAmount = math.Round(amount);
		local cash = math.Round( math.max(nexus.player.GetCash(player) + roundedAmount, 0) );
		
		player:SetCharacterData("cash", cash, true);
		player:SetSharedVar("sh_Cash", cash);
		
		if (roundedAmount < 0) then
			roundedAmount = math.abs(roundedAmount);
			
			if (!noMessage) then
				if (reason) then
					nexus.hint.Send(player, "Your character has lost "..FORMAT_CASH(roundedAmount).." ("..reason..").", 4, negativeHintColor);
				else
					nexus.hint.Send(player, "Your character has lost "..FORMAT_CASH(roundedAmount)..".", 4, negativeHintColor);
				end;
			end;
		elseif (roundedAmount > 0) then
			if (!noMessage) then
				if (reason) then
					nexus.hint.Send(player, "Your character has gained "..FORMAT_CASH(roundedAmount).." ("..reason..").", 4, positiveHintColor);
				else
					nexus.hint.Send(player, "Your character has gained "..FORMAT_CASH(roundedAmount)..".", 4, positiveHintColor);
				end;
			end;
		end;
		
		nexus.mount.Call("PlayerCashUpdated", player, roundedAmount, reason, noMessage);
	end;
end;

-- A function to show cinematic text to a player.
function nexus.player.CinematicText(player, text, color, hangTime)
	NEXUS:StartDataStream( player, "CinematicText", {text = text, color = color, hangTime = hangTime} );
end;

-- A function to show cinematic text to each player.
function nexus.player.CinematicTextAll(text, color, hangTime)
	
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			nexus.player.CinematicText(v, text, color, hangTime);
		end;
	end;
end;

-- A function to get a player by a part of their name.
function nexus.player.Get(name)
	
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( string.find(string.lower( v:Name() ), string.lower(name), 1, true) ) then
				return v;
			end;
		end;
	end;
	
	return false;
end;

-- A function to notify each player in a radius.
function nexus.player.NotifyInRadius(text, class, position, radius)
	local listeners = {};
	
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (position:Distance( v:GetPos() ) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;
	
	nexus.player.Notify(listeners, text, class);
end;

-- A function to notify each player.
function nexus.player.NotifyAll(text, class)
	nexus.player.Notify(nil, text, true);
end;

-- A function to notify a player.
function nexus.player.Notify(player, text, class)
	if (type(player) == "table") then
		
		for k, v in ipairs(player) do
			nexus.player.Notify(v, text, class);
		end;
	elseif (class == true) then
		nexus.chatBox.Add(player, nil, "notify_all", text);
	elseif (!class) then
		nexus.chatBox.Add(player, nil, "notify", text);
	else
		umsg.Start("nx_Notification", player);
			umsg.String(text);
			umsg.Short(class);
		umsg.End();
	end;
end;

-- A function to set a player's weapons list from a table.
function nexus.player.SetWeapons(player, weapons, forceReturn)
	for k, v in pairs(weapons) do
		if ( player:HasWeapon( v.weaponData["class"] ) ) then
			if (v.canHolster) then
				local itemTable = nexus.item.GetWeapon( v.weaponData["class"], v.weaponData["uniqueID"] );
				
				if (itemTable) then
					player:UpdateInventory(itemTable.uniqueID, 1, true);
					
					nexus.mount.Call("PlayerHolsterWeapon", player, itemTable, true);
				end;
			end;
		elseif (!v.teamIndex or player:Team() == v.teamIndex) then
			player:Give(v.weaponData["class"], v.weaponData["uniqueID"] , forceReturn);
			
			if ( !player:HasWeapon( v.weaponData["class"] ) ) then
				if (v.canHolster) then
					local itemTable = nexus.item.GetWeapon( v.weaponData["class"], v.weaponData["uniqueID"] );
					
					if (itemTable) then
						player:UpdateInventory(itemTable.uniqueID, 1, true);
						
						nexus.mount.Call("PlayerHolsterWeapon", player, itemTable, true);
					end;
				end;
			end;
		end;
	end;
end;

-- A function to give ammo to a player from a table.
function nexus.player.GiveAmmo(player, ammo)
	for k, v in pairs(ammo) do player:GiveAmmo(v, k); end;
end;

-- A function to set a player's ammo list from a table.
function nexus.player.SetAmmo(player, ammo)
	for k, v in pairs(ammo) do player:SetAmmo(v, k); end;
end;

-- A function to get a player's ammo list as a table.
function nexus.player.GetAmmo(player, strip)
	local spawnAmmo = nexus.player.GetSpawnAmmo(player);
	local ammo = {
		["sniperpenetratedround"] = player:GetAmmoCount("sniperpenetratedround"),
		["striderminigun"] = player:GetAmmoCount("striderminigun"),
		["helicoptergun"] = player:GetAmmoCount("helicoptergun"),
		["combinecannon"] = player:GetAmmoCount("combinecannon"),
		["smg1_grenade"] = player:GetAmmoCount("smg1_grenade"),
		["gaussenergy"] = player:GetAmmoCount("gaussenergy"),
		["sniperround"] = player:GetAmmoCount("sniperround"),
		["airboatgun"] = player:GetAmmoCount("airboatgun"),
		["ar2altfire"] = player:GetAmmoCount("ar2altfire"),
		["rpg_round"] = player:GetAmmoCount("rpg_round"),
		["xbowbolt"] = player:GetAmmoCount("xbowbolt"),
		["buckshot"] = player:GetAmmoCount("buckshot"),
		["alyxgun"] = player:GetAmmoCount("alyxgun"),
		["grenade"] = player:GetAmmoCount("grenade"),
		["thumper"] = player:GetAmmoCount("thumper"),
		["gravity"] = player:GetAmmoCount("gravity"),
		["battery"] = player:GetAmmoCount("battery"),
		["pistol"] = player:GetAmmoCount("pistol"),
		["slam"] = player:GetAmmoCount("slam"),
		["smg1"] = player:GetAmmoCount("smg1"),
		["357"] = player:GetAmmoCount("357"),
		["ar2"] = player:GetAmmoCount("ar2")
	};
	
	if (spawnAmmo) then
		
		for k, v in pairs(spawnAmmo) do
			if ( ammo[k] ) then
				ammo[k] = math.max(ammo[k] - v, 0);
			end;
		end;
	end;
	
	if (strip) then
		player:RemoveAllAmmo();
	end;
	
	return ammo;
end;

-- A function to get a player's weapons list as a table.
function nexus.player.GetWeapons(player, keep)
	local weapons = {};
	
	for k, v in pairs( player:GetWeapons() ) do
		local team = player:Team();
		local class = v:GetClass();
		local uniqueID = v:GetNetworkedString("sh_UniqueID");
		local itemTable = nexus.item.GetWeapon(v);
		
		if ( !nexus.player.GetSpawnWeapon(player, class) ) then
			team = nil;
		end;
		
		if ( itemTable and nexus.mount.Call("PlayerCanHolsterWeapon", player, itemTable, true, true) ) then
			weapons[#weapons + 1] = {
				weaponData = {class = class, uniqueID = uniqueID},
				canHolster = true,
				teamIndex = team
			};
		else
			weapons[#weapons + 1] = {
				weaponData = {class = class, uniqueID = uniqueID},
				canHolster = false,
				teamIndex = team
			};
		end;
		
		if (!keep) then
			player:StripWeapon(class);
		end;
	end;
	
	return weapons;
end;

-- A function to get the total weight of a player's equipped weapons.
function nexus.player.GetEquippedWeight(player)
	local weight = 0;
	
	for k, v in pairs( player:GetWeapons() ) do
		local itemTable = nexus.item.GetWeapon(v);
		
		if (itemTable) then
			weight = weight + itemTable.weight;
		end;
	end;
	
	return weight;
end;

-- A function to get a player's holstered weapon.
function nexus.player.GetHolsteredWeapon(player)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = nexus.item.GetWeapon(v);
		
		if (itemTable) then
			if (nexus.player.GetWeaponClass(player) != class) then
				return class;
			end;
		end;
	end;
end;

-- A function to check whether a player is ragdolled.
function nexus.player.IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		local ragdolled = player:GetSharedVar("sh_Ragdolled");
		
		if (ragdolled == exception) then
			return false;
		else
			return (ragdolled != RAGDOLL_NONE);
		end;
	end;
end;

-- A function to set a player's unragdoll time.
function nexus.player.SetUnragdollTime(player, delay)
	player.unragdollPaused = nil;
	
	if (delay) then
		nexus.player.SetAction(player, "unragdoll", delay, 2, function()
			if ( IsValid(player) and player:Alive() ) then
				nexus.player.SetRagdollState(player, RAGDOLL_NONE);
			end;
		end);
	else
		nexus.player.SetAction(player, "unragdoll", false);
	end;
end;

-- A function to pause a player's unragdoll time.
function nexus.player.PauseUnragdollTime(player)
	if (!player.unragdollPaused) then
		local unragdollTime = nexus.player.GetUnragdollTime(player);
		local curTime = CurTime();
		
		if ( player:IsRagdolled() ) then
			if (unragdollTime > 0) then
				player.unragdollPaused = unragdollTime - curTime;
				
				nexus.player.SetAction(player, "unragdoll", false);
			end;
		end;
	end;
end;

-- A function to start a player's unragdoll time.
function nexus.player.StartUnragdollTime(player)
	if (player.unragdollPaused) then
		if ( player:IsRagdolled() ) then
			nexus.player.SetUnragdollTime(player, player.unragdollPaused);
			
			player.unragdollPaused = nil;
		end;
	end;
end;

-- A function to get a player's unragdoll time.
function nexus.player.GetUnragdollTime(player)
	local action, actionDuration, startActionTime = nexus.player.GetAction(player);
	
	if (action == "unragdoll") then
		return startActionTime + actionDuration;
	else
		return 0;
	end;
end;

-- A function to get a player's ragdoll state.
function nexus.player.GetRagdollState(player)
	return player:GetSharedVar("sh_Ragdolled");
end;

-- A function to get a player's ragdoll entity.
function nexus.player.GetRagdollEntity(player)
	if (player.ragdollTable) then
		if ( IsValid(player.ragdollTable.entity) ) then
			return player.ragdollTable.entity;
		end;
	end;
end;

-- A function to get a player's ragdoll table.
function nexus.player.GetRagdollTable(player)
	return player.ragdollTable;
end;

-- A function to do a player's ragdoll decay check.
function nexus.player.DoRagdollDecayCheck(player, ragdoll)
	local index = ragdoll:EntIndex();
	
	NEXUS:CreateTimer("Decay Check: "..index, 60, 0, function()
		local ragdollIsValid = IsValid(ragdoll);
		local playerIsValid = IsValid(player);
		
		if (!playerIsValid and ragdollIsValid) then
			if ( !nexus.entity.IsDecaying(ragdoll) ) then
				local decayTime = nexus.config.Get("body_decay_time"):Get();
				
				if ( decayTime > 0 and nexus.mount.Call("PlayerCanRagdollDecay", player, ragdoll, decayTime) ) then
					nexus.entity.Decay(ragdoll, decayTime);
				end;
			else
				NEXUS:DestroyTimer("Decay Check: "..index);
			end;
		elseif (!ragdollIsValid) then
			NEXUS:DestroyTimer("Decay Check: "..index);
		end;
	end);
end;

-- A function to set a player's ragdoll immunity.
function nexus.player.SetRagdollImmunity(player, delay)
	if (delay) then
		player:GetRagdollTable().immunity = CurTime() + delay;
	else
		player:GetRagdollTable().immunity = 0;
	end;
end;

-- A function to set a player's ragdoll state.
function nexus.player.SetRagdollState(player, state, delay, decay, force, multiplier, velocityCallback)
	if (state == RAGDOLL_KNOCKEDOUT or state == RAGDOLL_FALLENOVER) then
		if ( player:IsRagdolled() ) then
			if ( nexus.mount.Call("PlayerCanRagdoll", player, state, delay, decay, player.ragdollTable) ) then
				nexus.player.SetUnragdollTime(player, delay);
				
				player:SetSharedVar("sh_Ragdolled", state);

				player.ragdollTable.delay = delay;
				player.ragdollTable.decay = decay;
				
				nexus.mount.Call("PlayerRagdolled", player, state, player.ragdollTable);
			end;
		elseif ( nexus.mount.Call("PlayerCanRagdoll", player, state, delay, decay) ) then
			local velocity = player:GetVelocity() + (player:GetAimVector() * 128);
			local ragdoll = ents.Create("prop_ragdoll");
			
			ragdoll:SetMaterial( player:GetMaterial() );
			ragdoll:SetAngles( player:GetAngles() );
			ragdoll:SetColor( player:GetColor() );
			ragdoll:SetModel( player:GetModel() );
			ragdoll:SetSkin( player:GetSkin() );
			ragdoll:SetPos( player:GetPos() );
			ragdoll:Spawn();
			
			player.ragdollTable = {};
			player.ragdollTable.eyeAngles = player:EyeAngles();
			player.ragdollTable.immunity = CurTime() + nexus.config.Get("ragdoll_immunity_time"):Get();
			player.ragdollTable.moveType = MOVETYPE_WALK;
			player.ragdollTable.entity = ragdoll;
			player.ragdollTable.health = player:Health();
			player.ragdollTable.armor = player:Armor();
			player.ragdollTable.delay = delay;
			player.ragdollTable.decay = decay;
			
			if ( !player:IsOnGround() ) then
				player.ragdollTable.immunity = 0;
			end;
			
			if ( IsValid(ragdoll) ) then
				local headIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1");
				
				ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				
				for i = 1, ragdoll:GetPhysicsObjectCount() do
					local physicsObject = ragdoll:GetPhysicsObjectNum(i);
					local boneIndex = ragdoll:TranslatePhysBoneToBone(i);
					local position, angle = player:GetBonePosition(boneIndex);
					
					if ( IsValid(physicsObject) ) then
						physicsObject:SetPos(position);
						physicsObject:SetAngle(angle);
						
						if (!velocityCallback) then
							if (boneIndex == headIndex) then
								physicsObject:SetVelocity(velocity * 1.5);
							else
								physicsObject:SetVelocity(velocity);
							end;
							
							if (force) then
								if (boneIndex == headIndex) then
									physicsObject:ApplyForceCenter(force * 1.5);
								else
									physicsObject:ApplyForceCenter(force);
								end;
							end;
						else
							velocityCallback(physicsObject, boneIndex, ragdoll, velocity, force);
						end;
					end;
				end;
			end;
			
			if ( player:Alive() ) then
				if ( IsValid( player:GetActiveWeapon() ) ) then
					player.ragdollTable.weapon = nexus.player.GetWeaponClass(player);
				end;
				
				player.ragdollTable.weapons = nexus.player.GetWeapons(player, true);
				
				if (delay) then
					nexus.player.SetUnragdollTime(player, delay);
				end;
			end;
			
			if ( player:InVehicle() ) then
				player:ExitVehicle();
				
				player.ragdollTable.eyeAngles = Angle(0, 0, 0);
			end;
			
			if ( player:IsOnFire() ) then
				ragdoll:Ignite(8, 0);
			end;
			
			player:Spectate(OBS_MODE_CHASE);
			player:RunCommand("-duck");
			player:RunCommand("-voicerecord");
			player:SetMoveType(MOVETYPE_OBSERVER);
			player:StripWeapons(true);
			player:SpectateEntity(ragdoll);
			player:CrosshairDisable();
			
			if ( player:FlashlightIsOn() ) then
				player:Flashlight(false);
			end;
			
			player.unragdollPaused = nil;
			
			player:SetSharedVar("sh_Ragdolled", state);
			player:SetSharedVar("sh_Ragdoll", ragdoll);
			
			if (state != RAGDOLL_FALLENOVER) then
				nexus.player.GiveDeathCode(player);
			end;
			
			nexus.entity.SetPlayer(ragdoll, player);
			nexus.player.DoRagdollDecayCheck(player, ragdoll);
			
			nexus.mount.Call("PlayerRagdolled", player, state, player.ragdollTable);
		end;
	elseif (state == RAGDOLL_NONE or state == RAGDOLL_RESET) then
		if ( player:IsRagdolled(nil, true) ) then
			local ragdollTable = player:GetRagdollTable();
			
			if ( nexus.mount.Call("PlayerCanUnragdoll", player, state, ragdollTable) ) then
				player:UnSpectate();
				player:CrosshairEnable();
				
				if (state != RAGDOLL_RESET) then
					nexus.player.LightSpawn(player, nil, nil, true);
				end;
				
				if (state != RAGDOLL_RESET) then
					if ( IsValid(ragdollTable.entity) ) then
						local position = nexus.entity.GetPelvisPosition(ragdollTable.entity);
						
						if (position) then
							nexus.player.SetSafePosition(player, position, ragdollTable.entity);
						end;
						
						player:SetSkin( ragdollTable.entity:GetSkin() );
						player:SetColor( ragdollTable.entity:GetColor() );
						player:SetModel( ragdollTable.entity:GetModel() );
						player:SetMaterial( ragdollTable.entity:GetMaterial() );
					end;
					
					player:SetArmor(ragdollTable.armor);
					player:SetHealth(ragdollTable.health);
					player:SetMoveType(ragdollTable.moveType);
					player:SetEyeAngles(ragdollTable.eyeAngles);
				end;
				
				if ( IsValid(ragdollTable.entity) ) then
					NEXUS:DestroyTimer( "Decay Check: "..ragdollTable.entity:EntIndex() );
					
					if (ragdollTable.decay) then
						if ( nexus.mount.Call("PlayerCanRagdollDecay", player, ragdollTable.entity, ragdollTable.decay) ) then
							nexus.entity.Decay(ragdollTable.entity, ragdollTable.decay);
						end;
					else
						ragdollTable.entity:Remove();
					end;
				end;
				
				if (state != RAGDOLL_RESET) then
					nexus.player.SetWeapons(player, ragdollTable.weapons, true);
					
					if (ragdollTable.weapon) then
						player:SelectWeapon(ragdollTable.weapon);
					end;
				end;
				
				nexus.player.SetUnragdollTime(player, false);
				
				player:SetSharedVar("sh_Ragdolled", RAGDOLL_NONE);
				player:SetSharedVar("sh_Ragdoll", NULL);
				
				nexus.mount.Call("PlayerUnragdolled", player, state, ragdollTable);
				
				player.unragdollPaused = nil;
				player.ragdollTable = {};
			end;
		end;
	end;
end;

-- A function to make a player drop their weapons.
function nexus.player.DropWeapons(player, attacker)
	local ragdollEntity = player:GetRagdollEntity();
	
	if ( player:IsRagdolled() ) then
		local ragdollWeapons = player:GetRagdollWeapons();
		
		for k, v in pairs(ragdollWeapons) do
			if (v.canHolster) then
				local itemTable = nexus.item.GetWeapon( v.weaponData["class"], v.weaponData["uniqueID"] );
				
				if (itemTable) then
					if ( nexus.mount.Call("PlayerCanDropWeapon", player, attacker, itemTable, true) ) then
						local info = {
							itemTable = itemTable,
							position = ragdollEntity:GetPos() + Vector( 0, 0, math.random(1, 48) ),
							angles = Angle(0, 0, 0)
						};
						
						if ( nexus.mount.Call("PlayerAdjustDropWeaponInfo", player, info) ) then
							local entity = nexus.entity.CreateItem(player, info.itemTable.uniqueID, info.position, info.angles);
							
							if ( IsValid(entity) ) then
								entity.data.sClip = nexus.player.TakeSecondaryAmmo( player, v.weaponData["class"] );
								entity.data.pClip = nexus.player.TakePrimaryAmmo( player, v.weaponData["class"] );
							end;
						end;
						
						ragdollWeapons[k] = nil;
					end;
				end;
			end;
		end;
	else
		for k, v in pairs( player:GetWeapons() ) do
			local itemTable = nexus.item.GetWeapon(v);
			local class = v:GetClass();
			
			if (itemTable) then
				if ( nexus.mount.Call("PlayerCanDropWeapon", player, attacker, itemTable, true) ) then
					local info = {
						itemTable = itemTable,
						position = player:GetPos() + Vector( 0, 0, math.random(1, 48) ),
						angles = Angle(0, 0, 0)
					};
					
					if ( nexus.mount.Call("PlayerAdjustDropWeaponInfo", player, info) ) then
						local entity = nexus.entity.CreateItem(player, info.itemTable.uniqueID, info.position, info.angles);
						
						if ( IsValid(entity) ) then
							entity.data.sClip = nexus.player.TakeSecondaryAmmo(player, class);
							entity.data.pClip = nexus.player.TakePrimaryAmmo(player, class);
						end;
					end;
					
					player:StripWeapon( v:GetClass() );
				end;
			end;
		end;
	end;
end;

-- A function to lightly spawn a player.
function nexus.player.LightSpawn(player, weapons, ammo, forceReturn)
	if (player:IsRagdolled() and !forceReturn) then
		nexus.player.SetRagdollState(player, RAGDOLL_NONE);
	end;
	
	player.lightSpawn = true;
	
	local moveType = player:GetMoveType();
	local material = player:GetMaterial();
	local position = player:GetPos();
	local angles = player:EyeAngles();
	local weapon = player:GetActiveWeapon();
	local health = player:Health();
	local armor = player:Armor();
	local model = player:GetModel();
	local color = player:GetColor();
	local skin = player:GetSkin();
	
	if (ammo) then
		if (type(ammo) != "table") then
			ammo = nexus.player.GetAmmo(player, true);
		end;
	end;
	
	if (weapons) then
		if (type(weapons) != "table") then
			weapons = nexus.player.GetWeapons(player);
		end;
		
		if ( IsValid(weapon) ) then
			weapon = weapon:GetClass();
		end;
	end;
	
	player.lightSpawnCallback = function(player, gamemodeHook)
		if (weapons) then
			NEXUS:PlayerLoadout(player);
			
			nexus.player.SetWeapons(player, weapons, forceReturn);
			
			if (type(weapon) == "string") then
				player:SelectWeapon(weapon);
			end;
		end;
		
		if (ammo) then
			nexus.player.GiveAmmo(player, ammo);
		end;
		
		player:SetPos(position);
		player:SetSkin(skin);
		player:SetModel(model);
		player:SetColor(color);
		player:SetArmor(armor);
		player:SetHealth(health);
		player:SetMaterial(material);
		player:SetMoveType(moveType);
		player:SetEyeAngles(angles);
		
		if (gamemodeHook) then
			special = special or false;
			
			nexus.mount.Call("PostPlayerLightSpawn", player, weapons, ammo, special);
		end;
		
		player:ResetSequence( player:GetSequence() );
	end;
	
	player:Spawn();
end;

-- A function to convert a table to camel case.
function nexus.player.ConvertToCamelCase(base)
	local newTable = {};
	
	for k, v in pairs(base) do
		local key = NEXUS:SetCamelCase(string.gsub(k, "_", ""), true);
		
		if (key and key != "") then
			newTable[key] = v;
		end;
	end;
	
	return newTable;
end;

-- A function to get a player's characters.
function nexus.player.GetCharacters(player, Callback)
	if ( IsValid(player) ) then
		local charactersTable = nexus.config.Get("mysql_characters_table"):Get();
		local schemaFolder = NEXUS:GetSchemaFolder();
		local characters = {};
		
		tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..player:SteamID().."\"", function(result)
			if ( IsValid(player) ) then
				if (result and type(result) == "table" and #result > 0) then
					for k, v in pairs(result) do
						characters[k] = nexus.player.ConvertToCamelCase(v);
					end;
					
					Callback(characters);
				else
					Callback();
				end;
			end;
		end, 1);
	end
end;

-- A function to add a character to the character screen.
function nexus.player.CharacterScreenAdd(player, character)
	local info = {
		name = character.name,
		model = character.model,
		banned = character.data["banned"],
		faction = character.faction,
		characterID = character.characterID
	};
	
	if ( character.data["physdesc"] ) then
		if (string.len( character.data["physdesc"] ) > 64) then
			info.details = string.sub(character.data["physdesc"], 1, 64).."...";
		else
			info.details = character.data["physdesc"];
		end;
	end;
	
	if ( character.data["banned"] ) then
		info.details = "This character is banned.";
	end;
	
	nexus.mount.Call("PlayerAdjustCharacterScreenInfo", player, character, info);
	
	NEXUS:StartDataStream(player, "CharacterAdd", info);
end;

-- A function to convert a character's MySQL variables to Lua variables.
function nexus.player.ConvertCharacterMySQL(base)
	base.recognisedNames = nexus.player.ConvertCharacterRecognisedNamesString(base.recognisedNames);
	base.characterID = tonumber(base.characterID);
	base.attributes = nexus.player.ConvertCharacterDataString(base.attributes);
	base.inventory = nexus.player.ConvertCharacterDataString(base.inventory);
	base.cash = tonumber(base.cash);
	base.ammo = nexus.player.ConvertCharacterDataString(base.ammo);
	base.data = nexus.player.ConvertCharacterDataString(base.data);
	base.key = tonumber(base.key);
end;

-- A function to get a player's character ID.
function nexus.player.GetCharacterID(player)
	local character = player:GetCharacter();
	
	if (character) then
		for k, v in pairs( player:GetCharacters() ) do
			if (v == character) then
				return k;
			end;
		end;
	end;
end;

-- A function to load a player's character.
function nexus.player.LoadCharacter(player, characterID, mergeCreate, Callback, force)
	local character = {};
	local unixTime = os.time();
	
	if (mergeCreate) then
		character = {};
		character.name = name;
		character.data = {};
		character.ammo = {};
		character.cash = nexus.config.Get("default_cash"):Get();
		character.model = "models/police.mdl";
		character.flags = "b";
		character.schema = NEXUS:GetSchemaFolder();
		character.gender = GENDER_MALE;
		character.faction = FACTION_CITIZEN;
		character.steamID = player:SteamID();
		character.steamName = player:SteamName();
		character.inventory = {};
		character.attributes = {};
		character.onNextLoad = "";
		character.lastPlayed = unixTime;
		character.timeCreated = unixTime;
		character.characterID = characterID;
		character.recognisedNames = {};
		
		if ( !player.characters[characterID] ) then
			table.Merge(character, mergeCreate);
			
			if (character and type(character) == "table") then
				character.inventory = nexus.inventory.GetDefault(player, character);
				
				if (!force) then
					local fault = nexus.mount.Call("PlayerCanCreateCharacter", player, character, characterID);
					
					if (fault == false or type(fault) == "string") then
						return nexus.player.CreationError(player, fault or "You cannot create this character!");
					end;
				end;
				
				nexus.player.SaveCharacter(player, true, character, function(key)
					player.characters[characterID] = character;
					player.characters[characterID].key = key;
					
					nexus.mount.Call("PlayerCharacterCreated", player, character);
					
					nexus.player.CharacterScreenAdd(player, character);
					
					if (Callback) then
						Callback();
					end;
				end);
			end;
		end;
	else
		character = player.characters[characterID];
		
		if (character) then
			if ( player:GetCharacter() ) then
				nexus.player.SaveCharacter(player);
				nexus.player.UpdateCharacter(player);
				
				nexus.mount.Call("PlayerCharacterUnloaded", player);
			end;
			
			player.character = character;
			
			if ( player:Alive() ) then
				player:KillSilent();
			end;
			
			if ( nexus.player.SetBasicSharedVars(player) ) then
				nexus.mount.Call("PlayerCharacterLoaded", player);
				
				player:SaveCharacter();
			end;
		end;
	end;
end;

-- A function to set a player's basic shared variables.
function nexus.player.SetBasicSharedVars(player)
	local gender = nexus.player.GetGender(player);
	local faction = player:QueryCharacter("faction");
	
	player:SetSharedVar( "sh_Flags", player:QueryCharacter("flags") );
	player:SetSharedVar( "sh_Model", nexus.player.GetDefaultModel(player) );
	player:SetSharedVar( "sh_Name", player:QueryCharacter("name") );
	player:SetSharedVar( "sh_Key", player:QueryCharacter("key") );
	
	if ( nexus.faction.stored[faction] ) then
		player:SetSharedVar("sh_Faction", nexus.faction.stored[faction].index);
	end;
	
	if (gender == GENDER_MALE) then
		player:SetSharedVar("sh_Gender", 2);
	else
		player:SetSharedVar("sh_Gender", 1);
	end;
	
	return true;
end;

-- A function to unescape a string.
function nexus.player.Unescape(text)
	return string.Replace(string.Replace(string.Replace(text, "\\\\", "\\"), '\\"', '"'), "\\'", "'");
end;

-- A function to get the character's ammo as a string.
function nexus.player.GetCharacterAmmoString(player, character, rawTable)
	local ammo = table.Copy(character.ammo);
	
	for k, v in pairs( nexus.player.GetAmmo(player) ) do
		if (v > 0) then
			ammo[k] = v;
		end;
	end;
	
	if (!rawTable) then
		return Json.Encode(ammo);
	else
		return ammo;
	end;
end;

-- A function to get the character's data as a string.
function nexus.player.GetCharacterDataString(player, character, rawTable)
	local data = table.Copy(character.data);
	
	nexus.mount.Call("PlayerSaveCharacterData", player, data);
	
	if (!rawTable) then
		return Json.Encode(data);
	else
		return data;
	end;
end;

-- A function to get the character's recognised names as a string.
function nexus.player.GetCharacterRecognisedNamesString(player, character)
	local recognisedNames = {};
	
	for k, v in pairs(character.recognisedNames) do
		if (v == RECOGNISE_SAVE) then
			recognisedNames[#recognisedNames + 1] = k;
		end;
	end;
	
	return Json.Encode(recognisedNames);
end;

-- A function to get the character's inventory as a string.
function nexus.player.GetCharacterInventoryString(player, character, rawTable)
	local inventory = table.Copy(character.inventory);
	
	nexus.mount.Call("PlayerGetInventoryString", player, character, inventory);
	
	for k, v in pairs(inventory) do
		local itemTable = nexus.item.Get(k);
		
		if (itemTable) then
			local amount = v;
			
			if (itemTable.GetInventoryStringAmount) then
				amount = itemTable:GetInventoryStringAmount(player);
			end;
			
			if (amount > 0) then
				inventory[k] = amount;
			else
				inventory[k] = nil;
			end;
		end;
	end;
	
	if (!rawTable) then
		return Json.Encode(inventory);
	else
		return inventory;
	end;
end;

-- A function to convert a character's recognised names string to a table.
function nexus.player.ConvertCharacterRecognisedNamesString(data)
	local success, value = pcall( Json.Decode, nexus.player.Unescape(data) );
	
	if (success) then
		local recognisedNames = {};
		
		for k, v in pairs(value) do
			recognisedNames[v] = RECOGNISE_SAVE;
		end;
		
		return recognisedNames;
	else
		return {};
	end;
end;

-- A function to convert a character's data string to a table.
function nexus.player.ConvertCharacterDataString(data)
	local success, value = pcall( Json.Decode, nexus.player.Unescape(data) );
	
	if (success) then
		return value;
	else
		return {};
	end;
end;

-- A function to load a player's data.
function nexus.player.LoadData(player, Callback)
	local playersTable = nexus.config.Get("mysql_players_table"):Get();
	local schemaFolder = NEXUS:GetSchemaFolder();
	local steamID = player:SteamID();
	
	tmysql.query("SELECT * FROM "..playersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"", function(result)
		if (IsValid(player) and !player.data) then
			local onNextPlay = "";
			
			if (result and type(result) == "table" and #result > 0) then
				player.data = nexus.player.ConvertDataString(player, result[1]._Data);
				
				onNextPlay = result[1]._OnNextPlay;
			else
				player.data = nexus.player.SaveData(player, true);
			end;
			
			nexus.mount.Call("PlayerRestoreData", player, player.data);
			
			if ( Callback and IsValid(player) ) then
				Callback(player);
			end;
			
			if (onNextPlay != "") then
				tmysql.query("UPDATE "..playersTable.." SET _OnNextPlay = \"\" WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"");
				
				PLAYER = player;
					RunString(onNextPlay);
				PLAYER = nil;
			end;
		end;
	end, 1);
	
	timer.Simple(2, function()
		if (IsValid(player) and !player.data) then
			nexus.player.LoadData(player, Callback);
		end;
	end);
end;

-- A function to save a players's data.
function nexus.player.SaveData(player, create, delay, simple)
	if (create) then
		local query = nexus.player.GetDataCreateQuery(player);
		
		if (delay) then
			timer.Simple(delay, function()
				tmysql.query(query);
			end);
		elseif (simple) then
			return query;
		else
			tmysql.query(query);
		end;
		
		return {};
	else
		local query = nexus.player.GetDataUpdateQuery(player);
		
		if (delay) then
			timer.Simple(delay, function()
				tmysql.query(query);
			end);
		elseif (!simple) then
			tmysql.query(query);
		else
			return query;
		end;
	end;
end;

-- A function to convert a player's data string.
function nexus.player.ConvertDataString(player, data)
	local success, value = pcall( Json.Decode, nexus.player.Unescape(data) );
	
	if (success) then
		return value;
	else
		return {};
	end;
end;

-- A function to get the create query of a player's data.
function nexus.player.GetDataCreateQuery(player)
	local playersTable = nexus.config.Get("mysql_players_table"):Get();
	local schemaFolder = NEXUS:GetSchemaFolder();
	local steamName = tmysql.escape( player:SteamName() );
	local ipAddress = player:IPAddress();
	local unixTime = os.time();
	local steamID = player:SteamID();
	local query = "INSERT INTO "..playersTable.." (_Data, _Schema, _SteamID, _IPAddress, _SteamName, _OnNextPlay, _LastPlayed, _TimeJoined) ";
	
	query = query.."VALUES (\"\", \""..schemaFolder.."\", \""..steamID.."\", \""..ipAddress.."\", \""..steamName.."\",";
	query = query.." \"\", \""..unixTime.."\", \""..unixTime.."\")";
	
	return query;
end;

-- A function to get the update query of player's data.
function nexus.player.GetDataUpdateQuery(player)
	local schemaFolder = NEXUS:GetSchemaFolder();
	local steamName = tmysql.escape( player:SteamName() );
	local ipAddress = player:IPAddress();
	local steamID = player:SteamID();
	local data = table.Copy(player.data);
	
	nexus.mount.Call("PlayerSaveData", player, data);
	
	local playersTable = nexus.config.Get("mysql_players_table"):Get();
	local unixTime = os.time();
	local query = "UPDATE "..playersTable.." SET _Data = \""..tmysql.escape( Json.Encode(data) ).."\",";
	
	query = query.." _SteamName = \""..steamName.."\", _IPAddress = \""..ipAddress.."\", _LastPlayed = \""..unixTime.."\"";
	query = query.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"";
	
	return query;
end;

-- A function to get the create query of a character.
function nexus.player.GetCharacterCreateQuery(player, character)
	local charactersTable = nexus.config.Get("mysql_characters_table"):Get();
	local values = "";
	local amount = 1;
	local keys = "";
	
	if (!character) then
		character = player:GetCharacter();
	end;
	
	local characterKeys = table.Count(character);
	
	for k, v in pairs(character) do
		if (characterKeys != amount) then
			keys = keys.."_"..NEXUS:SetCamelCase(k, false)..", ";
		else
			keys = keys.."_"..NEXUS:SetCamelCase(k, false);
		end;
		
		if (type(v) == "table") then
			if (k == "recognisedNames") then
				v = Json.Encode(character.recognisedNames);
			elseif (k == "attributes") then
				v = Json.Encode(character.attributes);
			elseif (k == "inventory") then
				v = Json.Encode(character.inventory);
			elseif (k == "ammo") then
				v = Json.Encode(character.ammo);
			elseif (k == "data") then
				v = Json.Encode(v);
			end;
		end;
		
		local value = tmysql.escape( tostring(v) );
		
		if (characterKeys != amount) then
			values = values.."\""..value.."\", ";
		else
			values = values.."\""..value.."\"";
		end;
		
		amount = amount + 1;
	end;
	
	return "INSERT INTO "..charactersTable.." ("..keys..") VALUES ("..values..")";
end;

-- A function to get the update query of a character.
function nexus.player.GetCharacterUpdateQuery(player, character)
	local currentCharacter = player:GetCharacter();
	local charactersTable = nexus.config.Get("mysql_characters_table"):Get();
	local schemaFolder = NEXUS:GetSchemaFolder();
	local unixTime = os.time();
	local steamID = player:SteamID();
	local query = "";
	
	if (!character) then
		character = currentCharacter;
	end;
	
	for k, v in pairs(character) do
		if (k != "key" and k != "onNextLoad") then
			if (type(v) == "table") then
				if (k == "recognisedNames") then
					v = nexus.player.GetCharacterRecognisedNamesString(player, character);
				elseif (k == "attributes") then
					v = Json.Encode(character.attributes);
				elseif (k == "inventory") then
					if (currentCharacter == character) then
						v = nexus.player.GetCharacterInventoryString(player, character);
					else
						v = Json.Encode(character.inventory);
					end;
				elseif (k == "ammo") then
					if (currentCharacter == character) then
						v = nexus.player.GetCharacterAmmoString(player, character);
					else
						v = Json.Encode(character.ammo);
					end;
				elseif (k == "data") then
					if (currentCharacter == character) then
						v = nexus.player.GetCharacterDataString(player, character);
					else
						v = Json.Encode(character.data);
					end;
				end;
			elseif (k == "lastPlayed") then
				v = unixTime;
			elseif (k == "steamName") then
				v = player:SteamName();
			end;
			
			local value = tmysql.escape( tostring(v) );
			
			if (query == "") then
				query = "UPDATE "..charactersTable.." SET _"..NEXUS:SetCamelCase(k, false).." = \""..value.."\"";
			else
				query = query..", _"..NEXUS:SetCamelCase(k, false).." = \""..value.."\"";
			end;
		end;
	end;
	
	return query.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\" AND _CharacterID = "..character.characterID;
end;

-- A function to update a player's character.
function nexus.player.UpdateCharacter(player)
	player.character.inventory = nexus.player.GetCharacterInventoryString(player, player.character, true);
	player.character.ammo = nexus.player.GetCharacterAmmoString(player, player.character, true);
	player.character.data = nexus.player.GetCharacterDataString(player, player.character, true);
end;

-- A function to save a player's character.
function nexus.player.SaveCharacter(player, create, character, Callback)
	if (create) then
		local query = nexus.player.GetCharacterCreateQuery(player, character);
		
		tmysql.query(query, function(result, status, lastID)
			if ( Callback and tonumber(lastID) ) then
				Callback( tonumber(lastID) );
			end;
		end, 2);
	elseif ( player:HasInitialized() ) then
		local characterQuery = nexus.player.GetCharacterUpdateQuery(player, character);
		local dataQuery = nexus.player.SaveData(player, nil, nil, true);
		
		tmysql.query(characterQuery);
		tmysql.query(dataQuery);
	end;
end;

-- A function to get the class of a player's active weapon.
function nexus.player.GetWeaponClass(player, safe)
	if ( IsValid( player:GetActiveWeapon() ) ) then
		return player:GetActiveWeapon():GetClass();
	else
		return safe;
	end;
end;

-- A function to call a player's think hook.
function nexus.player.CallThinkHook(player, setSharedVars, infoTable, curTime)
	infoTable.inventoryWeight = nexus.config.Get("default_inv_weight"):Get();
	infoTable.crouchedSpeed = player.crouchedSpeed;
	infoTable.jumpPower = player.jumpPower;
	infoTable.walkSpeed = player.walkSpeed;
	infoTable.runSpeed = player.runSpeed;
	infoTable.running = player:IsRunning();
	infoTable.jogging = player:IsJogging();
	infoTable.wages = nexus.class.Query(player:Team(), "wages", 0);
	
	if ( !player:IsJogging(true) ) then
		infoTable.jogging = nil;
		
		player:SetSharedVar("sh_Jogging", false);
	end;
	
	if (setSharedVars) then
		nexus.mount.Call("PlayerSetSharedVars", player, curTime);
		
		player.nextSetSharedVars = nil;
	end;
	
	nexus.mount.Call("PlayerThink", player, curTime, infoTable);
	
	player.nextThink = nil;
end;

-- A function to preserve a player's ammo.
function nexus.player.PreserveAmmo(player)
	local weapon = player:GetActiveWeapon();
	
	for k, v in ipairs( player:GetWeapons() ) do
		local itemTable = nexus.item.GetWeapon(v);
		
		if (itemTable) then
			nexus.player.SavePrimaryAmmo(player, v);
			nexus.player.SaveSecondaryAmmo(player, v);
		end;
	end;
end;

-- A function to get a player's wages.
function nexus.player.GetWages(player)
	return player:GetSharedVar("sh_Wages");
end;