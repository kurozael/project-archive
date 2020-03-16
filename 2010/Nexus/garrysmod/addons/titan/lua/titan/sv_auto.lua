--[[
Name: "sv_auto.lua".
Product: "titan".
--]]

local oldEntity = Entity;

-- A function to get an entity by its index.
function Entity(entIndex)
	if (entIndex == 0) then
		return GetWorldEntity();
	end;
	
	return oldEntity(entIndex);
end;

-- A function to clear a player's timers.
function titan:ClearPlayerTimers(player)
	self.quickTimers[player] = nil;
	self.slowTimers[player] = nil;
	self.longTimers[player] = nil;
end;

-- A function to register a player timer.
function titan:RegisterPlayerTimer(player, entity, key)
	local worldEntity = GetWorldEntity();
	local entryTable = self.slowTimers;
	local position = entity:GetPos();
	
	if (entity == worldEntity or entity:IsPlayer() or player:GetPos():Distance(position) < 512) then
		entryTable = self.quickTimers;
	else
		local canSend = self:CanVariableBeSent(player, entity);
		
		if (canSend != SEND_TRUE) then
			entryTable = self.longTimers;
		end;
	end;
	
	if ( !entryTable[player] ) then
		entryTable[player] = {};
	end;
	
	if ( !entryTable[player][entity] ) then
		entryTable[player][entity] = {};
	end;
	
	table.insert(entryTable[player][entity], key);
end;

-- A function to send a full player update.
function titan:SendFullPlayerUpdate(player)
	if (player.fn_Vars) then
		player.fn_Vars = {};
	end;
	
	self:ClearPlayerTimers(player);
	
	for k, v in pairs(self.netVars) do
		local entity = Entity(k);
		
		if ( self:IsValidEntity(entity) ) then
			for k2, v2 in pairs(v) do
				self:RegisterPlayerTimer(player, entity, k2);
			end;
		end;
	end;
end;

-- A function to update an entity's variable.
function titan:UpdateVar(entity, key, value)
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v.fn_Initialized and !self:DoesPlayerHaveVar(v, entity, key, value) ) then
			self:RegisterPlayerTimer(v, entity, key);
		end;
	end;
end;

-- A function to get whether a player has a variable.
function titan:DoesPlayerHaveVar(player, entity, key, value)
	local entIndex = entity:EntIndex();
	
	if (player.fn_Vars[entIndex] and player.fn_Vars[entIndex][key] == value) then
		return true;
	end;
end;

-- A function to add to a player's variables.
function titan:AddPlayerVar(player, entity, key, value)
	local entIndex = entity:EntIndex();
	
	if ( !player.fn_Vars[entIndex] ) then
		player.fn_Vars[entIndex] = {};
	end;
	
	player.fn_Vars[entIndex][key] = value;
end;

-- A function to check if the variable can be sent.
function titan:CanVariableBeSent(player, entity)
	if ( !self:IsValidEntity(entity) ) then
		return SEND_ERROR;
	end;
	
	if ( entity != GetWorldEntity() and !entity:IsPlayer() and !entity:IsNPC() ) then
		if (entity.UpdateTransmitState) then
			local transmitState = entity:UpdateTransmitState();
			
			if ( ( transmitState == TRANSMIT_PVS and !player:Visible(entity)
			and !entity:Visible(player) ) or transmitState == TRANSMIT_NEVER ) then
				return SEND_FALSE;
			end;
		end;
	end;
	
	return SEND_TRUE;
end;

-- A function to update a player's timer.
function titan:UpdatePlayerTimer(player, messageBytes, entity, key)
	local entIndex = entity:EntIndex();
	local variables = self.netVars[entIndex];
	
	if (variables and variables[key] != nil) then
		local value = variables[key];
		
		if (type(value) == "string") then
			if (string.len(value) > 200) then
				value = string.sub(value, 1, 200);
			end;
		end;
		
		if (value != nil) then
			local success, encodedData = pcall( glon.encode, {entIndex, key, value} );
			
			if (success and encodedData) then
				self:AddPlayerVar(player, entity, key, value);
				
				umsg.Start("x", player);
					umsg.String(encodedData);
				umsg.End();
				
				messageBytes = messageBytes + string.len(encodedData);
			end;
		end;
	end;
	
	return messageBytes;
end;

-- A function to initialize a player.
function titan:InitializePlayer(player)
	local curTime = CurTime();
	local nextUpdate = curTime + 2;
	
	player.fn_NextUpdateAvailable = nextUpdate;
	player.fn_NextFullUpdate = nextUpdate;
	
	if (!player.fn_Initialized) then
		for k, v in ipairs(self.quickTimers) do
			if ( !IsValid(k) ) then
				self.quickTimers[k] = nil;
			end;
		end;
		
		for k, v in ipairs(self.slowTimers) do
			if ( !IsValid(k) ) then
				self.slowTimers[k] = nil;
			end;
		end;
		
		for k, v in ipairs(self.longTimers) do
			if ( !IsValid(k) ) then
				self.longTimers[k] = nil;
			end;
		end;
		
		player.fn_NextQuickTimerCall = 0;
		player.fn_NextLongTimerCall = 0;
		player.fn_Initialized = true;
		player.fn_Vars = {};
	end;
end;

-- A function to run a player's timers.
function titan:RunPlayerTimer(player, timerType, messageBytes)
	local timers = self[timerType][player];
	
	if (timers) then
		for k, v in pairs(timers) do
			local canSend = self:CanVariableBeSent(player, k);
			
			if (canSend == SEND_TRUE) then
				for k2, v2 in ipairs(v) do
					messageBytes = self:UpdatePlayerTimer(player, messageBytes, k, v2);
					
					table.remove(timers[k], k2);
					
					if (messageBytes > 256) then
						break;
					end;
				end;
				
				if (#timers[k] == 0) then
					timers[k] = nil;
				end;
				
				if (messageBytes > 256) then
					break;
				end;
			elseif (canSend == SEND_ERROR) then
				timers[k] = nil;
			end;
		end;
	end;
	
	return messageBytes;
end;

hook.Add("SetupPlayerVisibility", "titan.SetupPlayerVisibility", function(player)
	local messageBytes = 0;
	local curTime = CurTime();
	
	if (player.fn_Initialized) then
		if (curTime >= player.fn_NextQuickTimerCall) then
			player.fn_NextQuickTimerCall = curTime + (FrameTime() * 2);
			
			messageBytes = titan:RunPlayerTimer(player, "quickTimers", messageBytes);
			
			if (messageBytes < 256) then
				messageBytes = titan:RunPlayerTimer(player, "slowTimers", messageBytes);
			end;
		
			if (curTime >= player.fn_NextLongTimerCall) then
				player.fn_NextLongTimerCall = curTime + 0.5;
				
				if (messageBytes < 256) then
					messageBytes = titan:RunPlayerTimer(player, "longTimers", messageBytes);
				end;
			end;
		end;
		
		if (player.fn_NextFullUpdate) then
			if (curTime >= player.fn_NextFullUpdate) then
				titan:SendFullPlayerUpdate(player);
				
				player.fn_NextFullUpdate = nil;
			end;
		end;
	end;
end);

hook.Add("InitPostEntity", "titan.InitPostEntity", function()
	RunConsoleCommand("sv_usermessage_maxsize", "1024");
	
	for k, v in ipairs( ents.GetAll() ) do
		v.isMapEntity = true;
	end;
end);

hook.Add("PlayerInitialSpawn", "titan.PlayerInitialSpawn", function(player)
	timer.Simple(2, function()
		if ( IsValid(player) ) then
			umsg.Start("fn_UpdateReady", player);
			umsg.End();
		end;
	end);
end);

concommand.Add("fn_fullupdate", function(player, command, arguments)
	local curTime = CurTime();
	
	if (!player.fn_NextUpdateAvailable) then
		player.fn_NextUpdateAvailable = 0;
	end;
	
	if (curTime >= player.fn_NextUpdateAvailable) then
		titan:InitializePlayer(player);
	end;
end);