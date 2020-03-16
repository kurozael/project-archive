local ENTITY = FindMetaTable("Entity");

Clockwork.networking = {};
Clockwork.networking.requests = {};
Clockwork.networking.entities = {};

if (SERVER) then 
	util.AddNetworkString("cwv");
	util.AddNetworkString("cwr");
	util.AddNetworkString("cwc");
	
	net.Receive("cwv", function(len, ply)
		Clockwork.networking:SyncClient(ply)
	end);
	
	function Clockwork.networking:SyncClient(ply)
		local sharedVars = Clockwork.kernel:GetSharedVars():Player();
		
		for id, values in pairs(self.entities) do			
			for key, value in pairs(values) do
				if (IsEntity(value) and !value:IsValid()) then 
					self.entities[id][key] = nil;
					continue; 
				end;
				
				local definition = sharedVars and sharedVars[key];
				
				if (!value:IsPlayer() or not definition or (not definition.bPlayerOnly and not definition.playerOnly) or ply == value) then
					Clockwork.networking:SendNetVar(ply, id, key, value);
				end;
			end;
		end;
	end;
	
	function Clockwork.networking:BroadcastNetVar(id, key, value)
		net.Start("cwv");
			net.WriteUInt(id, 16);
			net.WriteString(key);
			net.WriteType(value);
		net.Broadcast();
	end;
	
	function Clockwork.networking:SendNetVar(ply, id, key, value)
		net.Start("cwv");
			net.WriteUInt(id, 16);
			net.WriteString(key);
			net.WriteType(value);
		net.Send(ply);
	end;
	
	net.Receive("cwr", function(bits, ply)
		local id  = net.ReadUInt(16);
		local ent = Entity(id);
		local key = net.ReadString();
		
		if (ent:GetNetRequest(key) ~= nil) then
			Clockwork.networking:SendNetRequest(ply, id, key, ent:GetNetRequest(key));
		end;
	end);
	
	function Clockwork.networking:SendNetRequest(ply, id, key, value)
		net.Start("cwr");
			net.WriteUInt(id, 16);
			net.WriteString(key);
			net.WriteType(value);
		net.Send(ply);
	end;
	
	hook.Add("EntityRemoved", "cwc", function(ent)
		Clockwork.networking:ClearData(ent:EntIndex());
	end);
elseif (CLIENT) then
	net.Receive("cwv", function(len)
		local entid = net.ReadUInt(16);
		local key = net.ReadString();
		local typeid = net.ReadUInt(8);
		local value = net.ReadType(typeid);

		Clockwork.networking:StoreNetVar(entid, key, value);
	end);
	
	hook.Add("InitPostEntity", "Clockwork.networking", function()
		net.Start("cwv");
		net.SendToServer();
	end);
	
	hook.Add("OnEntityCreated", "Clockwork.networking", function(ent)
		local id = ent:EntIndex();
		local values = Clockwork.networking:GetNetVars(id);
		
		for key, value in pairs(values) do
			ent:SetNetVar(key, value);
		end;
	end);
	
	function ENTITY:SendNetRequest(key)
		Clockwork.networking:SendNetRequest(self:EntIndex(), key);
	end;
	
	function Clockwork.networking:SendNetRequest(id, key)
		local requests = self.requests;

		if (!requests[id]) then
			requests[id] = {};
		end;
		
		if (!requests[id]["NumRequests"]) then
			requests[id]["NumRequests"] = 0;
		end;
		
		if (!requests[id]["NextRequest"]) then
			requests[id]["NextRequest"] = CurTime();
		end;
		
		local maxRetries = -1;
		
		if (maxRetries >= 0 and requests[id]["NumRequests"] >= maxRetries) then
			return;
		end;
		
		if (requests[id]["NextRequest"] > CurTime()) then
			return;
		end;
		
		net.Start("cwr");
			net.WriteUInt(id, 16);
			net.WriteString(key);
		net.SendToServer();
		
		requests[id]["NextRequest"] = CurTime() + 5;
		requests[id]["NumRequests"] = requests[id]["NumRequests"] + 1;
	end;
	
	net.Receive("cwr", function(bits)
		local id = net.ReadUInt(16);
		local key = net.ReadString();
		local typeid = net.ReadUInt(8);
		local value = net.ReadType(typeid);
		
		Entity(id):SetNetRequest(key, value);
	end);
	
	net.Receive("cwc", function(bits)
		local id = net.ReadUInt(16);
		Clockwork.networking:ClearData(id);
	end);
end;

function ENTITY:SetNetVar(key, value, force)
	if (Clockwork.networking:GetNetVars(self:EntIndex())[key] == value and not force) then
		return;
	end;

	Clockwork.networking:StoreNetVar(self:EntIndex(), key, value);

	if (SERVER) then
		local sharedVars = Clockwork.kernel:GetSharedVars():Player();
		local definition = sharedVars and sharedVars[key];
		
		if (!self:IsPlayer() or not definition or (not definition.bPlayerOnly and not definition.playerOnly)) then
			Clockwork.networking:BroadcastNetVar(self:EntIndex(), key, value);
		elseif (self:IsPlayer()) then
			Clockwork.networking:SendNetRequest(self, self:EntIndex(), key, value);
		end;
	end;
end;

function ENTITY:GetNetVar(key, default)
	local values = Clockwork.networking:GetNetVars(self:EntIndex());
	
	if (values[key] ~= nil) then
		return values[key];
	else
		return default;
	end;
end;

function Clockwork.networking:StoreNetVar(id, key, value)
	self.entities[id] = self.entities[id] or {};
	self.entities[id][key] = value;
end;

function Clockwork.networking:GetNetVars(id)
	return self.entities[id] or {}
end;

function ENTITY:SetNetRequest(key, value)
	Clockwork.networking:StoreNetRequest(self:EntIndex(), key, value);
end;

function ENTITY:GetNetRequest(key, default)
	local values = Clockwork.networking:GetNetRequests(self:EntIndex());
	
	if (values[key] ~= nil) then
		return values[key];
	else
		return default;
	end;
end;

function Clockwork.networking:StoreNetRequest(id, key, value)
	self.requests[id] = self.requests[id] or {};
	self.requests[id][key] = value;
end;

function Clockwork.networking:GetNetRequests(id)
	return self.requests[id] or {};
end

function Clockwork.networking:RemoveNetRequests(id)
	self.requests[id] = nil;
end;

function Clockwork.networking:ClearData(id)
	self.entities[id] = nil;
	self.requests[id] = nil;

	if (SERVER) then
		net.Start("cwc");
			net.WriteUInt(id, 16);
		net.Broadcast();
	end;
end;