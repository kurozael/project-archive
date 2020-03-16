--[[
Name: "cl_player.lua".
Product: "kuroScript".
--]]

kuroScript.player = {};
	
-- A function to get the local player's action.
function kuroScript.player.GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("ks_StartActionTime");
	local actionDuration = player:GetSharedVar("ks_ActionDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("ks_Action");
	
	-- Check if a statement is true.
	if (curTime < startActionTime + actionDuration) then
		if (percentage) then
			return action, (100 / actionDuration) * (actionDuration - ( (startActionTime + actionDuration) - curTime) );
		else
			return action, actionDuration, startActionTime;
		end;
	else
		return "", 0, 0;
	end;
end;

-- A function to get the local player's maximum characters.
function kuroScript.player.GetMaximumCharacters()
	local maximum = kuroScript.config.Get("additional_characters"):Get(0);
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.class.stored) do
		if ( !v.whitelist or table.HasValue(kuroScript.character.whitelisted, v.name) ) then
			maximum = maximum + 1;
		end;
	end;
	
	-- Return the maximum characters.
	return maximum;
end;

-- A function to get whether a player's weapon is raised.
function kuroScript.player.GetWeaponRaised(player)
	return player:GetSharedVar("ks_WeaponRaised");
end;

-- A function to get whether a player can see an NPC.
function kuroScript.player.CanSeeNPC(player, target, allowance)
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
function kuroScript.player.CanSeePlayer(player, target, allowance)
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
	trace.filter = player;
	
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

-- A function to get a player's wages name.
function kuroScript.player.GetWagesName(player)
	return kuroScript.vocation.Query( player:Team(), "wagesName", kuroScript.config.Get("wages_name"):Get() );
end;

-- A function to check whether a player is ragdolled
function kuroScript.player.IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		if (player:GetSharedVar("ks_Ragdolled") == 0) then
			return false;
		elseif (player:GetSharedVar("ks_Ragdolled") == exception) then
			return false;
		else
			return (player:GetSharedVar("ks_Ragdolled") != RAGDOLL_NONE);
		end;
	end;
end;

-- A function to get whether the local player knows another player.
function kuroScript.player.KnowsPlayer(player, status, simple)
	if (!status) then
		return kuroScript.player.KnowsPlayer(player, KNOWN_PARTIAL);
	elseif ( kuroScript.config.Get("anonymous_system"):Get() ) then
		local key = kuroScript.player.GetCharacterKey(player);
		local default = false;
		
		-- Check if a statement is true.
		if (kuroScript.player.GetCharacterKey(g_LocalPlayer) == key) then
			return true;
		elseif ( self.KnownNames[key] ) then
			if (simple) then
				default = (self.KnownNames[key] == status);
			else
				default = (self.KnownNames[key] >= status);
			end;
		end;
		
		-- Return whether the player knows them.
		return hook.Call("PlayerDoesKnowPlayer", kuroScript.frame, player, status, simple, default);
	else
		return true;
	end;
end;

-- A function to get a player's character key.
function kuroScript.player.GetCharacterKey(player)
	return player:GetSharedVar("ks_Key");
end;

-- A function to get a player's ragdoll state.
function kuroScript.player.GetRagdollState(player)
	if (player:GetSharedVar("ks_Ragdolled") == 0) then
		return false;
	else
		return player:GetSharedVar("ks_Ragdolled");
	end;
end;

-- A function to get a player's details.
function kuroScript.player.GetDetails(player)
	if (!player) then
		player = g_LocalPlayer;
	end;
	
	-- Set some information.
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

-- A function to get the local player's wages.
function kuroScript.player.GetWages()
	return g_LocalPlayer:GetSharedVar("ks_Wages");
end;

-- A function to get the local player's currency.
function kuroScript.player.GetCurrency()
	return g_LocalPlayer:GetSharedVar("ks_Currency");
end;

-- A function to get a player's ragdoll entity.
function kuroScript.player.GetRagdollEntity(player)
	local ragdollEntity = player:GetSharedVar("ks_Ragdoll");
	
	-- Check if a statement is true.
	if ( ValidEntity(ragdollEntity) ) then
		return ragdollEntity;
	end;
end;

-- A function to get a player's gender.
function kuroScript.player.GetGender(player)
	if (player:GetSharedVar("ks_Gender") == 1) then
		return GENDER_FEMALE;
	else
		return GENDER_MALE;
	end;
end;

-- A function to get a player's default skin.
function kuroScript.player.GetDefaultSkin(player)
	return player:GetSharedVar("ks_Skin");
end;

-- A function to get a player's default model.
function kuroScript.player.GetDefaultModel(player)
	local model = player:GetSharedVar("ks_Model");
	
	-- Check if a statement is true.
	if (model == "") then
		return "models/error.mdl";
	else
		return model;
	end;
end;
	
-- A function to get a player's class.
function kuroScript.player.GetClass(player)
	local index = player:GetSharedVar("ks_Class");
	
	-- Check if a statement is true.
	if ( kuroScript.class.Get(index) ) then
		return kuroScript.class.Get(index).name;
	else
		return "Unknown";
	end;
end;

-- A function to check if a player has any access.
function kuroScript.player.HasAnyAccess(player, access, default)
	local playerAccess = player:GetSharedVar("ks_Access")
	
	-- Check if a statement is true.
	if (playerAccess != "") then
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
	local playerAccess = player:GetSharedVar("ks_Access")
	
	-- Check if a statement is true.
	if (playerAccess != "") then
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
						return false;
					end;
				end;
			end;
		end;
		
		-- Return true to break the function.
		return true;
	end;
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

-- A function to get whether the local player is drunk.
function kuroScript.player.GetDrunk()
	local drunk = g_LocalPlayer:GetSharedVar("ks_Drunk");
	
	-- Check if a statement is true.
	if (drunk and drunk > 0) then
		return drunk;
	end;
end;