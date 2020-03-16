--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.player = {};
openAura.player.sharedVars = {};

-- A function to get whether a player is noclipping.
function openAura.player:IsNoClipping(player)
	if ( player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle() ) then
		return true;
	end;
end;

-- A function to get whether a player is an admin.
function openAura.player:IsAdmin(player)
	if ( self:HasFlags(player, "o") ) then
		return true;
	end;
end;

-- A function to get whether the local player's data has streamed.
function openAura.player:HasDataStreamed()
	return openAura.DataHasStreamed;
end;

-- A function to get whether a player can hear another player.
function openAura.player:CanHearPlayer(player, target, allowance)
	if ( openAura.config:Get("messages_must_see_player"):Get() ) then
		return self:CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;

-- A function to register a player's shared variable.
function openAura.player:RegisterSharedVar(name, class, playerOnly)
	self.sharedVars[name] = {
		playerOnly = playerOnly,
		class = class,
		name = name
	};
end;
	
-- A function to get whether the target recognises the local player.
function openAura.player:DoesTargetRecognise()
	if ( openAura.config:Get("recognise_system"):Get() ) then
		return openAura.Client:GetSharedVar("targetRecognises");
	else
		return true;
	end;
end;

-- A function to get a player's real trace.
function openAura.player:GetRealTrace(player, useFilterTrace)
	local angles = player:GetAimVector() * 4096;
	local eyePos = EyePos();
	
	if (player != openAura.Client) then
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
function openAura.player:CanGiveToStorage(item)
	local itemTable = openAura.item:Get(item);
	local entity = openAura.storage:GetEntity();
	
	if ( itemTable and IsValid(entity) ) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerGive = (!entity:IsPlayer() or itemTable.allowPlayerGive != false);
		local allowEntityGive = (entity:IsPlayer() or itemTable.allowEntityGive != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowGive = (itemTable.allowGive != false);
		local shipment = (entity and entity:GetClass() == "aura_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerGive and allowStorage and allowGive) ) then
			return true;
		end;
	end;
end;

-- A function to get whether the local player can take from storage.
function openAura.player:CanTakeFromStorage(item)
	local itemTable = openAura.item:Get(item);
	local entity = openAura.storage:GetEntity();
	
	if ( itemTable and IsValid(entity) ) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerTake = (!entity:IsPlayer() or itemTable.allowPlayerTake != false);
		local allowEntityTake = (entity:IsPlayer() or itemTable.allowEntityTake != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowTake = (itemTable.allowTake != false);
		local shipment = (entity and entity:GetClass() == "aura_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerTake and allowStorage and allowTake) ) then
			return true;
		end;
	end;
end;

-- A function to get the local player's action.
function openAura.player:GetAction(player, percentage)
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
function openAura.player:GetMaximumCharacters()
	local whitelisted = openAura.character:GetWhitelisted();
	local maximum = openAura.config:Get("additional_characters"):Get(2);
	
	for k, v in pairs(openAura.faction.stored) do
		if ( !v.whitelist or table.HasValue(whitelisted, v.name) ) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

-- A function to get whether a player's weapon is raised.
function openAura.player:GetWeaponRaised(player)
	return player:GetSharedVar("weaponRaised");
end;

-- A function to get a player's unrecognised name.
function openAura.player:GetUnrecognisedName(player)
	local unrecognisedPhysDesc = self:GetPhysDesc(player);
	local unrecognisedName = openAura.config:Get("unrecognised_name"):Get();
	local usedPhysDesc;
	
	if (unrecognisedPhysDesc) then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

-- A function to get whether a player can see an NPC.
function openAura.player:CanSeeNPC(player, target, allowance, ignoreEnts)
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
function openAura.player:CanSeePlayer(player, target, allowance, ignoreEnts)
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
function openAura.player:CanSeeEntity(player, target, allowance, ignoreEnts)
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
function openAura.player:CanSeePosition(player, position, allowance, ignoreEnts)
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
function openAura.player:GetWagesName(player)
	return openAura.class:Query( player:Team(), "wagesName", openAura.config:Get("wages_name"):Get() );
end;

-- A function to check whether a player is ragdolled
function openAura.player:IsRagdolled(player, exception, entityless)
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
function openAura.player:DoesRecognise(player, status, isAccurate)
	if (!status) then
		return self:DoesRecognise(player, RECOGNISE_PARTIAL);
	elseif ( openAura.config:Get("recognise_system"):Get() ) then
		local key = self:GetCharacterKey(player);
		local realValue = false;
		
		if (self:GetCharacterKey(openAura.Client) == key) then
			return true;
		elseif ( openAura.RecognisedNames[key] ) then
			if (isAccurate) then
				realValue = (openAura.RecognisedNames[key] == status);
			else
				realValue = (openAura.RecognisedNames[key] >= status);
			end;
		end;
		
		return openAura.plugin:Call("PlayerDoesRecognisePlayer", player, status, isAccurate, realValue);
	else
		return true;
	end;
end;

-- A function to get a player's character key.
function openAura.player:GetCharacterKey(player)
	return player:GetSharedVar("key");
end;

-- A function to get a player's ragdoll state.
function openAura.player:GetRagdollState(player)
	if (player:GetSharedVar("ragdolled") == 0) then
		return false;
	else
		return player:GetSharedVar("ragdolled");
	end;
end;

-- A function to get a player's physical description.
function openAura.player:GetPhysDesc(player)
	if (!player) then
		player = openAura.Client;
	end;
	
	local physDesc = player:GetSharedVar("physDesc");
	local team = player:Team();
	
	if (physDesc == "") then
		physDesc = openAura.class:Query(team, "defaultPhysDesc", "");
	end;
	
	if (physDesc == "") then
		physDesc = openAura.config:Get("default_physdesc"):Get();
	end;
	
	if (!physDesc or physDesc == "") then
		physDesc = "This character has no physical description set.";
	else
		physDesc = openAura:ModifyPhysDesc(physDesc);
	end;
	
	local override = openAura.plugin:Call("GetPlayerPhysDescOverride", player, physDesc);
	
	if (override) then
		physDesc = override;
	end;
	
	return physDesc;
end;

-- A function to get the local player's wages.
function openAura.player:GetWages()
	return openAura.Client:GetSharedVar("wages");
end;

-- A function to get the local player's cash.
function openAura.player:GetCash()
	return openAura.Client:GetSharedVar("cash");
end;

-- A function to get a player's ragdoll entity.
function openAura.player:GetRagdollEntity(player)
	local ragdollEntity = player:GetSharedVar("ragdoll");
	
	if ( IsValid(ragdollEntity) ) then
		return ragdollEntity;
	end;
end;

-- A function to get a player's gender.
function openAura.player:GetGender(player)
	if (player:GetSharedVar("gender") == 1) then
		return GENDER_FEMALE;
	else
		return GENDER_MALE;
	end;
end;

-- A function to get a player's default skin.
function openAura.player:GetDefaultSkin(player)
	local model, skin = openAura.class:GetAppropriateModel(player:Team(), player);
	
	return skin;
end;

-- A function to get a player's default model.
function openAura.player:GetDefaultModel(player)
	local model, skin = openAura.class:GetAppropriateModel(player:Team(), player);
	
	return model;
end;
	
-- A function to get a player's class.
function openAura.player:GetFaction(player)
	local index = player:GetSharedVar("faction");
	
	if ( openAura.faction:Get(index) ) then
		return openAura.faction:Get(index).name;
	else
		return "Unknown";
	end;
end;

-- A function to check if a player has any flags.
function openAura.player:HasAnyFlags(player, flags, default)
	local playerFlags = player:GetSharedVar("flags")
	
	if (playerFlags != "") then
		if ( openAura.class:HasAnyFlags(player:Team(), flags) and !default ) then
			return true;
		else
			-- local i;
			
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success = true;
				
				if (!default) then
					local hasFlag = openAura.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
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
function openAura.player:HasFlags(player, flags, default)
	local playerFlags = player:GetSharedVar("flags")
	
	if (playerFlags != "") then
		if ( openAura.class:HasFlags(player:Team(), flags) and !default ) then
			return true;
		else
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success;
				
				if (!default) then
					local hasFlag = openAura.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
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
function openAura.player:SetSharedVar(player, key, value)
	if ( IsValid(player) ) then
		local sharedVarData = self.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (value == nil) then
					sharedVarData.value = openAura:GetDefaultNetworkedValue(sharedVarData.class);
				else
					sharedVarData.value = value;
				end;
			else
				local class = openAura:ConvertNetworkedClass(sharedVarData.class);
				
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
function openAura.player:GetSharedVar(player, key)
	if ( IsValid(player) ) then
		local sharedVarData = self.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (!sharedVarData.value) then
					return openAura:GetDefaultNetworkedValue(sharedVarData.class);
				else
					return sharedVarData.value;
				end;
			else
				local class = openAura:ConvertNetworkedClass(sharedVarData.class);
				
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
function openAura.player:GetDrunk()
	local drunk = openAura.Client:GetSharedVar("drunk");
	
	if (drunk and drunk > 0) then
		return drunk;
	end;
end;