--[[
Name: "cl_player.lua".
Product: "nexus".
--]]

nexus.player = {};
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

-- A function to get whether the local player's data has streamed.
function nexus.player.HasDataStreamed()
	return NEXUS.DataHasStreamed;
end;

-- A function to get whether a player can hear another player.
function nexus.player.CanHearPlayer(player, target, allowance)
	if ( nexus.config.Get("messages_must_see_player"):Get() ) then
		return nexus.player.CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;

-- A function to register a player's shared variable.
function nexus.player.RegisterSharedVar(name, class, playerOnly)
	nexus.player.sharedVars[name] = {
		playerOnly = playerOnly,
		class = class,
		name = name
	};
end;
	
-- A function to get whether the target recognises the local player.
function nexus.player.DoesTargetRecognise()
	if ( nexus.config.Get("recognise_system"):Get() ) then
		return g_LocalPlayer:GetSharedVar("sh_TargetRecognises");
	else
		return true;
	end;
end;

-- A function to get a player's real trace.
function nexus.player.GetRealTrace(player, useFilterTrace)
	local angles = player:GetAimVector() * 4096;
	local eyePos = EyePos();
	
	if (player != g_LocalPlayer) then
		eyePos = player:EyePos();
	end;
	
	local trace = util.TraceLine( {
		endpos = eyePos + angles,
		start = eyePos,
		filter = player
	} );
	
	player:GetEyeTraceNoCursor();
	
	local newTrace = util.TraceLine( {
		endpos = eyePos + angles,
		filter = player,
		start = eyePos,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	} );
	
	if ( ( IsValid(newTrace.Entity) and !newTrace.HitWorld and ( !IsValid(trace.Entity)
	or string.find(trace.Entity:GetClass(), "vehicle") ) ) or useFilterTrace ) then
		trace = newTrace;
	end;
	
	return trace;
end;

-- A function to get whether the local player can give to storage.
function nexus.player.CanGiveToStorage(item)
	local itemTable = nexus.item.Get(item);
	local entity = nexus.storage.GetEntity();
	
	if ( itemTable and IsValid(entity) ) then
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

-- A function to get whether the local player can take from storage.
function nexus.player.CanTakeFromStorage(item)
	local itemTable = nexus.item.Get(item);
	local entity = nexus.storage.GetEntity();
	
	if ( itemTable and IsValid(entity) ) then
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

-- A function to get the local player's action.
function nexus.player.GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("sh_StartActionTime");
	local actionDuration = player:GetSharedVar("sh_ActionDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("sh_Action");
	
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
function nexus.player.GetMaximumCharacters()
	local whitelisted = nexus.character.GetWhitelisted();
	local maximum = nexus.config.Get("additional_characters"):Get(2);
	
	for k, v in pairs(nexus.faction.stored) do
		if ( !v.whitelist or table.HasValue(whitelisted, v.name) ) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

-- A function to get whether a player's weapon is raised.
function nexus.player.GetWeaponRaised(player)
	return player:GetSharedVar("sh_WeaponRaised");
end;

-- A function to get a player's unrecognised name.
function nexus.player.GetUnrecognisedName(player)
	local unrecognisedPhysDesc = nexus.player.GetPhysDesc(player);
	local unrecognisedName = nexus.config.Get("unrecognised_name"):Get();
	local usedPhysDesc;
	
	if (unrecognisedPhysDesc) then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

-- A function to get whether a player can see an NPC.
function nexus.player.CanSeeNPC(player, target, allowance)
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
function nexus.player.CanSeePlayer(player, target, allowance)
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
	trace.filter = player;
	
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

-- A function to get a player's wages name.
function nexus.player.GetWagesName(player)
	return nexus.class.Query( player:Team(), "wagesName", nexus.config.Get("wages_name"):Get() );
end;

-- A function to check whether a player is ragdolled
function nexus.player.IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		if (player:GetSharedVar("sh_Ragdolled") == 0) then
			return false;
		elseif (player:GetSharedVar("sh_Ragdolled") == exception) then
			return false;
		else
			return (player:GetSharedVar("sh_Ragdolled") != RAGDOLL_NONE);
		end;
	end;
end;

-- A function to get whether the local player recognises another player.
function nexus.player.DoesRecognise(player, status, simple)
	if (!status) then
		return nexus.player.DoesRecognise(player, RECOGNISE_PARTIAL);
	elseif ( nexus.config.Get("recognise_system"):Get() ) then
		local key = nexus.player.GetCharacterKey(player);
		local default = false;
		
		if (nexus.player.GetCharacterKey(g_LocalPlayer) == key) then
			return true;
		elseif ( NEXUS.RecognisedNames[key] ) then
			if (simple) then
				default = (NEXUS.RecognisedNames[key] == status);
			else
				default = (NEXUS.RecognisedNames[key] >= status);
			end;
		end;
		
		return nexus.mount.Call("PlayerDoesRecognisePlayer", player, status, simple, default);
	else
		return true;
	end;
end;

-- A function to get a player's character key.
function nexus.player.GetCharacterKey(player)
	return player:GetSharedVar("sh_Key");
end;

-- A function to get a player's ragdoll state.
function nexus.player.GetRagdollState(player)
	if (player:GetSharedVar("sh_Ragdolled") == 0) then
		return false;
	else
		return player:GetSharedVar("sh_Ragdolled");
	end;
end;

-- A function to get a player's physical description.
function nexus.player.GetPhysDesc(player)
	if (!player) then
		player = g_LocalPlayer;
	end;
	
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

-- A function to get the local player's wages.
function nexus.player.GetWages()
	return g_LocalPlayer:GetSharedVar("sh_Wages");
end;

-- A function to get the local player's cash.
function nexus.player.GetCash()
	return g_LocalPlayer:GetSharedVar("sh_Cash");
end;

-- A function to get a player's ragdoll entity.
function nexus.player.GetRagdollEntity(player)
	local ragdollEntity = player:GetSharedVar("sh_Ragdoll");
	
	if ( IsValid(ragdollEntity) ) then
		return ragdollEntity;
	end;
end;

-- A function to get a player's gender.
function nexus.player.GetGender(player)
	if (player:GetSharedVar("sh_Gender") == 1) then
		return GENDER_FEMALE;
	else
		return GENDER_MALE;
	end;
end;

-- A function to get a player's default skin.
function nexus.player.GetDefaultSkin(player)
	local model, skin = nexus.class.GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

-- A function to get a player's default model.
function nexus.player.GetDefaultModel(player)
	local model, skin = nexus.class.GetAppropriateModel(player:Team(), player);
	
	return model;
end;
	
-- A function to get a player's class.
function nexus.player.GetFaction(player)
	local index = player:GetSharedVar("sh_Faction");
	
	if ( nexus.faction.Get(index) ) then
		return nexus.faction.Get(index).name;
	else
		return "Unknown";
	end;
end;

-- A function to check if a player has any flags.
function nexus.player.HasAnyFlags(player, flags, default)
	local playerFlags = player:GetSharedVar("sh_Flags")
	
	if (playerFlags != "") then
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

-- A function to check if a player has access.
function nexus.player.HasFlags(player, flags, default)
	local playerFlags = player:GetSharedVar("sh_Flags")
	
	if (playerFlags != "") then
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
						return false;
					end;
				end;
			end;
		end;
		
		return true;
	end;
end;

-- A function to set a shared variable for a player.
function nexus.player.SetSharedVar(player, key, value)
	if ( IsValid(player) ) then
		local sharedVarData = nexus.player.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (value == nil) then
					sharedVarData.value = NEXUS:GetDefaultNetworkedValue(sharedVarData.class);
				else
					sharedVarData.value = value;
				end;
			else
				local class = NEXUS:ConvertNetworkedClass(sharedVarData.class);
				
				if (class) then
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
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (!sharedVarData.value) then
					return NEXUS:GetDefaultNetworkedValue(sharedVarData.class);
				else
					return sharedVarData.value;
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

-- A function to get whether the local player is drunk.
function nexus.player.GetDrunk()
	local drunk = g_LocalPlayer:GetSharedVar("sh_Drunk");
	
	if (drunk and drunk > 0) then
		return drunk;
	end;
end;