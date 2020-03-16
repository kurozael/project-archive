Clockwork.cloudnet.sendQueue = Clockwork.cloudnet.sendQueue or {};

util.AddNetworkString(Clockwork.cloudnet.NET_KEY);
util.AddNetworkString(Clockwork.cloudnet.PRUNE_KEY);
 
net.Receive(Clockwork.cloudnet.PRUNE_KEY, function(length, player)
	local entIndexes = {};
	local numEntities = net.ReadUInt(32);
	
	for i = 1, numEntities do
		entIndexes[#entIndexes + 1] = net.ReadUInt(32);
	end;
	
	for k, v in ipairs(entIndexes) do
		if (IsValid(Entity(v))) then
			Clockwork.cloudnet:SendEntity(player, v, true);
		end;
	end;
end);

function Clockwork.cloudnet:SetSendCallback(callback)
	self.sendCallback = callback;
end;

function Clockwork.cloudnet:CanSend(entity, target, key)
	if (not self.sendCallback or self.sendCallback(entity, target, key)) then
		return true;
	end;
	
	return false;
end;

function Clockwork.cloudnet:SetVar(entity, key, value)
	if (!IsValid(entity)) then
		return;
	end;
	
	if (value == nil) then
		ErrorNoHalt("You cannot set a CloudNet var to nil. Please find another way!\n");
		return;
	end;
	
	local index = entity:EntIndex();
	
	if (not self.stored[index]) then
		self.stored[index] = {};
	end;
	
	if (self.stored[index][key] == value) then
		return;
	end;
	
	self.stored[index][key] = value;
	
	for k, v in ipairs(player.GetAll()) do
		if (self:CanSend(entity, v, key)) then
			local uniqueID = v:UniqueID();
			self:AddToQueue(uniqueID, index, key, value);
		end;
	end;
end;

function Clockwork.cloudnet:AddToQueue(uniqueID, index, key, value, isForced)
	if (not self.cache[uniqueID]) then
		self.cache[uniqueID] = {};
	end;
	
	if (not self.cache[uniqueID][index]) then
		self.cache[uniqueID][index] = {};
	end;
	
	if (isForced or self.cache[uniqueID][index][key] ~= value) then
		self.cache[uniqueID][index][key] = value;
		
		if (not self.sendQueue[uniqueID]) then
			self.sendQueue[uniqueID] = {};
			self.sendQueue[uniqueID].numEntities = 0;
		end;
		
		if (not self.sendQueue[uniqueID][index]) then
			self.sendQueue[uniqueID][index] = {};
			self.sendQueue[uniqueID][index].numVars = 0;
			self.sendQueue[uniqueID].numEntities = self.sendQueue[uniqueID].numEntities + 1;
		end;
		
		if (self.sendQueue[uniqueID][index][key] == nil) then
			self.sendQueue[uniqueID][index].numVars = self.sendQueue[uniqueID][index].numVars + 1;
		end;
		
		self.sendQueue[uniqueID][index][key] = value;
	end;
end;

function Clockwork.cloudnet:SendEntity(player, index, isForced)
	local uniqueID = player:UniqueID();
	local data = self.stored[index];
	local entity = Entity(index);
	
	if (data and IsValid(entity)) then
		for k, v in pairs(data) do
			if (self:CanSend(entity, player, k)) then
				self:AddToQueue(uniqueID, index, k, v, isForced);
			end;
		end;
	end;
end;

function Clockwork.cloudnet:SendAll(player)
	local uniqueID = player:UniqueID();
	
	for k, v in pairs(self.stored) do
		local entity = Entity(k);
		
		if (IsValid(entity)) then
			for k2, v2 in pairs(v) do
				if (self:CanSend(entity, player, k2)) then
					self:AddToQueue(uniqueID, k, k2, v2);
				end;
			end;
		end;
	end;
end;

function Clockwork.cloudnet:WriteData(key, value)
	net.WriteString(key);
	
	if (type(value) == "number") then
		net.WriteUInt(self.INT, 32);
		net.WriteFloat(value);
	elseif (type(value) == "string") then
		net.WriteUInt(self.STRING, 32);
		net.WriteString(value);
	elseif (type(value) == "boolean") then
		net.WriteUInt(self.BOOL, 32);
		net.WriteBool(value);
	elseif (type(value) == "Vector") then
		net.WriteUInt(self.VECTOR, 32);
		net.WriteVector(value);
	end;
end;

Clockwork.cloudnet.nextSendUpdate = 0;

hook.Add("PlayerAuthed", "Clockwork.cloudnet.PlayerAuthed", function(player)
	Clockwork.cloudnet:SendAll(player);
end);

hook.Add("EntityRemoved", "Clockwork.cloudnet.EntityRemoved", function(entity)
	local index = entity:EntIndex();
	
	for k, v in pairs(Clockwork.cloudnet.cache) do
		Clockwork.cloudnet.cache[k][index] = nil;
	end;
	
	Clockwork.cloudnet.stored[index] = nil;
end);

hook.Add("PlayerDisconnected", "Clockwork.cloudnet.PlayerDisconnected", function(player)
	local uniqueID = player:UniqueID();
	
	Clockwork.cloudnet.cache[uniqueID] = nil;
	Clockwork.cloudnet.sendQueue[uniqueID] = nil;
end);

Clockwork.cloudnet.NUM_VARS_STRING = "numVars";

hook.Add("Think", "Clockwork.cloudnet.Think", function()
	if (CurTime() >= Clockwork.cloudnet.nextSendUpdate) then
		for k, v in ipairs(player.GetAll()) do
			local uniqueID = v:UniqueID();
			local sendTable = Clockwork.cloudnet.sendQueue[uniqueID];
			
			if (sendTable) then
				net.Start(Clockwork.cloudnet.NET_KEY);
				net.WriteUInt(sendTable.numEntities, 32);
				
				for k2, v2 in pairs(sendTable) do
					if (tonumber(k2)) then
						net.WriteUInt(k2, 32);
						net.WriteUInt(v2.numVars, 32);
						
						for k3, v3 in pairs(v2) do
							if (k3 ~= Clockwork.cloudnet.NUM_VARS_STRING) then
								Clockwork.cloudnet:WriteData(k3, v3);
							end;
						end;
					end;
				end;
				
				net.Send(v);
			end;
		end;
		
		Clockwork.cloudnet.sendQueue = {};
		Clockwork.cloudnet.nextSendUpdate = CurTime() + 0.05;
	end;
end);