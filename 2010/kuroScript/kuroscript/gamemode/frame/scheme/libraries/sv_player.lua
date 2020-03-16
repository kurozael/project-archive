--[[
Name: "sv_player.lua".
Product: "kuroScript".
--]]

kuroScript.player = {};
kuroScript.player.property = {};

-- A function to set a player's action.
function kuroScript.player.SetAction(player, action, duration, priority, callback)
	local currentAction = kuroScript.player.GetAction(player);
	
	-- Check if a statement is true.
	if (type(action) != "string" or action == "") then
		kuroScript.frame:DestroyTimer( "Action: "..player:UniqueID() );
		
		-- Set some information.
		player:SetSharedVar("ks_StartActionTime", 0);
		player:SetSharedVar("ks_ActionDuration", 0);
		player:SetSharedVar("ks_Action", "");
		
		-- Return to break the function.
		return;
	elseif (duration == false or duration == 0) then
		if (currentAction == action) then
			return kuroScript.player.SetAction(player, false);
		else
			return false;
		end;
	end;
	
	-- Check if a statement is true.
	if (player._Action) then
		if ( ( priority and priority > player._Action[2] ) or currentAction == ""
		or action == player._Action[1] ) then
			player._Action = nil;
		end;
	end;

	-- Check if a statement is true.
	if (!player._Action) then
		local curTime = CurTime();
		
		-- Set some information.
		player:SetSharedVar("ks_StartActionTime", curTime);
		player:SetSharedVar("ks_ActionDuration", duration);
		player:SetSharedVar("ks_Action", action);
		
		-- Check if a statement is true.
		if (priority) then
			player._Action = {action, priority};
		else
			player._Action = nil;
		end;
		
		-- Set some information.
		kuroScript.frame:CreateTimer("Action: "..player:UniqueID(), duration, 1, function()
			if (callback) then
				callback();
			end;
		end);
	end;
end;

-- A function to get a player's action.
function kuroScript.player.GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("ks_StartActionTime");
	local actionDuration = player:GetSharedVar("ks_ActionDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("ks_Action");
	
	-- Check if a statement is true.
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

-- A function to print a player's departure message.
function kuroScript.player.PrintDepartureMessage(player)
	local ipAddress = player:IPAddress();
	local steamID = player:SteamID();
	local name = player:Name();
	
	-- Check if a statement is true.
	if (KS_CONVAR_DEPARTURE:GetInt() == 1 and !player._Kicked) then
		local departure = hook.Call("PlayerCanShowDeparture", kuroScript.frame, player);
		
		-- Check if a statement is true.
		if (departure == true) then
			local class = kuroScript.player.GetClassTable(player);
			
			-- Check if a statement is true.
			if (class.OnDeparture != nil) then
				if (class.OnDeparture != false) then
					kuroScript.chatBox.Add( nil, nil, "departure", class:OnDeparture(player) );
				end;
			else
				kuroScript.chatBox.Add(nil, nil, "departure", name.." has disconnected from the server.");
			end;
		elseif (type(departure) == "string") then
			kuroScript.chatBox.Add(nil, nil, "departure", departure);
		end;
	end;
	
	-- Print a debug message.
	kuroScript.frame:PrintDebug(name.." ("..steamID.." | "..ipAddress..") has disconnected from the server.", true);
end;

-- A function to print a player's arrival message.
function kuroScript.player.PrintArrivalMessage(player)
	local name = player:Name();
	
	-- Check if a statement is true.
	if (KS_CONVAR_ARRIVAL:GetInt() == 1) then
		local arrival = hook.Call("PlayerCanShowArrival", kuroScript.frame, player);
		
		-- Check if a statement is true.
		if (arrival == true) then
			local class = kuroScript.player.GetClassTable(player);
			
			-- Check if a statement is true.
			if (class.OnArrival != nil) then
				if (class.OnArrival != false) then
					kuroScript.chatBox.Add( nil, nil, "arrival", class:OnArrival(player) );
				else
					kuroScript.frame:PrintDebug(name.." has connected to the server.", true);
				end;
			else
				kuroScript.chatBox.Add(nil, nil, "arrival", name.." has connected to the server.");
			end;
		elseif (type(arrival) == "string") then
			kuroScript.chatBox.Add(nil, nil, "arrival", arrival);
		else
			kuroScript.frame:PrintDebug(name.." has connected to the server.", true);
		end;
	else
		kuroScript.frame:PrintDebug(player:Name().." has connected to the server.", true);
	end;
end;

-- A function to run a kuroScript command on a player.
function kuroScript.player.RunKuroScriptCommand(player, command, ...)
	return kuroScript.command.ConsoleCommand( player, "ks", {command, ...} );
end;

-- A function to give a player's name to a player.
function kuroScript.player.GiveName(player, class, text)
	local radius = kuroScript.config.Get("talk_radius"):Get();
	local action = "giving";
	local k, v;
	
	-- Check if a statement is true.
	if (class == "whisper") then
		radius = radius / 3;
		action = "whispering";
	elseif (class == "yell") then
		radius = radius * 3;
		action = "yelling";
	end;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (v:Alive() and player != v) then
				if (v:GetShootPos():Distance( player:GetShootPos() ) <= radius) then
					if ( kuroScript.player.CanSeePlayer(v, player) ) then
						kuroScript.player.SetPlayerKnown(v, player, KNOWN_SAVE);
					end;
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (text and text != "" and text != "none") then
		kuroScript.chatBox.AddInRadius(player, class, text, player:GetPos(), radius);
	elseif (player:GetData("givenamehint") < 3) then
		kuroScript.player.Notify(player, "Now roleplay "..action.." your name to this character.");
		
		-- Set some information.
		player:SetData("givenamehint", player:GetData("givenamehint") + 1);
	end;
end;

-- A function to get a player's wages name.
function kuroScript.player.GetWagesName(player)
	return kuroScript.vocation.Query( player:Team(), "wagesName", kuroScript.config.Get("wages_name"):Get() );
end;

-- A function to get whether a player can see an NPC.
function kuroScript.player.CanSeeNPC(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		-- Set some information.
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		-- Check if a statement is true.
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		-- Set some information.
		trace = util.TraceLine(trace);
		
		-- Check if a statement is true.
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a player.
function kuroScript.player.CanSeePlayer(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	elseif (target:GetEyeTraceNoCursor().Entity == player) then
		return true;
	else
		local trace = {};
		
		-- Set some information.
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		-- Check if a statement is true.
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		-- Set some information.
		trace = util.TraceLine(trace);
		
		-- Check if a statement is true.
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see an entity.
function kuroScript.player.CanSeeEntity(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		-- Set some information.
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:LocalToWorld( target:OBBCenter() );
		trace.filter = {player, target};
		
		-- Check if a statement is true.
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		-- Set some information.
		trace = util.TraceLine(trace);
		
		-- Check if a statement is true.
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a position.
function kuroScript.player.CanSeePosition(player, position, allowance, ignoreEnts)
	local trace = {};
	
	-- Set some information.
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = player:GetShootPos();
	trace.endpos = position;
	trace.filter = {player};
	
	-- Check if a statement is true.
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	-- Set some information.
	trace = util.TraceLine(trace);
	
	-- Check if a statement is true.
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to get whether a player's weapon is raised.
function kuroScript.player.GetWeaponRaised(player)
	if ( !kuroScript.config.Get("raised_weapon_system"):Get() ) then
		return true;
	else
		local weapon = player:GetActiveWeapon();
		
		-- Check if a statement is true.
		if ( ValidEntity(weapon) ) then
			if (!weapon.NeverRaised) then
				if (weapon.GetRaised) then
					local raised = weapon:GetRaised();
					
					-- Check if a statement is true.
					if (raised != nil) then
						return raised;
					end;
				end;
				
				-- Set some information.
				local class = weapon:GetClass();
				
				-- Check if a statement is true.
				if (class != "weapon_physgun" and class != "weapon_physcannon" and class != "gmod_tool") then
					return hook.Call("GetPlayerWeaponRaised", kuroScript.frame, player, class, weapon);
				else
					return true;
				end;
			end;
		end;
	end;
end;

-- A function to toggle whether a player's weapon is raised.
function kuroScript.player.ToggleWeaponRaised(player)
	kuroScript.player.SetWeaponRaised(player, !player._ToggleWeaponRaised);
end;

-- A function to set whether a player's weapon is raised.
function kuroScript.player.SetWeaponRaised(player, raised)
	local weapon = player:GetActiveWeapon();
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		if (type(raised) == "number") then
			player._AutoWeaponRaised = weapon:GetClass();
			
			-- Set some information.
			kuroScript.frame:CreateTimer("Auto Weapon Raised: "..player:UniqueID(), raised, 1, function()
				if ( ValidEntity(player) ) then
					player._AutoWeaponRaised = nil;
				end;
			end);
		elseif (raised) then
			if (!player._ToggleWeaponRaised) then
				if (weapon.OnRaised) then
					weapon:OnRaised();
				end;
			end;
			
			-- Set some information.
			player._ToggleWeaponRaised = weapon:GetClass();
			player._AutoWeaponRaised = nil;
		else
			if (player._ToggleWeaponRaised) then
				if (weapon.OnLowered) then
					weapon:OnLowered();
				end;
			end;
			
			-- Set some information.
			player._ToggleWeaponRaised = nil;
			player._AutoWeaponRaised = nil;
		end;
	end;
end;

-- A function to give property to a player.
function kuroScript.player.GiveProperty(player, entity, networked, removeDelay)
	kuroScript.frame:DestroyTimer( "Remove Delay: "..entity:EntIndex() );
	
	-- Clear the entity's property.
	kuroScript.entity.ClearProperty(entity);
	
	-- Set some information.
	entity._Property = {
		key = player:QueryCharacter("key"),
		owner = player,
		owned = true,
		uniqueID = player:UniqueID(),
		networked = networked,
		removeDelay = removeDelay
	};
	
	-- Check if a statement is true.
	if ( ValidEntity(player) ) then
		if (entity.SetPlayer) then
			entity:SetPlayer(player);
		end;
		
		-- Check if a statement is true.
		if (networked) then
			entity:SetNetworkedEntity("ks_Owner", player);
		end;
	end;
	
	-- Set some information.
	entity:SetNetworkedBool("ks_Owned", true);
	
	-- Set some information.
	kuroScript.player.property[ entity:EntIndex() ] = entity;
	
	-- Call a gamemode hook.
	hook.Call("PlayerPropertyGiven", kuroScript.frame, player, entity, networked, removeDelay);
end;

-- A function to give property to an offline player.
function kuroScript.player.GivePropertyOffline(key, uniqueID, entity, networked, removeDelay)
	kuroScript.entity.ClearProperty(entity);
	
	-- Check if a statement is true.
	if (key and uniqueID) then
		local propertyUniqueID = kuroScript.entity.QueryProperty(entity, "uniqueID");
		local owner = player.GetByUniqueID(uniqueID);
		
		-- Check if a statement is true.
		if (owner) then
			if (owner:QueryCharacter("key") != key) then
				owner = nil;
			else
				kuroScript.player.GiveProperty(owner, entity, networked, removeDelay);
				
				-- Return to break the function.
				return;
			end;
		end;
		
		-- Check if a statement is true.
		if (propertyUniqueID) then
			kuroScript.frame:DestroyTimer("Remove Delay: "..entity:EntIndex().." "..propertyUniqueID);
		end;
		
		-- Set some information.
		entity._Property = {
			key = key,
			owner = owner,
			owned = true,
			uniqueID = uniqueID,
			networked = networked,
			removeDelay = removeDelay
		};
		
		-- Check if a statement is true.
		if ( ValidEntity(entity._Property.owner) ) then
			if (entity.SetPlayer) then
				entity:SetPlayer(entity._Property.owner);
			end;
			
			-- Check if a statement is true.
			if (networked) then
				entity:SetNetworkedEntity("ks_Owner", entity._Property.owner);
			end;
		end;
		
		-- Set some information.
		entity:SetNetworkedBool("ks_Owned", true);
		
		-- Set some information.
		kuroScript.player.property[ entity:EntIndex() ] = entity;
		
		-- Call a gamemode hook.
		hook.Call("PlayerPropertyGivenOffline", kuroScript.frame, key, uniqueID, entity, networked, removeDelay);
	end;
end;

-- A function to take property from an offline player.
function kuroScript.player.TakePropertyOffline(key, uniqueID, entity)
	if (key and uniqueID) then
		local owner = player.GetByUniqueID(uniqueID);
		
		-- Check if a statement is true.
		if (owner and owner:QueryCharacter("key") == key) then
			kuroScript.player.TakeProperty(owner, entity);
			
			-- Return to break the function.
			return;
		end;
		
		-- Check if a statement is true.
		if (kuroScript.entity.QueryProperty(entity, "uniqueID") == uniqueID) then
			if (kuroScript.entity.QueryProperty(entity, "key") == key) then
				entity._Property = nil;
				
				-- Set some information.
				entity:SetNetworkedEntity("ks_Owner", NULL);
				entity:SetNetworkedBool("ks_Owned", false);
				
				-- Check if a statement is true.
				if (entity.SetPlayer) then
					entity:SetVar("Founder", nil);
					entity:SetVar("FounderIndex", nil);
					entity:SetNetworkedString("FounderName", "");
				end;
				
				-- Set some information.
				kuroScript.player.property[ entity:EntIndex() ] = nil;
				
				-- Call a gamemode hook.
				hook.Call("PlayerPropertyTakenOffline", kuroScript.frame, key, uniqueID, entity);
			end;
		end;
	end;
end;

-- A function to take property from a player.
function kuroScript.player.TakeProperty(player, entity)
	if (kuroScript.entity.GetOwner(entity) == player) then
		entity._Property = nil;
		
		-- Set some information.
		entity:SetNetworkedEntity("ks_Owner", NULL);
		entity:SetNetworkedBool("ks_Owned", false);
		
		-- Check if a statement is true.
		if (entity.SetPlayer) then
			entity:SetVar("Founder", nil);
			entity:SetVar("FounderIndex", nil);
			entity:SetNetworkedString("FounderName", "");
		end;
		
		-- Set some information.
		kuroScript.player.property[ entity:EntIndex() ] = nil;
		
		-- Call a gamemode hook.
		hook.Call("PlayerPropertyTaken", kuroScript.frame, player, entity);
	end;
end;

-- A function to set a player to their default skin.
function kuroScript.player.SetDefaultSkin(player)
	player:SetSkin( kuroScript.player.GetDefaultSkin(player) );
end;

-- A function to get a player's default skin.
function kuroScript.player.GetDefaultSkin(player)
	return hook.Call("GetPlayerDefaultSkin", kuroScript.frame, player);
end;

-- A function to set a player to their default model.
function kuroScript.player.SetDefaultModel(player)
	player:SetModel( kuroScript.player.GetDefaultModel(player) );
end;

-- A function to get a player's default model.
function kuroScript.player.GetDefaultModel(player)
	return hook.Call("GetPlayerDefaultModel", kuroScript.frame, player);
end;

-- A function to get whether a player is drunk.
function kuroScript.player.GetDrunk(player)
	if (player._Drunk) then return #player._Drunk; end;
end;

-- A function to set whether a player is drunk.
function kuroScript.player.SetDrunk(player, expire)
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (expire == false) then
		player._Drunk = nil;
	elseif (!player._Drunk) then
		player._Drunk = {curTime + expire};
	else
		player._Drunk[#player._Drunk + 1] = curTime + expire;
	end;
	
	-- Set some information.
	player:SetSharedVar("ks_Drunk", kuroScript.player.GetDrunk(player) or 0);
end;

-- A function to strip a player's default ammo.
function kuroScript.player.StripDefaultAmmo(player, weapon, itemTable)
	if (!itemTable) then
		itemTable = kuroScript.item.GetWeapon(weapon);
	end;
	
	-- Check if a statement is true.
	if (itemTable) then
		if (itemTable.primaryDefaultAmmo) then
			local ammoClass = weapon:GetPrimaryAmmoType();
			
			-- Check if a statement is true.
			if (weapon:Clip1() != -1) then weapon:SetClip1(0); end;
			
			-- Check if a statement is true.
			if (type(itemTable.primaryDefaultAmmo) == "number") then
				player:SetAmmo(math.max(player:GetAmmoCount(ammoClass) - itemTable.primaryDefaultAmmo, 0), ammoClass);
			end;
		end;
		
		-- Check if a statement is true.
		if (itemTable.secondaryDefaultAmmo) then
			local ammoClass = weapon:GetSecondaryAmmoType();
			
			-- Check if a statement is true.
			if (weapon:Clip2() != -1) then weapon:SetClip2(0); end;
			
			-- Check if a statement is true.
			if (type(itemTable.secondaryDefaultAmmo) == "number") then
				player:SetAmmo(math.max(player:GetAmmoCount(ammoClass) - itemTable.secondaryDefaultAmmo, 0), ammoClass);
			end;
		end;
	end;
end;

-- A function to check if a weapon is empty.
function kuroScript.player.CheckWeaponEmpty(player, weapon, itemTable)
	local class = weapon:GetClass();
	
	-- Check if a statement is true.
	if (!itemTable) then
		itemTable = kuroScript.item.GetWeapon(weapon);
	end;
	
	-- Check if a statement is true.
	if (itemTable and !itemTable.meleeWeapon) then
		local primaryEmpty = kuroScript.player.GetPrimaryAmmo(player, class) == 0;
		local secondaryEmpty = kuroScript.player.GetSecondaryAmmo(player, class) == 0;
		
		-- Check if a statement is true.
		if (primaryEmpty and secondaryEmpty) then
			local primaryAmmoCount = player:GetAmmoCount( weapon:GetPrimaryAmmoType() );
			local secondaryAmmoCount = player:GetAmmoCount( weapon:GetSecondaryAmmoType() );
			
			-- Check if a statement is true.
			if (primaryAmmoCount == 0 and secondaryAmmoCount == 0) then
				if (!itemTable.expireOnEmpty) then
					if ( hook.Call("PlayerCanHolsterWeapon", kuroScript.frame, player, itemTable, true, true) ) then
						if ( kuroScript.inventory.Update(player, itemTable.uniqueID, 1, true) ) then
							player:StripWeapon(class); player:SelectWeapon("ks_hands");
							
							-- Call a gamemode hook.
							hook.Call("PlayerHolsterWeapon", kuroScript.frame, player, itemTable, true);
						end;
					end;
				else
					player:StripWeapon(class);
					player:SelectWeapon("ks_hands");
				end;
			end;
		end;
	end;
end;

-- A function to restore a player's secondary ammo.
function kuroScript.player.RestoreSecondaryAmmo(player)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local spawnAmmo = kuroScript.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		-- Check if a statement is true.
		if (weapon:Clip2() != -1) then
			if ( ammo["s_"..class] ) then
				weapon:SetClip2( ammo["s_"..class] );
			elseif ( kuroScript.player.GetSpawnWeapon(player, class) ) then
				if ( spawnAmmo["s_"..class] ) then
					weapon:SetClip2( spawnAmmo["s_"..class] );
				end;
			end;
		end;
	end;
end;

-- A function to restore a player's primary ammo.
function kuroScript.player.RestorePrimaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local spawnAmmo = kuroScript.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		-- Check if a statement is true.
		if (weapon:Clip1() != -1) then
			if ( ammo["p_"..class] ) then
				weapon:SetClip1( ammo["p_"..class] );
			elseif ( kuroScript.player.GetSpawnWeapon(player, class) ) then
				if ( spawnAmmo["p_"..class] ) then
					weapon:SetClip1( spawnAmmo["p_"..class] );
				end;
			end;
		end;
	end;
end;

-- A function to save a player's secondary ammo.
function kuroScript.player.SaveSecondaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local spawnAmmo = kuroScript.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		-- Check if a statement is true.
		if (weapon:Clip2() >= 0) then
			if ( kuroScript.player.GetSpawnWeapon(player, class) ) then
				spawnAmmo["s_"..class] = weapon:Clip2();
				
				-- Check if a statement is true.
				if (spawnAmmo["s_"..class] == 0) then
					spawnAmmo["s_"..class] = nil;
				end;
			else
				ammo["s_"..class] = weapon:Clip2();
				
				-- Check if a statement is true.
				if (ammo["s_"..class] == 0) then
					ammo["s_"..class] = nil;
				end;
			end;
		end;
	end;
end;

-- A function to save a player's primary ammo.
function kuroScript.player.SavePrimaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local spawnAmmo = kuroScript.player.GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		-- Check if a statement is true.
		if (weapon:Clip1() >= 0) then
			if ( kuroScript.player.GetSpawnWeapon(player, class) ) then
				spawnAmmo["p_"..class] = weapon:Clip1();
				
				-- Check if a statement is true.
				if (spawnAmmo["p_"..class] == 0) then
					spawnAmmo["p_"..class] = nil;
				end;
			else
				ammo["p_"..class] = weapon:Clip1();
				
				-- Check if a statement is true.
				if (ammo["p_"..class] == 0) then
					ammo["p_"..class] = nil;
				end;
			end;
		end;
	end;
end;

-- A function to get a player's secondary ammo.
function kuroScript.player.GetSecondaryAmmo(player, class)
	local spawnAmmo = kuroScript.player.GetSpawnAmmo(player);
	local ammo = player:QueryCharacter("ammo");
	
	-- Check if a statement is true.
	if (spawnAmmo["s_"..class] and spawnAmmo["s_"..class] > 0) then
		return spawnAmmo["s_"..class];
	elseif (ammo["s_"..class] and ammo["s_"..class] > 0) then
		return ammo["s_"..class];
	else
		return 0;
	end;
end;

-- A function to get a player's primary ammo.
function kuroScript.player.GetPrimaryAmmo(player, class)
	local spawnAmmo = kuroScript.player.GetSpawnAmmo(player);
	local ammo = player:QueryCharacter("ammo");
	
	-- Check if a statement is true.
	if (spawnAmmo["p_"..class] and spawnAmmo["p_"..class] > 0) then
		return spawnAmmo["p_"..class];
	elseif (ammo["p_"..class] and ammo["p_"..class] > 0) then
		return ammo["p_"..class];
	else
		return 0;
	end;
end;

-- A function to check if a player is whitelisted for a class.
function kuroScript.player.IsWhitelisted(player, class)
	return table.HasValue(player:GetData("whitelisted"), class);
end;

-- A function to set whether a player is whitelisted for a class.
function kuroScript.player.SetWhitelisted(player, class, boolean)
	local whitelisted = player:GetData("whitelisted");
	local k, v;
	
	-- Check if a statement is true.
	if (boolean) then
		if ( !kuroScript.player.IsWhitelisted(player, class) ) then
			whitelisted[#whitelisted + 1] = class;
		end;
	else
		for k, v in pairs(whitelisted) do
			if (v == class) then whitelisted[k] = nil; end;
		end;
	end;
end;

-- A function to create a condition timer.
function kuroScript.player.ConditionTimer(player, delay, condition, callback)
	delay = CurTime() + delay; local uniqueID = player:UniqueID();
	
	-- Check if a statement is true.
	if (player._ConditionTimer) then
		player._ConditionTimer.callback(false);
		player._ConditionTimer = nil;
	end;
	
	-- Set some information.
	player._ConditionTimer = {
		delay = delay,
		callback = callback,
		condition = condition
	};
	
	-- Set some information.
	kuroScript.frame:CreateTimer("Condition Timer: "..uniqueID, 0, 0, function()
		if ( ValidEntity(player) ) then
			if ( condition() ) then
				if (CurTime() >= delay) then
					callback(true); player._ConditionTimer = nil;
					
					-- Destroy some information.
					kuroScript.frame:DestroyTimer("Condition Timer: "..uniqueID);
				end;
			else
				callback(false); player._ConditionTimer = nil;
				
				-- Destroy some information.
				kuroScript.frame:DestroyTimer("Condition Timer: "..uniqueID);
			end;
		else
			kuroScript.frame:DestroyTimer("Condition Timer: "..uniqueID);
		end;
	end);
end;

-- A function to create an entity condition timer.
function kuroScript.player.EntityConditionTimer(player, target, entity, delay, distance, condition, callback)
	delay = CurTime() + delay; entity = entity or target;
	
	-- Set some information.
	local uniqueID = player:UniqueID();
	
	-- Check if a statement is true.
	if (player._EntityConditionTimer) then
		player._EntityConditionTimer.callback(false);
		player._EntityConditionTimer = nil;
	end;
	
	-- Set some information.
	player._EntityConditionTimer = {
		delay = delay,
		target = target,
		entity = entity,
		distance = distance,
		callback = callback,
		condition = condition
	};
	
	-- Set some information.
	kuroScript.frame:CreateTimer("Entity Condition Timer: "..uniqueID, 0, 0, function()
		if ( ValidEntity(player) ) then
			local trace = player:GetEyeTraceNoCursor();
			
			-- Check if a statement is true.
			if ( ValidEntity(target) and ValidEntity(entity) and trace.Entity == entity
			and trace.Entity:GetPos():Distance( player:GetShootPos() ) <= distance and condition() ) then
				if (CurTime() >= delay) then
					callback(true); player._EntityConditionTimer = nil;
					
					-- Destroy some information.
					kuroScript.frame:DestroyTimer("Entity Condition Timer: "..uniqueID);
				end;
			else
				callback(false); player._EntityConditionTimer = nil;
				
				-- Destroy some information.
				kuroScript.frame:DestroyTimer("Entity Condition Timer: "..uniqueID);
			end;
		else
			kuroScript.frame:DestroyTimer("Entity Condition Timer: "..uniqueID);
		end;
	end);
end;

-- A function to get a player's spawn ammo.
function kuroScript.player.GetSpawnAmmo(player, ammo)
	if (ammo) then
		return player._SpawnAmmo[ammo];
	else
		return player._SpawnAmmo;
	end;
end;

-- A function to get a player's spawn weapon.
function kuroScript.player.GetSpawnWeapon(player, weapon)
	if (weapon) then
		return player._SpawnWeapons[weapon];
	else
		return player._SpawnWeapons;
	end;
end;

-- A function to take spawn ammo from a player.
function kuroScript.player.TakeSpawnAmmo(player, ammo, amount)
	if ( player._SpawnAmmo[ammo] ) then
		if (player._SpawnAmmo[ammo] < amount) then
			amount = player._SpawnAmmo[ammo];
			
			-- Set some information.
			player._SpawnAmmo[ammo] = nil;
		else
			player._SpawnAmmo[ammo] = player._SpawnAmmo[ammo] - amount;
		end;
		
		-- Remove ammo from the player.
		player:RemoveAmmo(amount, ammo);
	end;
end;

-- A function to give the player spawn ammo.
function kuroScript.player.GiveSpawnAmmo(player, ammo, amount)
	if ( player._SpawnAmmo[ammo] ) then
		player._SpawnAmmo[ammo] = player._SpawnAmmo[ammo] + amount;
	else
		player._SpawnAmmo[ammo] = amount;
	end;
	
	-- Give the player ammo.
	player:GiveAmmo(amount, ammo);
end;

-- A function to take a player's spawn weapon.
function kuroScript.player.TakeSpawnWeapon(player, class)
	player._SpawnWeapons[class] = nil;
	
	-- Strip the player's weapon.
	player:StripWeapon(class);
end;

-- A function to give the player a spawn weapon.
function kuroScript.player.GiveSpawnWeapon(player, class, uniqueID)
	player._SpawnWeapons[class] = true;
	
	-- Give the player the weapon.
	player:Give(class, uniqueID);
end;

-- A function to give access to a player.
function kuroScript.player.GiveAccess(player, access)
	for i = 1, string.len(access) do
		local flag = string.sub(access, i, i);
		
		-- Check if a statement is true.
		if ( !string.find(player:QueryCharacter("access"), flag) ) then
			player:SetCharacterData("access", player:QueryCharacter("access")..flag, true);
			
			-- Call a gamemode hook.
			hook.Call("PlayerAccessGiven", kuroScript.frame, player, flag);
		end;
	end;
end;

-- A function to play a sound to a player.
function kuroScript.player.PlaySound(player, sound)
	umsg.Start("ks_PlaySound", player);
		umsg.String(sound);
	umsg.End();
end;

-- A function to get a player's maximum characters.
function kuroScript.player.GetMaximumCharacters(player)
	local maximum = kuroScript.config.Get("additional_characters"):Get();
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.class.stored) do
		if ( !v.whitelist or kuroScript.player.IsWhitelisted(player, v.name) ) then
			maximum = maximum + 1;
		end;
	end;
	
	-- Return the maximum characters.
	return maximum;
end;

-- A function to query a player's character.
function kuroScript.player.Query(player, key, default)
	key = kuroScript.frame:SetCamelCase(string.gsub(key, "_", ""), false);
	
	-- Set some information.
	local character = player:GetCharacter();
	
	-- Check if a statement is true.
	if (character) then
		return character["_"..key] or default;
	else
		return default;
	end;
end;

-- A function to set a player to a safe position.
function kuroScript.player.SetSafePosition(player, position, filter)
	position = kuroScript.player.GetSafePosition(player, position, filter);
	
	-- Check if a statement is true.
	if (position) then
		player:SetMoveType(MOVETYPE_NOCLIP);
		player:SetPos(position);
		
		-- Check if a statement is true.
		if ( player:IsInWorld() ) then
			player:SetMoveType(MOVETYPE_WALK);
		else
			player:Spawn();
		end;
	end;
end;

-- A function to get the safest position near a position.
function kuroScript.player.GetSafePosition(player, position, filter)
	local closestPosition;
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
	
	-- Set some information.
	position = position + Vector(0, 0, 32);
	
	-- Check if a statement is true.
	if (!filter) then
		filter = {player};
	elseif (type(filter) != "table") then
		filter = {filter};
	end;
	
	-- Check if a statement is true.
	if ( !table.HasValue(filter, player) ) then
		filter[#filter + 1] = player;
	end;
	
	-- Loop through a range of values.
	for i = 1, 8 do
		for k, v in ipairs(angles) do
			directions[#directions + 1] = {v, distanceAmount};
		end;
		
		-- Set some information.
		distanceAmount = distanceAmount * 2;
	end;
	
	-- A function to get a lower position.
	local function GetLowerPosition(testPosition, ignoreHeight)
		local trace = {
			filter = filter,
			endpos = testPosition - Vector(0, 0, 256),
			start = testPosition
		};
		
		-- Return the lower position.
		return util.TraceLine(trace).HitPos + Vector(0, 0, 32);
	end;
	
	-- Set some information.
	local trace = {
		filter = filter,
		endpos = position + Vector(0, 0, 256),
		start = position
	};
	
	-- Set some information.
	local safePosition = GetLowerPosition(util.TraceLine(trace).HitPos);
	local k, v;
	
	-- Check if a statement is true.
	if (safePosition) then
		position = safePosition;
	end;
	
	-- Loop through each value in a table.
    for k, v in ipairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + ( angleVector * v[2] );
		
		-- Set some information.
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		-- Set some information.
		local traceLine = util.TraceEntity(trace, player);
		
		-- Check if a statement is true.
		if (traceLine.Hit) then
			trace = {
				filter = filter,
				endpos = traceLine.HitPos - ( angleVector * v[2] ),
				start = traceLine.HitPos
			};
			
			-- Set some information.
			traceLine = util.TraceEntity(trace, player);
			
			-- Check if a statement is true.
			if (!traceLine.Hit) then
				position = traceLine.HitPos;
			end;
		end;
		
		-- Check if a statement is true.
		if (!traceLine.Hit) then
			break;
		end;
    end;
	
	-- Loop through each value in a table.
    for k, v in ipairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + ( angleVector * v[2] );
		
		-- Set some information.
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		-- Set some information.
		local traceLine = util.TraceEntity(trace, player);
		
		-- Check if a statement is true.
		if (!traceLine.Hit) then
			return traceLine.HitPos;
		end;
    end;
	
	-- Return the position.
	return position;
end;

-- A function to return a player's property.
function kuroScript.player.ReturnProperty(player)
	local uniqueID = player:UniqueID();
	local key = player:QueryCharacter("key");
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.player.property) do
		if ( ValidEntity(v) ) then
			if ( uniqueID == kuroScript.entity.QueryProperty(v, "uniqueID") ) then
				if ( key == kuroScript.entity.QueryProperty(v, "key") ) then
					kuroScript.player.GiveProperty( player, v, kuroScript.entity.QueryProperty(v, "networked") );
				end;
			end;
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("PlayerReturnProperty", kuroScript.frame, player);
end;

-- A function to take access from a player.
function kuroScript.player.TakeAccess(player, access)
	for i = 1, string.len(access) do
		local flag = string.sub(access, i, i);
		
		-- Check if a statement is true.
		if ( string.find(player:QueryCharacter("access"), flag) ) then
			player:SetCharacterData("access", string.gsub(player:QueryCharacter("access"), flag, ""), true);
			
			-- Call a gamemode hook.
			hook.Call("PlayerAccessTaken", kuroScript.frame, player, flag);
		end;
	end;
end;

-- A function to set whether a player's menu is open.
function kuroScript.player.SetMenuOpen(player, boolean)
	umsg.Start("ks_MenuOpen", player);
		umsg.Bool(boolean);
	umsg.End();
end;

-- A function to set whether a player has intialized.
function kuroScript.player.SetInitialized(player, initialized)
	player:SetSharedVar("ks_Initialized", initialized);
end;

-- A function to check if a player has any access.
function kuroScript.player.HasAnyAccess(player, access, default)
	if ( player:GetCharacter() ) then
		local playerAccess = player:QueryCharacter("access");
		
		-- Check if a statement is true.
		if ( kuroScript.vocation.HasAnyAccess(player:Team(), access) and !default ) then
			return true;
		else
			local i;
			
			-- Loop through a range of values.
			for i = 1, string.len(access) do
				local flag = string.sub(access, i, i);
				local success = true;
				
				-- Check if a statement is true.
				if (!default) then
					local hasFlag = hook.Call("PlayerDoesHaveAccessFlag", kuroScript.frame, player, flag);
					
					-- Check if a statement is true.
					if (hasFlag != false) then
						if (hasFlag) then
							return true;
						end;
					else
						success = nil;
					end;
				end;
				
				-- Check if a statement is true.
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
					elseif ( string.find(playerAccess, flag) ) then
						return true;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to check if a player has access.
function kuroScript.player.HasAccess(player, access, default)
	if ( player:GetCharacter() ) then
		local playerAccess = player:QueryCharacter("access");
		
		-- Check if a statement is true.
		if ( kuroScript.vocation.HasAccess(player:Team(), access) and !default ) then
			return true;
		else
			local i;
			
			-- Loop through a range of values.
			for i = 1, string.len(access) do
				local flag = string.sub(access, i, i);
				local success;
				
				-- Check if a statement is true.
				if (!default) then
					local hasFlag = hook.Call("PlayerDoesHaveAccessFlag", kuroScript.frame, player, flag);
					
					-- Check if a statement is true.
					if (hasFlag != false) then
						if (hasFlag) then
							success = true;
						end;
					else
						return;
					end;
				end;
				
				-- Check if a statement is true.
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
					elseif ( !string.find(playerAccess, flag) ) then
						return;
					end;
				end;
			end;
		end;
		
		-- Return true to break the function.
		return true;
	end;
end;

-- A function to use a player's death code.
function kuroScript.player.UseDeathCode(player, command, arguments)
	hook.Call("PlayerDeathCodeUsed", kuroScript.frame, player, command, arguments);
	
	-- Take the player's death code.
	kuroScript.player.TakeDeathCode(player);
end;

-- A function to get whether a player has a death code.
function kuroScript.player.GetDeathCode(player, authenticated)
	if ( player._DeathCode and (!authenticated or player._DeathCodeAuthenticated) ) then
		return player._DeathCode;
	end;
end;

-- A function to take a player's death code.
function kuroScript.player.TakeDeathCode(player)
	player._DeathCodeAuthenticated = nil;
	player._DeathCode = nil;
end;

-- A function to give a player their death code.
function kuroScript.player.GiveDeathCode(player)
	player._DeathCode = math.random(0, 99999);
	player._DeathCodeAuthenticated = nil;
	
	-- Start a user message.
	umsg.Start("ks_ChatBoxDeathCode", player);
		umsg.Long(player._DeathCode);
	umsg.End();
end;

-- A function to take a door from a player.
function kuroScript.player.TakeDoor(player, door, force, thisDoorOnly, childrenOnly)
	if (!thisDoorOnly) then
		local doorParent = kuroScript.entity.GetDoorParent(door);
		local k, v;
		
		-- Check if a statement is true.
		if (doorParent and !childrenOnly) then
			return kuroScript.player.TakeDoor(player, doorParent, force);
		else
			for k, v in pairs( kuroScript.entity.GetDoorChildren(door) ) do
				if ( ValidEntity(v) ) then
					kuroScript.player.TakeDoor(player, v, true, true);
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( hook.Call("PlayerCanUnlockDoor", kuroScript.frame, player, door) ) then
		door:Fire("Unlock", "", 0);
		door:EmitSound("doors/door_latch3.wav");
	end;
	
	-- Set some information.
	kuroScript.entity.SetDoorText(door, false);
	kuroScript.player.TakeProperty(player, door)
	
	-- Check if a statement is true.
	if (door:GetClass() == "prop_dynamic") then
		if ( !door:IsMapEntity() ) then
			door:Remove();
		end;
	end;
	
	-- Check if a statement is true.
	if (!force) then
		kuroScript.player.GiveCurrency(player, kuroScript.config.Get("door_cost"):Get() / 2, "Door");
	end;
end;

-- A function to make a player say text as a radio broadcast.
function kuroScript.player.SayRadio(player, text, check, silent)
	local eavesdroppers = {};
	local listeners = {};
	local canRadio = true;
	local info = {listeners = {}, silent = silent, text = text};
	local k, v;
	
	-- Call a gamemode hook.
	hook.Call("PlayerAdjustRadioInfo", kuroScript.frame, player, info);
	
	-- Loop through each value in a table.
	for k, v in pairs(info.listeners) do
		if (type(k) == "Player") then
			listeners[k] = k;
		elseif (type(v) == "Player") then
			listeners[v] = v;
		end;
	end;
	
	-- Check if a statement is true.
	if (!info.silent) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() and !listeners[v] ) then
				if ( v:GetShootPos():Distance( player:GetShootPos() ) <= kuroScript.config.Get("talk_radius"):Get() ) then
					eavesdroppers[v] = v;
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (check) then
		canRadio = hook.Call("PlayerCanRadio", kuroScript.frame, player, info.text, listeners, eavesdroppers);
	end;
	
	-- Check if a statement is true.
	if (canRadio) then
		info = kuroScript.chatBox.Add(listeners, player, "radio", info.text);
		
		-- Check if a statement is true.
		if ( info and ValidEntity(info.speaker) ) then
			kuroScript.chatBox.Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			
			-- Call a gamemode hook.
			hook.Call("PlayerRadioUsed", kuroScript.frame, player, info.text, listeners, eavesdroppers);
		end;
	end;
end;

-- A function to get a player's class table.
function kuroScript.player.GetClassTable(player)
	return kuroScript.class.stored[ player:QueryCharacter("class") ];
end;

-- A function to give a door to a player.
function kuroScript.player.GiveDoor(player, door, name, unsellable, override)
	if ( kuroScript.entity.IsDoor(door) ) then
		local doorParent = kuroScript.entity.GetDoorParent(door);
		local k, v;
		
		-- Check if a statement is true.
		if (doorParent and !override) then
			kuroScript.player.GiveDoor(player, doorParent, name, unsellable);
		else
			for k, v in pairs( kuroScript.entity.GetDoorChildren(door) ) do
				if ( ValidEntity(v) ) then
					kuroScript.player.GiveDoor(player, v, name, unsellable, true);
				end;
			end;
			
			-- Set some information.
			door._Unsellable = unsellable;
			door._AccessList = {};
			
			-- Set some information.
			kuroScript.entity.SetDoorText( door, name or player:Name() );
			kuroScript.player.GiveProperty(player, door, true);
			
			-- Check if a statement is true.
			if ( hook.Call("PlayerCanUnlockDoor", kuroScript.frame, player, door) ) then
				door:EmitSound("doors/door_latch3.wav");
				door:Fire("Unlock", "", 0);
			end;
		end;
	end;
end;

-- A function to check if a player knows another player.
function kuroScript.player.KnowsPlayer(player, target, status, simple)
	if (!status) then
		return kuroScript.player.KnowsPlayer(player, target, KNOWN_PARTIAL);
	elseif ( kuroScript.config.Get("anonymous_system"):Get() ) then
		local knownNames = player:QueryCharacter("knownNames");
		local default = false;
		local key = target:QueryCharacter("key");
		
		-- Check if a statement is true.
		if ( knownNames[key] ) then
			if (simple) then
				default = (knownNames[key] == status);
			else
				default = (knownNames[key] >= status);
			end;
		end;
		
		-- Return whether the player knows them.
		return hook.Call("PlayerDoesKnowPlayer", kuroScript.frame, player, target, status, simple, default);
	else
		return true;
	end;
end;

-- A function to send a player a creation fault.
function kuroScript.player.CreationError(player, fault)
	umsg.Start("ks_CharacterFinish", player)
		umsg.Bool(false);
		umsg.String(fault);
	umsg.End();
end;

-- A function to delete a player's character.
function kuroScript.player.DeleteCharacter(player, characterID)
	local character = player._Characters[characterID];
	
	-- Check if a statement is true.
	if (character) then
		local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
		local fault = hook.Call("PlayerCanDeleteCharacter", kuroScript.frame, player, character);
		local game = GAME_FOLDER;
		
		-- Check if a statement is true.
		if (fault == nil or fault == true) then
			umsg.Start("ks_CharacterRemove", player)
				umsg.Short(characterID);
			umsg.End();
			
			-- Remove this character from the MySQL database.
			tmysql.query("DELETE FROM "..charactersTable.." WHERE _Game = \""..game.."\" AND _SteamID = \""..player:SteamID().."\" AND _CharacterID = "..characterID);
			
			-- Print a debug message.
			kuroScript.frame:PrintDebug(player:SteamName().." deleted character '"..character._Name.."'.");
			
			-- Call a gamemode hook.
			hook.Call("PlayerDeleteCharacter", kuroScript.frame, player, character);
			
			-- Set some information.
			player._Characters[characterID] = nil;
		else
			kuroScript.player.CreationError(player, fault or "You cannot delete this character!");
		end;
	end;
end;

-- A function to use a player's character.
function kuroScript.player.UseCharacter(player, characterID)
	local character = player._Characters[characterID];
	
	-- Check if a statement is true.
	if (character) then
		local fault = hook.Call("PlayerCanUseCharacter", kuroScript.frame, player, character);
		
		-- Check if a statement is true.
		if (fault == nil or fault == true) then
			local limit = kuroScript.class.stored[character._Class].limit;
			local index = kuroScript.class.stored[character._Class].index;
			
			-- Check if a statement is true.
			if ( hook.Call("PlayerCanBypassClassLimit", player, character) ) then
				limit = MaxPlayers();
			end;
			
			-- Check if a statement is true.
			if (#kuroScript.class.GetPlayers(character._Class) == limit) then
				kuroScript.player.CreationError(player, "The "..character._Class.." class is full ("..limit.."/"..limit..")!");
			else
				kuroScript.player.LoadCharacter(player, characterID);
				
				-- Print a debug message.
				kuroScript.frame:PrintDebug(player:SteamName().." has loaded the character '"..character._Name.."'.");
			end;
		else
			kuroScript.player.CreationError(player, fault or "You cannot use this character!");
		end;
	end;
end;

-- A function to get a player's character.
function kuroScript.player.GetCharacter(player)
	return player._Character;
end;

-- A function to get a player's storage entity.
function kuroScript.player.GetStorageEntity(player)
	if ( player:GetStorageTable() ) then
		local entity = kuroScript.player.QueryStorage(player, "entity");
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then return entity; end;
	end;
end;

-- A function to get a player's storage table.
function kuroScript.player.GetStorageTable(player)
	return player._Storage;
end;

-- A function to query a player's storage.
function kuroScript.player.QueryStorage(player, key, default)
	local storage = player:GetStorageTable();
	
	-- Check if a statement is true.
	if (storage) then
		return storage[key] or default;
	else
		return default;
	end;
end;

-- A function to close storage for a player.
function kuroScript.player.CloseStorage(player, server)
	local storage = player:GetStorageTable();
	local OnClose = kuroScript.player.QueryStorage(player, "OnClose");
	local entity = kuroScript.player.QueryStorage(player, "entity");
	
	-- Check if a statement is true.
	if (storage and OnClose) then
		OnClose(player, storage, entity);
	end;
	
	-- Check if a statement is true.
	if (!server) then
		umsg.Start("ks_StorageClose", player);
		umsg.End();
	end;
	
	-- Set some information.
	player._Storage = nil;
end;

-- A function to get the weight of a player's storage.
function kuroScript.player.GetStorageWeight(player)
	if ( player:GetStorageTable() ) then
		local inventory = kuroScript.player.QueryStorage(player, "inventory");
		local currency = kuroScript.player.QueryStorage(player, "currency");
		local weight = ( currency * kuroScript.config.Get("currency_weight"):Get() );
		
		-- Loop through each value in a table.
		for k, v in pairs(inventory) do
			local itemTable = kuroScript.item.Get(k);
			
			-- Check if a statement is true.
			if (itemTable) then
				weight = weight + (math.max(itemTable.storageWeight or itemTable.weight, 0) * v );
			end;
		end;
		
		-- Return the weight.
		return weight;
	else
		return 0;
	end;
end;

-- A function to open storage for a player.
function kuroScript.player.OpenStorage(player, data)
	local storage = player:GetStorageTable();
	local OnClose = kuroScript.player.QueryStorage(player, "OnClose");
	
	-- Check if a statement is true.
	if (storage and OnClose) then
		OnClose(player, storage, storage.entity);
	end;
	
	-- Set some information.
	data.inventory = data.inventory or {};
	data.currency = data.currency or 0;
	data.entity = data.entity or player;
	data.weight = data.weight or kuroScript.config.Get("default_inv_weight"):Get();
	data.name = data.name or "Storage";
	
	-- Set some information.
	player._Storage = data;
	
	-- Start a user message.
	umsg.Start("ks_StorageStart", player);
		umsg.Entity(data.entity);
		umsg.String(data.name);
	umsg.End();
	
	-- Update the player's storage information.
	kuroScript.player.UpdateStorageCurrency(player, data.currency);
	kuroScript.player.UpdateStorageWeight(player, data.weight);
	
	-- Loop through each value in a table.
	for k, v in pairs(data.inventory) do
		kuroScript.player.UpdateStorageItem(player, k);
	end;
end;

-- A function to update a player's storage currency.
function kuroScript.player.UpdateStorageCurrency(player, currency)
	local storageTable = player:GetStorageTable();
	local k, v;
	
	-- Check if a statement is true.
	if (storageTable) then
		local inventory = kuroScript.player.QueryStorage(player, "inventory");
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( v:GetStorageTable() ) then
					if (kuroScript.player.QueryStorage(v, "inventory") == inventory) then
						v._Storage.currency = currency;
						
						-- Start a user message.
						umsg.Start("ks_StorageCurrency", v);
							umsg.Long(currency);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to update a player's storage weight.
function kuroScript.player.UpdateStorageWeight(player, weight)
	local k, v;
	
	-- Check if a statement is true.
	if ( player:GetStorageTable() ) then
		local inventory = kuroScript.player.QueryStorage(player, "inventory");
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( v:GetStorageTable() ) then
					if (kuroScript.player.QueryStorage(v, "inventory") == inventory) then
						v._Storage.weight = weight;
						
						-- Start a user message.
						umsg.Start("ks_StorageWeight", v);
							umsg.Float(weight);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get whether a player can give to storage.
function kuroScript.player.CanGiveToStorage(player, item)
	local itemTable = kuroScript.item.Get(item);
	local entity = kuroScript.player.QueryStorage(player, "entity");
	
	-- Check if a statement is true.
	if (itemTable) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerGive = (!entity:IsPlayer() or itemTable.allowPlayerGive != false);
		local allowEntityGive = (entity:IsPlayer() or itemTable.allowEntityGive != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowGive = (itemTable.allowGive != false);
		local shipment = (entity and entity:GetClass() == "ks_shipment");
		
		-- Check if a statement is true.
		if ( shipment or (allowPlayerStorage and allowPlayerGive and allowStorage and allowGive) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can take from storage.
function kuroScript.player.CanTakeFromStorage(player, item)
	local itemTable = kuroScript.item.Get(item);
	local entity = kuroScript.player.QueryStorage(player, "entity");
	
	-- Check if a statement is true.
	if (itemTable) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerTake = (!entity:IsPlayer() or itemTable.allowPlayerTake != false);
		local allowEntityTake = (entity:IsPlayer() or itemTable.allowEntityTake != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowTake = (itemTable.allowTake != false);
		local shipment = (entity and entity:GetClass() == "ks_shipment");
		
		-- Check if a statement is true.
		if ( shipment or (allowPlayerStorage and allowPlayerTake and allowStorage and allowTake) ) then
			return true;
		end;
	end;
end;

-- A function to update each player's storage for a player.
function kuroScript.player.UpdateStorageForPlayer(player, item)
	local inventory = player:QueryCharacter("inventory");
	local currency = player:QueryCharacter("currency");
	local k, v;
	
	-- Check if a statement is true.
	if (item) then
		local itemTable = kuroScript.item.Get(item);
		
		-- Check if a statement is true.
		if (itemTable) then
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (kuroScript.player.QueryStorage(v, "inventory") == inventory) then
							umsg.Start("ks_StorageItem", v);
								umsg.Long(itemTable.index);
								umsg.Long(inventory[itemTable.uniqueID] or 0);
							umsg.End();
						end;
					end;
				end;
			end;
		end;
	else
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( v:GetStorageTable() ) then
					if (kuroScript.player.QueryStorage(v, "inventory") == inventory) then
						v._Storage.currency = currency;
						
						-- Start a user message.
						umsg.Start("ks_StorageCurrency", v);
							umsg.Long(currency);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to update a storage item for a player.
function kuroScript.player.UpdateStorageItem(player, item, amount)
	local k, v;
	
	-- Check if a statement is true.
	if ( player:GetStorageTable() ) then
		local inventory = kuroScript.player.QueryStorage(player, "inventory");
		local itemTable = kuroScript.item.Get(item);
		
		-- Check if a statement is true.
		if (itemTable) then
			item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if (amount) then
				if ( amount < 0 and !kuroScript.player.CanTakeFromStorage(player, item) ) then
					return;
				elseif ( amount > 0 and !kuroScript.player.CanGiveToStorage(player, item) ) then
					return;
				end;
			end;
			
			-- Check if a statement is true.
			if (amount) then
				inventory[item] = inventory[item] or 0;
				inventory[item] = inventory[item] + amount;
			end;
			
			-- Loop through each value in a table.
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (kuroScript.player.QueryStorage(v, "inventory") == inventory) then
							if (amount or player == v) then
								umsg.Start("ks_StorageItem", v);
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

-- A function to format text based on a relationship.
function kuroScript.player.FormatKnownText(player, text, ...)
	for i = 1, #arg do
		if ( string.find(text, "%%s") and ValidEntity( arg[i] ) ) then
			local name = kuroScript.config.Get("anonymous_name"):Get();
			
			-- Check if a statement is true.
			if ( kuroScript.player.KnowsPlayer( player, arg[i] ) ) then
				name = arg[i]:Name();
			end;
			
			-- Set some information.
			text = string.gsub(text, "%%s", name, 1);
		end;
	end;
	
	-- Return the text.
	return text;
end;

-- A function to restore a known name.
function kuroScript.player.RestoreKnownName(player, target)
	local knownNames = player:QueryCharacter("knownNames");
	local key = target:QueryCharacter("key");
	
	-- Check if a statement is true.
	if ( knownNames[key] ) then
		if ( hook.Call("PlayerCanRestoreKnownName", kuroScript.frame, player, target) ) then
			kuroScript.player.SetPlayerKnown(player, target, knownNames[key], true);
		else
			knownNames[key] = nil;
		end;
	end;
end;

-- A function to restore a player's known names.
function kuroScript.player.RestoreKnownNames(player)
	if ( kuroScript.config.Get("save_known_names"):Get() ) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				kuroScript.player.RestoreKnownName(player, v);
				kuroScript.player.RestoreKnownName(v, player);
			end;
		end;
	end;
end;

-- A function to set whether a player knows a player.
function kuroScript.player.SetPlayerKnown(player, target, status, force)
	local knownNames = player:QueryCharacter("knownNames");
	local name = target:Name();
	local key = target:QueryCharacter("key");
	
	-- Check if a statement is true.
	if (status == KNOWN_SAVE) then
		if ( kuroScript.config.Get("save_known_names"):Get() ) then
			if ( !hook.Call("PlayerCanSaveKnownName", kuroScript.frame, player, target) ) then
				status = KNOWN_TOTAL;
			end;
		else
			status = KNOWN_TOTAL;
		end;
	end;
	
	-- Check if a statement is true.
	if ( !status or force or !kuroScript.player.KnowsPlayer(player, target, status) ) then
		knownNames[key] = status or nil;
		
		-- Set some information.
		status = status or 0;
		
		-- Start a user message.
		umsg.Start("ks_KnownName", player);
			umsg.Long(key); umsg.Short(status);
		umsg.End();
	end;
end;

-- A function to get a player's details.
function kuroScript.player.GetDetails(player)
	local details = player:GetSharedVar("ks_Details");
	local team = player:Team();
	
	-- Check if a statement is true.
	if (details == "") then
		details = kuroScript.vocation.Query(team, "defaultDetails");
		
		-- Check if a statement is true.
		if (!details) then
			details = kuroScript.config.Get("default_details"):Get();
		end;
		
		-- Check if a statement is true.
		if (details != "") then
			details = kuroScript.frame:ModifyDetails(details);
		end;
	end;
	
	-- Check if a statement is true.
	if (details == "") then
		return g_Team.GetName(team);
	else
		return details;
	end;
end;

-- A function to clear a player's known names list.
function kuroScript.player.ClearKnownNames(player, status, simple)
	if (!status) then
		local character = player:GetCharacter();
		
		-- Check if a statement is true.
		if (character) then
			character._KnownNames = {};
			
			-- Start a user message.
			umsg.Start("ks_ClearKnownNames", player);
			umsg.End();
		end;
	else
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( kuroScript.player.KnowsPlayer(player, v, status, simple) ) then
					kuroScript.player.SetPlayerKnown(player, v, false);
				end;
			end;
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("PlayerKnownNamesCleared", player, status, simple);
end;

-- A function to clear a player's name from being known.
function kuroScript.player.ClearName(player, status, simple)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( !status or kuroScript.player.KnowsPlayer(v, player, status, simple) ) then
				kuroScript.player.SetPlayerKnown(v, player, false);
			end;
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("PlayerNameCleared", player, status, simple);
end;

-- A function to holsters all of a player's weapons.
function kuroScript.player.HolsterAll(player)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = kuroScript.item.GetWeapon(v);
		
		-- Check if a statement is true.
		if (itemTable) then
			if ( hook.Call("PlayerCanHolsterWeapon", kuroScript.frame, player, itemTable, true, true) ) then
				player:StripWeapon(class);
				
				-- Update the player's inventory.
				kuroScript.inventory.Update(player, itemTable.uniqueID, 1, true);
				
				-- Call a gamemode hook.
				hook.Call("PlayerHolsterWeapon", kuroScript.frame, player, itemTable, true);
			end;
		end;
	end;
	
	-- Make the player select a weapon.
	player:SelectWeapon("ks_hands");
end;

-- A function to get a player's shared variable.
function kuroScript.player.GetSharedVar(player, key)
	if ( ValidEntity(player) ) then
		if (!NWTYPE_STRING) then
			return player:GetNetworkedVar(key);
		else
			return player[key];
		end;
	end;
end;

-- A function to set a shared variable for a player.
function kuroScript.player.SetSharedVar(player, key, value)
	if ( ValidEntity(player) ) then
		if (!NWTYPE_STRING) then
			player:SetNetworkedVar(key, value);
		else
			player[key] = value;
		end;
	end;
end;

-- A function to set whether a player's character is banned.
function kuroScript.player.SetBanned(player, banned)
	player:SetCharacterData("banned", banned);
	
	-- Save the player's character.
	kuroScript.player.SaveCharacter(player);
end;

-- A function to set a player's name.
function kuroScript.player.SetName(player, name, saveless)
	local previousName = player:QueryCharacter("name");
	local newName = name;
	
	-- Set some information.
	player:SetCharacterData("name", newName, true);
	player:SetSharedVar("ks_Name", newName);
	
	-- Check if a statement is true.
	if (!player._FirstSpawn) then
		hook.Call("PlayerNameChanged", kuroScript.frame, player, previousName, newName);
	end;
	
	-- Check if a statement is true.
	if (!saveless) then
		kuroScript.player.SaveCharacter(player);
	end;
end;

-- A function to get a player's property count.
function kuroScript.player.GetPropertyCount(player, class)
	local count = 0;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.player.property) do
		if ( player:QueryCharacter("key") == kuroScript.entity.QueryProperty(v, "key") ) then
			if (!class or v:GetClass() == class) then
				count = count + 1;
			end;
		end;
	end;
	
	-- Return the count.
	return count;
end;

-- A function to get a player's door count.
function kuroScript.player.GetDoorCount(player)
	local count = 0;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.player.property) do
		if ( kuroScript.entity.IsDoor(v) and !kuroScript.entity.GetDoorParent(v) ) then
			if ( player:QueryCharacter("key") == kuroScript.entity.QueryProperty(v, "key") ) then
				count = count + 1;
			end;
		end;
	end;
	
	-- Return the count.
	return count;
end;

-- A function to take a player's door access.
function kuroScript.player.TakeDoorAccess(player, door)
	if (door._AccessList) then
		door._AccessList[ player:QueryCharacter("key") ] = nil;
	end;
end;

-- A function to give a player door access.
function kuroScript.player.GiveDoorAccess(player, door, access)
	local key = player:QueryCharacter("key");
	
	-- Check if a statement is true.
	if (!door._AccessList) then
		door._AccessList = {
			[key] = access
		};
	else
		door._AccessList[key] = access;
	end;
end;

-- A function to check if a player has door access.
function kuroScript.player.HasDoorAccess(player, door, access, simple)
	if (!access) then
		return kuroScript.player.HasDoorAccess(player, door, DOOR_ACCESS_BASIC, simple);
	else
		return hook.Call("PlayerDoesHaveDoorAccess", kuroScript.frame, player, door, access, simple);
	end;
end;

-- A function to check if a player can afford an amount.
function kuroScript.player.CanAfford(player, amount)
	return player:QueryCharacter("currency") >= amount;
end;

-- A function to give a player an amount of currency.
function kuroScript.player.GiveCurrency(player, amount, reason, silent)
	local roundedAmount = math.Round(amount);
	local currency = math.Round( math.max(player:QueryCharacter("currency") + roundedAmount, 0) );
	
	-- Set some information.
	player:SetCharacterData("currency", currency, true);
	player:SetSharedVar("ks_Currency", currency);
	
	-- Check if a statement is true.
	if (roundedAmount < 0) then
		roundedAmount = math.abs(roundedAmount);
		
		-- Check if a statement is true.
		if (!silent) then
			if (reason) then
				kuroScript.player.Alert( player, "- "..FORMAT_CURRENCY(roundedAmount).." ("..reason..")", Color(150, 50, 50, 255) );
			else
				kuroScript.player.Alert( player, "- "..FORMAT_CURRENCY(roundedAmount), Color(150, 50, 50, 255) );
			end;
		end;
	elseif (roundedAmount > 0) then
		if (!silent) then
			if (reason) then
				kuroScript.player.Alert( player, "+ "..FORMAT_CURRENCY(roundedAmount).." ("..reason..")", Color(75, 150, 50, 255) );
			else
				kuroScript.player.Alert( player, "+ "..FORMAT_CURRENCY(roundedAmount), Color(75, 150, 50, 255) );
			end;
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("PlayerCurrencyUpdated", kuroScript.frame, player, roundedAmount, reason, silent);
end;

-- A function to show cinematic text to a player.
function kuroScript.player.CinematicText(player, text, color, hangTime)
	datastream.StreamToClients( {player}, "ks_CinematicText", {text = text, color = color, hangTime = hangTime} );
end;

-- A function to show cinematic text to each player.
function kuroScript.player.CinematicTextAll(text, color, hangTime)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			kuroScript.player.CinematicText(v, text, color, hangTime);
		end;
	end;
end;

-- A function to alert a player.
function kuroScript.player.Alert(player, text, color)
	datastream.StreamToClients( {player}, "ks_Alert", {text = text, color = color} );
end;

-- A function to alert each player.
function kuroScript.player.AlertAll(text, color)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			kuroScript.player.Alert(v, text, color);
		end;
	end;
end;

-- A function to get a player by a part of their name.
function kuroScript.player.Get(name)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( string.find(string.lower( v:Name() ), string.lower(name), 1, true) ) then
				return v;
			end;
		end;
	end;
	
	-- Return false to break the function.
	return false;
end;

-- A function to notify each player in a radius.
function kuroScript.player.NotifyInRadius(text, class, position, radius)
	local listeners = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (position:Distance( v:GetPos() ) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;
	
	-- Notify the player.
	kuroScript.player.Notify(listeners, text, class);
end;

-- A function to notify each player.
function kuroScript.player.NotifyAll(text, class)
	kuroScript.player.Notify(nil, text, true);
end;

-- A function to notify a player.
function kuroScript.player.Notify(player, text, class)
	if (type(player) == "table") then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(player) do
			kuroScript.player.Notify(v, text, class);
		end;
	elseif (class == true) then
		kuroScript.chatBox.Add(player, nil, "notify_all", text);
	elseif (!class) then
		kuroScript.chatBox.Add(player, nil, "notify", text);
	else
		umsg.Start("ks_Notification", player);
			umsg.String(text);
			umsg.Short(class);
		umsg.End();
	end;
end;

-- A function to set a player's weapons list from a table.
function kuroScript.player.SetWeapons(player, weapons, forceReturn)
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(weapons) do
		if ( player:HasWeapon(v[1].class) ) then
			if ( v[2] ) then
				local itemTable = kuroScript.item.GetWeapon(v[1].class, v[1].uniqueID);
				
				-- Check if a statement is true.
				if (itemTable) then
					kuroScript.inventory.Update(player, itemTable.uniqueID, 1, true);
					
					-- Call a gamemode hook.
					hook.Call("PlayerHolsterWeapon", kuroScript.frame, player, itemTable, true);
				end;
			end;
		elseif ( !v[3] or player:Team() == v[3] ) then
			player:Give(v[1].class, v[1].uniqueID, forceReturn);
		end;
	end;
end;

-- A function to give ammo to a player from a table.
function kuroScript.player.GiveAmmo(player, ammo)
	for k, v in pairs(ammo) do player:GiveAmmo(v, k); end;
end;

-- A function to set a player's ammo list from a table.
function kuroScript.player.SetAmmo(player, ammo)
	for k, v in pairs(ammo) do player:SetAmmo(v, k); end;
end;

-- A function to get a player's ammo list as a table.
function kuroScript.player.GetAmmo(player, strip)
	local spawnAmmo = kuroScript.player.GetSpawnAmmo(player);
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
	
	-- Check if a statement is true.
	if (spawnAmmo) then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(spawnAmmo) do
			if ( ammo[k] ) then
				ammo[k] = math.max(ammo[k] - v, 0);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (strip) then
		player:RemoveAllAmmo();
	end;
	
	-- Return the ammo table.
	return ammo;
end;

-- A function to get a player's weapons list as a table.
function kuroScript.player.GetWeapons(player, keep)
	local weapons = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( player:GetWeapons() ) do
		local team = player:Team();
		local class = v:GetClass();
		local uniqueID = v:GetNetworkedString("ks_UniqueID");
		local itemTable = kuroScript.item.GetWeapon(v);
		
		-- Check if a statement is true.
		if ( !kuroScript.player.GetSpawnWeapon(player, class) ) then
			team = nil;
		end;
		
		-- Check if a statement is true.
		if ( itemTable and hook.Call("PlayerCanHolsterWeapon", kuroScript.frame, player, itemTable, true, true) ) then
			weapons[#weapons + 1] = { {class = class, uniqueID = uniqueID}, true, team };
		else
			weapons[#weapons + 1] = { {class = class, uniqueID = uniqueID}, false, team };
		end;
		
		-- Check if a statement is true.
		if (!keep) then
			player:StripWeapon(class);
		end;
	end;
	
	-- Return the weapons table.
	return weapons;
end;

-- A function to get the total weight of a player's equipped weapons.
function kuroScript.player.GetEquippedWeight(player)
	local weight = 0;
	
	-- Loop through each value in a table.
	for k, v in pairs( player:GetWeapons() ) do
		local itemTable = kuroScript.item.GetWeapon(v);
		
		-- Check if a statement is true.
		if (itemTable) then
			weight = weight + itemTable.weight;
		end;
	end;
	
	-- Return the weight.
	return weight;
end;

-- A function to get a player's holstered weapon.
function kuroScript.player.GetHolsteredWeapon(player)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = kuroScript.item.GetWeapon(v);
		
		-- Check if a statement is true.
		if (itemTable) then
			if (kuroScript.player.GetWeaponClass(player) != class) then
				return class;
			end;
		end;
	end;
end;

-- A function to check whether a player is ragdolled.
function kuroScript.player.IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		local ragdolled = player:GetSharedVar("ks_Ragdolled");
		
		-- Check if a statement is true.
		if (ragdolled == exception) then
			return false;
		else
			return (ragdolled != RAGDOLL_NONE);
		end;
	end;
end;

-- A function to set a player's unragdoll time.
function kuroScript.player.SetUnragdollTime(player, delay)
	player._UnragdollPaused = nil;
	
	-- Check if a statement is true.
	if (delay) then
		kuroScript.player.SetAction(player, "unragdoll", delay, 2, function()
			if ( ValidEntity(player) and player:Alive() ) then
				kuroScript.player.SetRagdollState(player, RAGDOLL_NONE);
			end;
		end);
	else
		kuroScript.player.SetAction(player, "unragdoll", false);
	end;
end;

-- A function to pause a player's unragdoll time.
function kuroScript.player.PauseUnragdollTime(player)
	if (!player._UnragdollPaused) then
		local unragdollTime = kuroScript.player.GetUnragdollTime(player);
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if ( player:IsRagdolled() ) then
			if (unragdollTime > 0) then
				player._UnragdollPaused = unragdollTime - curTime;
				
				-- Set some information.
				kuroScript.player.SetAction(player, "unragdoll", false);
			end;
		end;
	end;
end;

-- A function to start a player's unragdoll time.
function kuroScript.player.StartUnragdollTime(player)
	if (player._UnragdollPaused) then
		if ( player:IsRagdolled() ) then
			kuroScript.player.SetUnragdollTime(player, player._UnragdollPaused);
			
			-- Set some information.
			player._UnragdollPaused = nil;
		end;
	end;
end;

-- A function to get a player's unragdoll time.
function kuroScript.player.GetUnragdollTime(player)
	local action, actionDuration, startActionTime = kuroScript.player.GetAction(player);
	
	-- Check if a statement is true.
	if (action == "unragdoll") then
		return startActionTime + actionDuration;
	else
		return 0;
	end;
end;

-- A function to get a player's ragdoll state.
function kuroScript.player.GetRagdollState(player)
	return player:GetSharedVar("ks_Ragdolled");
end;

-- A function to get a player's ragdoll entity.
function kuroScript.player.GetRagdollEntity(player)
	if (player._RagdollTable) then
		if ( ValidEntity(player._RagdollTable.entity) ) then
			return player._RagdollTable.entity;
		end;
	end;
end;

-- A function to get a player's ragdoll table.
function kuroScript.player.GetRagdollTable(player)
	return player._RagdollTable;
end;

-- A function to do a player's ragdoll decay check.
function kuroScript.player.DoRagdollDecayCheck(player, ragdoll)
	local index = ragdoll:EntIndex();
	
	-- Set some information.
	kuroScript.frame:CreateTimer("Decay Check: "..index, 60, 0, function()
		local ragdollIsValid = ValidEntity(ragdoll);
		local playerIsValid = ValidEntity(player);
		
		-- Check if a statement is true.
		if (!playerIsValid and ragdollIsValid) then
			if ( !kuroScript.entity.IsDecaying(ragdoll) ) then
				local decayTime = kuroScript.config.Get("body_decay_time"):Get();
				
				-- Check if a statement is true.
				if ( decayTime > 0 and hook.Call("PlayerCanRagdollDecay", kuroScript.frame, player, ragdoll, decayTime) ) then
					kuroScript.entity.Decay(ragdoll, decayTime);
				end;
			else
				kuroScript.frame:DestroyTimer("Decay Check: "..index);
			end;
		elseif (!ragdollIsValid) then
			kuroScript.frame:DestroyTimer("Decay Check: "..index);
		end;
	end);
end;

-- A function to set a player's ragdoll state.
function kuroScript.player.SetRagdollState(player, state, delay, decay, force)
	if (state == RAGDOLL_KNOCKEDOUT or state == RAGDOLL_FALLENOVER) then
		if ( player:IsRagdolled() ) then
			if ( hook.Call("PlayerCanRagdoll", kuroScript.frame, player, state, delay, decay, player._RagdollTable) ) then
				kuroScript.player.SetUnragdollTime(player, delay);
				
				-- Set some information.
				player:SetSharedVar("ks_Ragdolled", state);

				-- Set some information.
				player._RagdollTable.delay = delay;
				player._RagdollTable.decay = decay;
				
				-- Call a gamemode hook.
				hook.Call("PlayerRagdolled", kuroScript.frame, player, state, player._RagdollTable);
			end;
		elseif ( hook.Call("PlayerCanRagdoll", kuroScript.frame, player, state, delay, decay) ) then
			local velocity = (player:GetVelocity() * 1.5) + (player:GetAimVector() * 80);
			local ragdoll = ents.Create("prop_ragdoll");
			local i;
			
			-- Set some information.
			ragdoll:SetMaterial( player:GetMaterial() );
			ragdoll:SetAngles( player:GetAngles() );
			ragdoll:SetColor( player:GetColor() );
			ragdoll:SetModel( player:GetModel() );
			ragdoll:SetSkin( player:GetSkin() );
			ragdoll:SetPos( player:GetPos() );
			ragdoll:Spawn();
			
			-- Set some information.
			player._RagdollTable = {};
			player._RagdollTable.eyeAngles = player:EyeAngles();
			player._RagdollTable.immunity = CurTime() + kuroScript.config.Get("ragdoll_immunity_time"):Get();
			player._RagdollTable.moveType = MOVETYPE_WALK;
			player._RagdollTable.entity = ragdoll;
			player._RagdollTable.health = player:Health();
			player._RagdollTable.armor = player:Armor();
			player._RagdollTable.delay = delay;
			player._RagdollTable.decay = decay;
			
			-- Check if a statement is true.
			if ( ValidEntity(ragdoll) ) then
				ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				
				-- Loop through each value in a table.
				for i = 1, ragdoll:GetPhysicsObjectCount() do
					local physicsObject = ragdoll:GetPhysicsObjectNum(i);
					local position, angle = player:GetBonePosition( ragdoll:TranslatePhysBoneToBone(i) );
					
					-- Check if a statement is true.
					if ( ValidEntity(physicsObject) ) then
						physicsObject:SetPos(position);
						physicsObject:SetAngle(angle);
						physicsObject:SetVelocity(velocity);
						
						-- Check if a statement is true.
						if (force) then
							physicsObject:ApplyForceCenter(force);
						end;
					end;
				end;
			end;
			
			-- Check if a statement is true.
			if ( player:Alive() ) then
				if ( ValidEntity( player:GetActiveWeapon() ) ) then
					player._RagdollTable.weapon = kuroScript.player.GetWeaponClass(player);
				end;
				
				-- Set some information.
				player._RagdollTable.weapons = kuroScript.player.GetWeapons(player, true);
				
				-- Check if a statement is true.
				if (delay) then
					kuroScript.player.SetUnragdollTime(player, delay);
				end;
			end;
			
			-- Check if a statement is true.
			if ( player:InVehicle() ) then
				player:ExitVehicle();
				
				-- Set some information.
				player._RagdollTable.eyeAngles = Angle(0, 0, 0);
			end;
			
			-- Check if a statement is true.
			if ( player:IsOnFire() ) then
				ragdoll:Ignite(8, 0);
			end;
			
			-- Set some information.
			player:Spectate(OBS_MODE_CHASE);
			player:Flashlight(false);
			player:RunCommand("-duck");
			player:RunCommand("-voicerecord");
			player:SetMoveType(MOVETYPE_OBSERVER);
			player:StripWeapons(true);
			player:SpectateEntity(ragdoll);
			player:CrosshairDisable();
			
			-- Set some information.
			player._UnragdollPaused = nil;
			
			-- Set some information.
			player:SetSharedVar("ks_Ragdolled", state);
			player:SetSharedVar("ks_Ragdoll", ragdoll);
			
			-- Give the player their death code.
			if (state != RAGDOLL_FALLENOVER) then
				kuroScript.player.GiveDeathCode(player);
			end;
			
			-- Set the entity's player.
			kuroScript.entity.SetPlayer(ragdoll, player);
			kuroScript.player.DoRagdollDecayCheck(player, ragdoll);
			
			-- Call a gamemode hook.
			hook.Call("PlayerRagdolled", kuroScript.frame, player, state, player._RagdollTable);
		end;
	elseif (state == RAGDOLL_NONE or state == RAGDOLL_RESET) then
		if ( player:IsRagdolled(nil, true) ) then
			local ragdollTable = player:GetRagdollTable();
			
			-- Check if a statement is true.
			if ( hook.Call("PlayerCanUnragdoll", kuroScript.frame, player, state, ragdollTable) ) then
				player:UnSpectate();
				player:CrosshairEnable();
				
				-- Check if a statement is true.
				if (state != RAGDOLL_RESET) then
					kuroScript.player.LightSpawn(player, nil, nil, true);
				end;
				
				-- Check if a statement is true.
				if (state != RAGDOLL_RESET) then
					if ( ValidEntity(ragdollTable.entity) ) then
						local position = kuroScript.entity.GetPelvisPosition(ragdollTable.entity);
						
						-- Check if a statement is true.
						if (position) then
							kuroScript.player.SetSafePosition(player, position, ragdollTable.entity);
						end;
						
						-- Set some information.
						player:SetSkin( ragdollTable.entity:GetSkin() );
						player:SetColor( ragdollTable.entity:GetColor() );
						player:SetModel( ragdollTable.entity:GetModel() );
						player:SetMaterial( ragdollTable.entity:GetMaterial() );
					end;
					
					-- Set some information.
					player:SetArmor(ragdollTable.armor);
					player:SetHealth(ragdollTable.health);
					player:SetMoveType(ragdollTable.moveType);
					player:SetEyeAngles(ragdollTable.eyeAngles);
				end;
				
				-- Check if a statement is true.
				if ( ValidEntity(ragdollTable.entity) ) then
					kuroScript.frame:DestroyTimer( "Decay Check: "..ragdollTable.entity:EntIndex() );
					
					-- Check if a statement is true.
					if (ragdollTable.decay) then
						if ( hook.Call("PlayerCanRagdollDecay", kuroScript.frame, player, ragdollTable.entity, ragdollTable.decay) ) then
							kuroScript.entity.Decay(ragdollTable.entity, ragdollTable.decay);
						end;
					else
						ragdollTable.entity:Remove();
					end;
				end;
				
				-- Check if a statement is true.
				if (state != RAGDOLL_RESET) then
					kuroScript.player.SetWeapons(player, ragdollTable.weapons, true);
					
					-- Check if a statement is true.
					if (ragdollTable.weapon) then
						player:SelectWeapon(ragdollTable.weapon);
					end;
				end;
				
				-- Set some information.
				kuroScript.player.SetUnragdollTime(player, false);
				
				-- Set some information.
				player:SetSharedVar("ks_Ragdolled", RAGDOLL_NONE);
				player:SetSharedVar("ks_Ragdoll", NULL);
				
				-- Call a gamemode hook.
				hook.Call("PlayerUnragdolled", kuroScript.frame, player, state, ragdollTable);
				
				-- Set some information.
				player._UnragdollPaused = nil;
				player._RagdollTable = {};
			end;
		end;
	end;
end;

-- A function to make a player drop their weapons.
function kuroScript.player.DropWeapons(player, attacker)
	local ragdollEntity = player:GetRagdollEntity();
	local k, v;
	
	-- Check if a statement is true.
	if ( player:IsRagdolled() ) then
		local ragdollTable = player:GetRagdollTable();
		
		-- Loop through each value in a table.
		for k, v in pairs(ragdollTable.weapons) do
			if ( v[2] ) then
				local itemTable = kuroScript.item.GetWeapon(v[1].class, v[1].uniqueID);
				
				-- Check if a statement is true.
				if (itemTable) then
					if ( hook.Call("PlayerCanDropWeapon", kuroScript.frame, player, attacker, itemTable, true) ) then
						kuroScript.entity.CreateItem( player, itemTable.uniqueID, ragdollEntity:GetPos() + Vector( 0, 0, math.random(1, 48) ) );
						
						-- Set some information.
						ragdollTable.weapons[k] = nil;
					end;
				end;
			end;
		end;
	else
		for k, v in pairs( player:GetWeapons() ) do
			local itemTable = kuroScript.item.GetWeapon(v);
			
			-- Check if a statement is true.
			if (itemTable) then
				if ( hook.Call("PlayerCanDropWeapon", kuroScript.frame, player, attacker, itemTable, true) ) then
					kuroScript.entity.CreateItem( player, itemTable.uniqueID, player:GetPos() + Vector( 0, 0, math.random(1, 48) ) );
					
					-- Strip the weapon from the player.
					player:StripWeapon( v:GetClass() );
				end;
			end;
		end;
	end;
end;

-- A function to lightly spawn a player.
function kuroScript.player.LightSpawn(player, weapons, ammo, forceReturn)
	if (player:IsRagdolled() and !forceReturn) then
		kuroScript.player.SetRagdollState(player, RAGDOLL_NONE);
	end;
	
	-- Set some information.
	player._LightSpawn = true;
	
	-- Set some information.
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
	
	-- Check if a statement is true.
	if (ammo) then
		if (type(ammo) != "table") then
			ammo = kuroScript.player.GetAmmo(player, true);
		end;
	end;
	
	-- Check if a statement is true.
	if (weapons) then
		if (type(weapons) != "table") then
			weapons = kuroScript.player.GetWeapons(player);
		end;
		
		-- Check if a statement is true.
		if ( ValidEntity(weapon) ) then
			weapon = weapon:GetClass();
		end;
	end;
	
	-- Set some information.
	player._LightSpawnCallback = function(player, gamemodeHook)
		if (weapons) then
			kuroScript.frame:PlayerLoadout(player);
			
			-- Set the player's weapons.
			kuroScript.player.SetWeapons(player, weapons, forceReturn);
			
			-- Check if a statement is true.
			if (type(weapon) == "string") then
				player:SelectWeapon(weapon);
			end;
		end;
		
		-- Check if a statement is true.
		if (ammo) then
			kuroScript.player.GiveAmmo(player, ammo);
		end;
		
		-- Set some information.
		player:SetPos(position);
		player:SetSkin(skin);
		player:SetModel(model);
		player:SetColor(color);
		player:SetArmor(armor);
		player:SetHealth(health);
		player:SetMaterial(material);
		player:SetMoveType(moveType);
		player:SetEyeAngles(angles);
		
		-- Check if a statement is true.
		if (gamemodeHook) then
			special = special or false;
			
			-- Call a gamemode hook.
			hook.Call("PostPlayerLightSpawn", kuroScript.frame, player, weapons, ammo, special);
		end;
	end;
	
	-- Spawn the player.
	player:Spawn();
end;

-- A function to get a player's characters.
function kuroScript.player.GetCharacters(player, callback)
	if ( ValidEntity(player) ) then
		local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
		local game = GAME_FOLDER;
		
		-- Perform a thread query.
		tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Game = \""..game.."\" AND _SteamID = \""..player:SteamID().."\"", function(result)
			if ( ValidEntity(player) ) then
				if (result and type(result) == "table" and #result > 0) then
					callback(result);
				else
					callback();
				end;
			end;
		end, 1);
	end
end;

-- A function to add a character to the character screen.
function kuroScript.player.CharacterScreenAdd(player, character)
	local info = {
		tags = {},
		name = character._Name,
		model = character._Model,
		class = character._Class,
		banned = character._Data["banned"],
		gender = character._Gender,
		characterID = character._CharacterID
	};
	
	-- Call a gamemode hook.
	hook.Call("PlayerAdjustCharacterScreenInfo", kuroScript.frame, player, character, info);
	
	-- Start a data stream.
	datastream.StreamToClients( {player}, "ks_CharacterAdd", info );
end;

-- A function to convert a character's MySQL variables to Lua variables.
function kuroScript.player.ConvertCharacterMySQL(base)
	base._CharacterID = tonumber(base._CharacterID);
	base._KnownNames = kuroScript.player.ConvertCharacterKnownNamesString(base._KnownNames);
	base._Attributes = kuroScript.player.ConvertCharacterDataString(base._Attributes);
	base._Inventory = kuroScript.player.ConvertCharacterDataString(base._Inventory);
	base._Currency = tonumber(base._Currency);
	base._Ammo = kuroScript.player.ConvertCharacterDataString(base._Ammo);
	base._Data = kuroScript.player.ConvertCharacterDataString(base._Data);
	base._Key = tonumber(base._Key);
end;

-- A function to load a player's character.
function kuroScript.player.LoadCharacter(player, characterID, mergeCreate, callback, force)
	local character = {};
	
	-- Check if a statement is true.
	if (mergeCreate) then
		character = {};
		character._Name = name;
		character._Game = GAME_FOLDER;
		character._Data = {};
		character._Ammo = {};
		character._Model = "models/police.mdl";
		character._Class = "Citizen";
		character._Access = "b";
		character._Gender = GENDER_MALE;
		character._SteamID = player:SteamID();
		character._Currency = kuroScript.config.Get("default_currency"):Get();
		character._SteamName = player:SteamName();
		character._Inventory = {};
		character._Attributes = {};
		character._KnownNames = {};
		character._CharacterID = characterID;
		
		-- Check if a statement is true.
		if ( !player._Characters[characterID] ) then
			table.Merge(character, mergeCreate);
			
			-- Set some information.
			character._Inventory = kuroScript.inventory.GetDefault(player, character);
			character._Attributes = kuroScript.attributes.GetDefault(player, character);
			
			-- Check if a statement is true.
			if (!force) then
				local fault = hook.Call("PlayerCanCreateCharacter", kuroScript.frame, player, character, characterID);
				
				-- Check if a statement is true.
				if (fault == false or type(fault) == "string") then
					return kuroScript.player.CreationError(fault or "You cannot create this character!");
				end;
			end;
			
			-- Save the player's character.
			kuroScript.player.SaveCharacter(player, true, character, function(key)
				player._Characters[characterID] = character;
				player._Characters[characterID]._Key = key;
				
				-- Call a gamemode hook.
				hook.Call("PlayerCharacterCreated", player, character);
				
				-- Check if a statement is true.
				kuroScript.player.CharacterScreenAdd(player, character);
				
				-- Check if a statement is true.
				if (callback) then
					callback();
				end;
			end);
		end;
	else
		character = player._Characters[characterID];
		
		-- Check if a statement is true.
		if (character) then
			player._Character = character;
			
			-- Set the player's basic shared variables.
			kuroScript.player.SetBasicSharedVars(player);
			
			-- Call a gamemode hook.
			hook.Call("PlayerCharacterLoaded", kuroScript.frame, player);
		end;
	end;
end;

-- A function to set a player's basic shared variables.
function kuroScript.player.SetBasicSharedVars(player)
	local gender = player:QueryCharacter("gender");
	local class = player:QueryCharacter("class");
	
	-- Set some information.
	player:SetSharedVar( "ks_Access", player:QueryCharacter("access") );
	player:SetSharedVar( "ks_Model", kuroScript.player.GetDefaultModel(player) );
	player:SetSharedVar( "ks_Name", player:QueryCharacter("name") );
	player:SetSharedVar( "ks_Skin", kuroScript.player.GetDefaultSkin(player) );
	player:SetSharedVar( "ks_Key", player:QueryCharacter("key") );
	
	-- Check if a statement is true.
	if ( kuroScript.class.stored[class] ) then
		player:SetSharedVar("ks_Class", kuroScript.class.stored[class].index);
	end;
	
	-- Check if a statement is true.
	if (gender == GENDER_MALE) then
		player:SetSharedVar("ks_Gender", 2);
	else
		player:SetSharedVar("ks_Gender", 1);
	end;
end;

-- A function to unescape a string from MySQL.
function kuroScript.player.Unescape(text)
	return string.Replace(string.Replace(string.Replace(text, "\\\\", "\\"), '\\"', '"'), "\\'", "'");
end;

-- A function to get the character's ammo as a string.
function kuroScript.player.GetCharacterAmmoString(player, character)
	local ammo = table.Copy(character._Ammo);
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs( kuroScript.player.GetAmmo(player) ) do
		if (v > 0) then ammo[k] = v; end;
	end;
	
	-- Return the encoded ammo.
	return Json.Encode(ammo);
end;

-- A function to get the character's data as a string.
function kuroScript.player.GetCharacterDataString(player, create, character)
	local data = character._Data;
	
	-- Check if a statement is true.
	if (!create) then
		data = table.Copy(data);
		
		-- Call a gamemode hook.
		hook.Call("PlayerSaveCharacterData", kuroScript.frame, player, data);
	end;
	
	-- Return the encoded data.
	return Json.Encode(data);
end;

-- A function to get the character's known names as a string.
function kuroScript.player.GetCharacterKnownNamesString(player, character)
	local knownNames = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(character._KnownNames) do
		if (v == KNOWN_SAVE) then
			knownNames[#knownNames + 1] = k;
		end;
	end;
	
	-- Return the encoded inventory.
	return Json.Encode(knownNames);
end;

-- A function to get the character's inventory as a string.
function kuroScript.player.GetCharacterInventoryString(player, character)
	local inventory = table.Copy(character._Inventory);
	local ragdollTable = player:GetRagdollTable();
	local fakeInventory = {};
	
	-- Check if a statement is true.
	if (ragdollTable and ragdollTable.weapons) then
		for k, v in pairs(ragdollTable.weapons) do
			if ( v[2] ) then
				local class = v[1].class;
				local uniqueID = v[1].uniqueID;
				local itemTable = kuroScript.item.GetWeapon(class, uniqueID);
				
				-- Check if a statement is true.
				if (itemTable) then
					if ( !kuroScript.player.GetSpawnWeapon(player, class) ) then
						if ( inventory[itemTable.uniqueID] ) then
							inventory[itemTable.uniqueID] = inventory[itemTable.uniqueID] + 1;
						else
							inventory[itemTable.uniqueID] = 1;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = kuroScript.item.GetWeapon(v);
		
		-- Check if a statement is true.
		if (itemTable) then
			if ( !kuroScript.player.GetSpawnWeapon(player, class) ) then
				if ( inventory[itemTable.uniqueID] ) then
					inventory[itemTable.uniqueID] = inventory[itemTable.uniqueID] + 1;
				else
					inventory[itemTable.uniqueID] = 1;
				end;
			end;
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("PlayerGetInventoryString", kuroScript.frame, player, character, fakeInventory);
	
	-- Loop for each value in a table.
	for k, v in pairs(fakeInventory) do
		local itemTable = kuroScript.item.Get(k);
		
		-- Check if a statement is true.
		if (itemTable) then
			local item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if ( !inventory[item] ) then
				inventory[item] = v;
			else
				inventory[item] = inventory[item] + v;
			end;
		end;
	end;
	
	-- Return the encoded inventory.
	return Json.Encode(inventory);
end;

-- A function to convert a character's known names string to a table.
function kuroScript.player.ConvertCharacterKnownNamesString(data)
	local success, value = pcall( Json.Decode, kuroScript.player.Unescape(data) );
	
	-- Check if a statement is true.
	if (success) then
		local knownNames = {};
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(value) do knownNames[v] = KNOWN_SAVE; end;
		
		-- Return the known names.
		return knownNames;
	else
		return {};
	end;
end;

-- A function to convert a character's data string to a table.
function kuroScript.player.ConvertCharacterDataString(data)
	local success, value = pcall( Json.Decode, kuroScript.player.Unescape(data) );
	
	-- Check if a statement is true.
	if (success) then
		return value;
	else
		return {};
	end;
end;

-- A function to load a player's data.
function kuroScript.player.LoadData(player, callback)
	local playersTable = kuroScript.config.Get("mysql_players_table"):Get();
	local game = GAME_FOLDER;
	
	-- Perform a threaded query.
	tmysql.query("SELECT * FROM "..playersTable.." WHERE _Game = \""..game.."\" AND _SteamID = \""..player:SteamID().."\"", function(result)
		if (ValidEntity(player) and !player._Data) then
			if (result and type(result) == "table" and #result > 0) then
				player._Data = kuroScript.player.ConvertDataString(player, result[1]._Data);
			else
				player._Data = {}; kuroScript.player.SaveData(player, true);
			end;
			
			-- Call a gamemode hook.
			hook.Call("PlayerRestoreData", kuroScript.frame, player, player._Data);
			
			-- Check if a statement is true.
			if ( callback and ValidEntity(player) ) then
				callback(player);
			end;
		end;
	end, 1);
	
	-- Set some information.
	timer.Simple(2, function()
		if (ValidEntity(player) and !player._Data) then
			kuroScript.player.LoadData(player, callback);
		end;
	end);
end;

-- A function to save a players's data.
function kuroScript.player.SaveData(player, create, delay, simple)
	if (create) then
		local query = kuroScript.player.GetDataCreateQuery(player);
		
		-- Check if a statement is true.
		if (delay) then
			timer.Simple(delay, function()
				tmysql.query(query);
			end);
		elseif (simple) then
			return query;
		else
			tmysql.query(query);
		end;
	else
		local query = kuroScript.player.GetDataUpdateQuery(player);
		
		-- Check if a statement is true.
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
function kuroScript.player.ConvertDataString(player, data)
	local success, value = pcall( Json.Decode, kuroScript.player.Unescape(data) );
	
	-- Check if a statement is true.
	if (success) then
		return value;
	else
		return {};
	end;
end;

-- A function to get the create query of a player's data.
function kuroScript.player.GetDataCreateQuery(player)
	local playersTable = kuroScript.config.Get("mysql_players_table"):Get();
	local steamName = tmysql.escape( player:SteamName() );
	local ipAddress = player:IPAddress();
	local steamID = player:SteamID();
	local game = GAME_FOLDER;
	
	-- Return the query.
	return "INSERT INTO "..playersTable.." (_Data, _Game, _SteamID, _IPAddress, _SteamName) VALUES (\"\", \""..game.."\", \""..steamID.."\", \""..ipAddress.."\", \""..steamName.."\")";
end;

-- A function to get the update query of player's data.
function kuroScript.player.GetDataUpdateQuery(player)
	local playersTable = kuroScript.config.Get("mysql_players_table"):Get();
	local steamName = tmysql.escape( player:SteamName() );
	local ipAddress = player:IPAddress();
	local steamID = player:SteamID();
	local data = table.Copy(player._Data);
	local game = GAME_FOLDER;
	
	-- Call a gamemode hook.
	hook.Call("PlayerSaveData", kuroScript.frame, player, data);
	
	-- Return the query.
	return "UPDATE "..playersTable.." SET _Data = \""..tmysql.escape( Json.Encode(data) ).."\", _SteamName = \""..steamName.."\", _IPAddress = \""..ipAddress.."\" WHERE _Game = \""..game.."\" AND _SteamID = \""..steamID.."\"";
end;

-- A function to get the create query of a character.
function kuroScript.player.GetCharacterCreateQuery(player, character)
	local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
	local values = "";
	local amount = 1;
	local keys = "";
	
	-- Check if a statement is true.
	if (!character) then
		character = player._Character;
	end;
	
	-- Set some information.
	local characterKeys = table.Count(character);
	
	-- Loop through each value in a table.
	for k, v in pairs(character) do
		if (characterKeys != amount) then
			keys = keys..k..", ";
		else
			keys = keys..k;
		end;
		
		-- Check if a statement is true.
		if (type(v) == "table") then
			if (k == "_Attributes") then
				v = Json.Encode(character._Attributes);
			elseif (k == "_KnownNames") then
				v = kuroScript.player.GetCharacterKnownNamesString(player, character);
			elseif (k == "_Inventory") then
				v = kuroScript.player.GetCharacterInventoryString(player, character);
			elseif (k == "_Ammo") then
				v = kuroScript.player.GetCharacterAmmoString(player, character);
			elseif (k == "_Data") then
				v = kuroScript.player.GetCharacterDataString(player, true, character);
			end;
		end;
		
		-- Set some information.
		local value = tmysql.escape( tostring(v) );
		
		-- Check if a statement is true.
		if (characterKeys != amount) then
			values = values.."\""..value.."\", ";
		else
			values = values.."\""..value.."\"";
		end;
		
		-- Set some information.
		amount = amount + 1;
	end;
	
	-- Return the query.
	return "INSERT INTO "..charactersTable.." ("..keys..") VALUES ("..values..")";
end;

-- A function to get the update query of a character.
function kuroScript.player.GetCharacterUpdateQuery(player, character)
	local charactersTable = kuroScript.config.Get("mysql_characters_table"):Get();
	local steamID = player:SteamID();
	local query = "";
	local game = GAME_FOLDER;
	
	-- Set some information.
	character = character or player._Character;
	
	-- Loop through each value in a table.
	for k, v in pairs(character) do
		if (k != "_Key") then
			if (type(v) == "table") then
				if (k == "_Attributes") then
					v = Json.Encode(character._Attributes);
				elseif (k == "_KnownNames") then
					v = kuroScript.player.GetCharacterKnownNamesString(player, character);
				elseif (k == "_Inventory") then
					v = kuroScript.player.GetCharacterInventoryString(player, character);
				elseif (k == "_Ammo") then
					v = kuroScript.player.GetCharacterAmmoString(player, character);
				elseif (k == "_Data") then
					v = kuroScript.player.GetCharacterDataString(player, nil, character);
				end;
			end;
			
			-- Set some information.
			local value = tmysql.escape( tostring(v) );
			
			-- Check to see if our query is valid.
			if (query == "") then
				query = "UPDATE "..charactersTable.." SET "..k.." = \""..value.."\"";
			else
				query = query..", "..k.." = \""..value.."\"";
			end;
		end;
	end;
	
	-- Return the query.
	return query.." WHERE _Game = \""..game.."\" AND _SteamID = \""..steamID.."\" AND _CharacterID = "..character._CharacterID;
end;

-- A function to save a player's character.
function kuroScript.player.SaveCharacter(player, create, character, callback)
	if (create) then
		local query = kuroScript.player.GetCharacterCreateQuery(player, character);
		
		-- Perform a threaded query.
		tmysql.query(query, function(result, status, lastID)
			if ( callback and tonumber(lastID) ) then
				callback( tonumber(lastID) );
			end;
		end, 2);
	elseif ( player:HasInitialized() ) then
		local characterQuery = kuroScript.player.GetCharacterUpdateQuery(player, character);
		local dataQuery = kuroScript.player.SaveData(player, nil, nil, true);
		
		-- Perform some threaded queries.
		tmysql.query(characterQuery);
		tmysql.query(dataQuery);
	end;
end;

-- A function to get the class of a player's active weapon.
function kuroScript.player.GetWeaponClass(player, safe)
	if ( ValidEntity( player:GetActiveWeapon() ) ) then
		return player:GetActiveWeapon():GetClass();
	else
		return safe;
	end;
end;

-- A function to call a player's think hook.
function kuroScript.player.CallThinkHook(player, setSharedVars, infoTable, curTime)
	infoTable.inventoryWeight = kuroScript.config.Get("default_inv_weight"):Get();
	infoTable.crouchedSpeed = player._CrouchedSpeed;
	infoTable.jumpPower = player._JumpPower;
	infoTable.walkSpeed = player._WalkSpeed;
	infoTable.runSpeed = player._RunSpeed;
	infoTable.running = player:IsRunning();
	infoTable.jogging = player:IsJogging();
	infoTable.wages = kuroScript.vocation.Query(player:Team(), "wages", 0);
	
	-- Check if a statement is true.
	if ( !player:IsJogging(true) ) then
		infoTable.jogging = nil;
		
		-- Set some information.
		player:SetSharedVar("ks_Jogging", false);
	end;
	
	-- Check if a statement is true.
	if (setSharedVars) then
		hook.Call("PlayerSetSharedVars", kuroScript.frame, player, curTime);
	end;
	
	-- Call a gamemode hook.
	hook.Call("PlayerThink", kuroScript.frame, player, curTime, infoTable);
end;

-- A function to preserve a player's ammo.
function kuroScript.player.PreserveAmmo(player, checkEmpty)
	local weapon = player:GetActiveWeapon();
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( player:GetWeapons() ) do
		local itemTable = kuroScript.item.GetWeapon(v);
		
		-- Check if a statement is true.
		if (itemTable) then
			kuroScript.player.SavePrimaryAmmo(player, v);
			kuroScript.player.SaveSecondaryAmmo(player, v);
			
			-- Check if a statement is true.
			if (checkEmpty) then
				kuroScript.player.CheckWeaponEmpty(player, v, itemTable);
			end;
		end;
	end;
end;

-- A function to get a player's wages.
function kuroScript.player.GetWages(player)
	return player:GetSharedVar("ks_Wages");
end;