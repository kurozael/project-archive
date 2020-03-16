--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.player = {};
CloudScript.player.sharedVars = {};

-- A function to get whether a player is noclipping.
function CloudScript.player:IsNoClipping(player)
	if ( player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle() ) then
		return true;
	end;
end;

-- A function to get whether a player is an admin.
function CloudScript.player:IsAdmin(player)
	if ( self:HasFlags(player, "o") ) then
		return true;
	end;
end;

-- A function to get whether the local player's data has streamed.
function CloudScript.player:HasDataStreamed()
	return CloudScript.DataHasStreamed;
end;

-- A function to get whether a player can hear another player.
function CloudScript.player:CanHearPlayer(player, target, allowance)
	if ( CloudScript.config:Get("messages_must_see_player"):Get() ) then
		return self:CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;

-- A function to register a player's shared variable.
function CloudScript.player:AddSharedVar(name, class, playerOnly)
	self.sharedVars[name] = {
		playerOnly = playerOnly,
		class = class,
		name = name
	};
end;
	
-- A function to get whether the target recognises the local player.
function CloudScript.player:DoesTargetRecognise()
	if ( CloudScript.config:Get("recognise_system"):Get() ) then
		return CloudScript.Client:GetSharedVar("targetRecognises");
	else
		return true;
	end;
end;

-- A function to get a player's real trace.
function CloudScript.player:GetRealTrace(player, useFilterTrace)
	local angles = player:GetAimVector() * 4096;
	local eyePos = EyePos();
	
	if (player != CloudScript.Client) then
		eyePos = player:EyePos();
	end;
	
	local trace = util.TraceLine( {
		endpos = eyePos + angles,
		start = eyePos,
		filter = player
	} );
	
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
function CloudScript.player:CanGiveToStorage(item)
	local itemTable = CloudScript.item:Get(item);
	local entity = CloudScript.storage:GetEntity();
	
	if ( itemTable and IsValid(entity) ) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerGive = (!entity:IsPlayer() or itemTable.allowPlayerGive != false);
		local allowEntityGive = (entity:IsPlayer() or itemTable.allowEntityGive != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowGive = (itemTable.allowGive != false);
		local shipment = (entity and entity:GetClass() == "cloud_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerGive and allowStorage and allowGive) ) then
			return true;
		end;
	end;
end;

-- A function to get whether the local player can take from storage.
function CloudScript.player:CanTakeFromStorage(item)
	local itemTable = CloudScript.item:Get(item);
	local entity = CloudScript.storage:GetEntity();
	
	if ( itemTable and IsValid(entity) ) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerTake = (!entity:IsPlayer() or itemTable.allowPlayerTake != false);
		local allowEntityTake = (entity:IsPlayer() or itemTable.allowEntityTake != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowTake = (itemTable.allowTake != false);
		local shipment = (entity and entity:GetClass() == "cloud_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerTake and allowStorage and allowTake) ) then
			return true;
		end;
	end;
end;

-- A function to get the local player's action.
function CloudScript.player:GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("startActionTime");
	local actionDuration = player:GetSharedVar("actionDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("action");
	
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
function CloudScript.player:GetMaximumCharacters()
	local whitelisted = CloudScript.character:GetWhitelisted();
	local maximum = CloudScript.config:Get("additional_characters"):Get(2);
	
	for k, v in pairs(CloudScript.faction.stored) do
		if ( !v.whitelist or table.HasValue(whitelisted, v.name) ) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

-- A function to get whether a player's weapon is raised.
function CloudScript.player:GetWeaponRaised(player)
	return player:GetSharedVar("weaponRaised");
end;

-- A function to get a player's unrecognised name.
function CloudScript.player:GetUnrecognisedName(player)
	local unrecognisedPhysDesc = self:GetPhysDesc(player);
	local unrecognisedName = CloudScript.config:Get("unrecognised_name"):Get();
	local usedPhysDesc;
	
	if (unrecognisedPhysDesc) then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

-- A function to get whether a player can see an NPC.
function CloudScript.player:CanSeeNPC(player, target, allowance, ignoreEnts)
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
function CloudScript.player:CanSeePlayer(player, target, allowance, ignoreEnts)
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
function CloudScript.player:CanSeeEntity(player, target, allowance, ignoreEnts)
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
function CloudScript.player:CanSeePosition(player, position, allowance, ignoreEnts)
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
function CloudScript.player:GetWagesName(player)
	return CloudScript.class:Query( player:Team(), "wagesName", CloudScript.config:Get("wages_name"):Get() );
end;

-- A function to check whether a player is ragdolled
function CloudScript.player:IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		if (player:GetSharedVar("ragdolled") == 0) then
			return false;
		elseif (player:GetSharedVar("ragdolled") == exception) then
			return false;
		else
			return (player:GetSharedVar("ragdolled") != RAGDOLL_NONE);
		end;
	end;
end;

-- A function to get whether the local player recognises another player.
function CloudScript.player:DoesRecognise(player, status, isAccurate)
	if (!status) then
		return self:DoesRecognise(player, RECOGNISE_PARTIAL);
	elseif ( CloudScript.config:Get("recognise_system"):Get() ) then
		local key = self:GetCharacterKey(player);
		local realValue = false;
		
		if (self:GetCharacterKey(CloudScript.Client) == key) then
			return true;
		elseif ( CloudScript.RecognisedNames[key] ) then
			if (isAccurate) then
				realValue = (CloudScript.RecognisedNames[key] == status);
			else
				realValue = (CloudScript.RecognisedNames[key] >= status);
			end;
		end;
		
		return CloudScript.plugin:Call("PlayerDoesRecognisePlayer", player, status, isAccurate, realValue);
	else
		return true;
	end;
end;

-- A function to get a player's character key.
function CloudScript.player:GetCharacterKey(player)
	return player:GetSharedVar("key");
end;

-- A function to get a player's ragdoll state.
function CloudScript.player:GetRagdollState(player)
	if (player:GetSharedVar("ragdolled") == 0) then
		return false;
	else
		return player:GetSharedVar("ragdolled");
	end;
end;

-- A function to get a player's physical description.
function CloudScript.player:GetPhysDesc(player)
	if (!player) then
		player = CloudScript.Client;
	end;
	
	local physDesc = player:GetSharedVar("physDesc");
	local team = player:Team();
	
	if (physDesc == "") then
		physDesc = CloudScript.class:Query(team, "defaultPhysDesc", "");
	end;
	
	if (physDesc == "") then
		physDesc = CloudScript.config:Get("default_physdesc"):Get();
	end;
	
	if (!physDesc or physDesc == "") then
		physDesc = "This character has no physical description set.";
	else
		physDesc = CloudScript:ModifyPhysDesc(physDesc);
	end;
	
	local override = CloudScript.plugin:Call("GetPlayerPhysDescOverride", player, physDesc);
	
	if (override) then
		physDesc = override;
	end;
	
	return physDesc;
end;

-- A function to get the local player's wages.
function CloudScript.player:GetWages()
	return CloudScript.Client:GetSharedVar("wages");
end;

-- A function to get the local player's cash.
function CloudScript.player:GetCash()
	return CloudScript.Client:GetSharedVar("cash");
end;

-- A function to get a player's ragdoll entity.
function CloudScript.player:GetRagdollEntity(player)
	local ragdollEntity = player:GetSharedVar("ragdoll");
	
	if ( IsValid(ragdollEntity) ) then
		return ragdollEntity;
	end;
end;

-- A function to get a player's gender.
function CloudScript.player:GetGender(player)
	if (player:GetSharedVar("gender") == 1) then
		return GENDER_FEMALE;
	else
		return GENDER_MALE;
	end;
end;

-- A function to get a player's default skin.
function CloudScript.player:GetDefaultSkin(player)
	local model, skin = CloudScript.class:GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

-- A function to get a player's default model.
function CloudScript.player:GetDefaultModel(player)
	local model, skin = CloudScript.class:GetAppropriateModel(player:Team(), player);
	
	return model;
end;
	
-- A function to get a player's class.
function CloudScript.player:GetFaction(player)
	local index = player:GetSharedVar("faction");
	
	if ( CloudScript.faction:Get(index) ) then
		return CloudScript.faction:Get(index).name;
	else
		return "Unknown";
	end;
end;

-- A function to check if a player has any flags.
function CloudScript.player:HasAnyFlags(player, flags, default)
	local playerFlags = player:GetSharedVar("flags")
	
	if (playerFlags != "") then
		if ( CloudScript.class:HasAnyFlags(player:Team(), flags) and !default ) then
			return true;
		else
			-- local i;
			
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success = true;
				
				if (!default) then
					local hasFlag = CloudScript.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
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
function CloudScript.player:HasFlags(player, flags, default)
	local playerFlags = player:GetSharedVar("flags")
	
	if (playerFlags != "") then
		if ( CloudScript.class:HasFlags(player:Team(), flags) and !default ) then
			return true;
		else
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success;
				
				if (!default) then
					local hasFlag = CloudScript.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
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
function CloudScript.player:SetSharedVar(player, key, value)
	if ( IsValid(player) ) then
		local sharedVarData = self.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (value == nil) then
					sharedVarData.value = CloudScript:GetDefaultNetworkedValue(sharedVarData.class);
				else
					sharedVarData.value = value;
				end;
			else
				local class = CloudScript:ConvertNetworkedClass(sharedVarData.class);
				
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
function CloudScript.player:GetSharedVar(player, key)
	if ( IsValid(player) ) then
		local sharedVarData = self.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (!sharedVarData.value) then
					return CloudScript:GetDefaultNetworkedValue(sharedVarData.class);
				else
					return sharedVarData.value;
				end;
			else
				local class = CloudScript:ConvertNetworkedClass(sharedVarData.class);
				
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
function CloudScript.player:GetDrunk()
	local drunk = CloudScript.Client:GetSharedVar("drunk");
	
	if (drunk and drunk > 0) then
		return drunk;
	end;
end;