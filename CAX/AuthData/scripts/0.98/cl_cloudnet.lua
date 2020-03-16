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
end;

function Clockwork.cloudnet:ReadData()
	local output = {};
	local numEntities = net.ReadUInt(32);
	
	for i = 1, numEntities do
		local index = net.ReadUInt(32);
		
		output[index] = {};
		
		local numVars = net.ReadUInt(32);
		
		for j = 1, numVars do
			local key = net.ReadString();
			local valueType = net.ReadUInt(32);
			
			if (valueType == self.INT) then
				output[index][key] = net.ReadFloat();
			elseif (valueType == self.STRING) then
				output[index][key] = net.ReadString();
			elseif (valueType == self.BOOL) then
				output[index][key] = net.ReadBool();
			elseif (valueType == self.VECTOR) then
				output[index][key] = net.ReadVector();
			end;
		end;
	end;
	
	for k, v in pairs(output) do
		if (not self.stored[k]) then
			self.stored[k] = {};
		end;
		
		for k2, v2 in pairs(v) do
			self.stored[k][k2] = v2;
		end;
	end;
end;


hook.Add("OnEntityCreated", "Clockwork.cloudnet.OnEntityCreated", function(entity)

end);

Clockwork.cloudnet.nextPrune = 0;

hook.Add("Tick", "Clockwork.cloudnet.Tick", function(entity)
	local curTime = CurTime();
	
	if (curTime >= Clockwork.cloudnet.nextPrune) then
		Clockwork.cloudnet.nextPrune = curTime + 5;
		
		local entityList = {};
		local hasEntity = false;
		
		for k, v in pairs(Clockwork.cloudnet.stored) do
			if (not IsValid(Entity(k))) then
				Clockwork.cloudnet.stored[k] = nil;
				
				entityList[#entityList + 1] = k;
				hasEntity = true;
			end;
		end;
		
		if (hasEntity) then
			net.Start(Clockwork.cloudnet.PRUNE_KEY)
			net.WriteUInt(#entityList, 32);
			
			for k, v in ipairs(entityList) do
				net.WriteUInt(v, 32);
			end;
			
			net.SendToServer();
		end;
	end;
end);

net.Receive(Clockwork.cloudnet.NET_KEY, function(length)
	Clockwork.cloudnet:ReadData();
end);